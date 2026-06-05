#############################Diagnosis###################


###  initial setting ###

setwd("######cleaned_data.scv#######") 
# data processing
df <- read.csv("data/full_data.csv") 
df$year    <- as.integer(df$year)
df$country <- as.factor(df$country)
df$region  <- as.factor(df$region)
key_vars <- c(
  "happiness_score",
  "gdp_per_capita",
  "social_support",
  "healthy_life_expectancy",
  "freedom_to_make_life_choices",
  "generosity",
  "perceptions_of_corruption"
)

# drop out the missing values
df_clean <- na.omit(df)
df_clean$perceptions_of_corruption[df_clean$perceptions_of_corruption == "N/A"] <- NA
df_clean <- df_clean[complete.cases(df_clean), ]
df_clean$perceptions_of_corruption <- as.numeric(df_clean$perceptions_of_corruption)



# 2015~2022: train , 2023 : test
train_data <- df_clean[df_clean$year <= 2022, ]
test_data  <- df_clean[df_clean$year == 2023, ]

str(df_clean)


# delete duplicate
library(dplyr)
df_clean <- df_clean %>% distinct()



#### Diagnosis ####
#1~3 I analyzed the 1~3(Outliers, Leverage, Influential Point).
library(dplyr)
library(broom)
library(ggplot2)


all_diagnosis_df <- list()
for(year in unique(df_clean$year)) {
  df_year <- df_clean %>% filter(year == !!year)
  
  # linear regression (lm)
  model <- lm(happiness_score ~ gdp_per_capita + social_support + 
                healthy_life_expectancy + freedom_to_make_life_choices + 
                generosity + perceptions_of_corruption,
              data = df_year)
  
  # dependent (k), observation (n)
  k <- length(coef(model)) - 1 
  n <- nrow(df_year)
  
  # calculate threshold
  leverage_threshold <- 2 * (k + 1) / n
  cooks_d_threshold <- 4 / n
  outlier_threshold <- 3 
  
  # calculate
  diag_values <- data.frame(
    country = df_year$country,
    year = year,
    std_residual = rstandard(model),
    hat_value = hatvalues(model),
    cooks_d = cooks.distance(model)
  )
  
  # Is it higher than threshold?
  diag_values <- diag_values %>%
    mutate(
      is_outlier = abs(std_residual) > outlier_threshold,
      is_leverage = hat_value > leverage_threshold,
      is_influential = cooks_d > cooks_d_threshold,
      # Check whether it belongs to at least one of them
      is_problem = is_outlier | is_leverage | is_influential
    )
  
  all_diagnosis_df[[as.character(year)]] <- diag_values
}

# combine all of data
combined_diagnosis_df <- bind_rows(all_diagnosis_df)

# filter
problematic_obs <- combined_diagnosis_df %>%
  filter(is_problem == TRUE) %>%
  select(year, country, std_residual, hat_value, cooks_d, is_outlier, is_leverage, is_influential) %>%
  arrange(year, desc(cooks_d))

## summarize problematic values
print(problematic_obs)



##### create report #####
# install.packages("ggplot2")
library(ggplot2)

# Cook's D
plot_data <- problematic_obs %>%
  filter(is_influential == TRUE) %>%
  # Cook's D
  group_by(country) %>%
  mutate(total_cooks_d = sum(cooks_d)) %>%
  ungroup() %>%
  top_n(10, total_cooks_d)

ggplot(plot_data, aes(x = year, y = cooks_d, color = country)) +
  geom_line(linewidth = 1, alpha = 0.6) +
  geom_point(size = 3) +
  
  # Cook's D high nations
  geom_text(aes(label = ifelse(cooks_d > 0.1, as.character(country), "")), 
            vjust = -1, hjust = 0.5, size = 3, check_overlap = TRUE) +
  
  facet_wrap(~ country) + # devide graphs by nation
  labs(
    title = "Cook's Distance of Influential Countries Over Time",
    subtitle = "Identifying persistent exceptional cases influencing model coefficients",
    x = "Year",
    y = "Cook's Distance (Model Influence)",
    color = "Country"
  ) +
  theme_minimal(base_size = 14) +
  theme(legend.position = "none",
        plot.title = element_text(face = "bold"))



# Dive into Botswana and Rwanda.
library(dplyr)
library(ggplot2)

# filtering 2 countries
target_countries <- c("Botswana", "Rwanda")
target_data <- combined_diagnosis_df %>%
  filter(country %in% target_countries)

# change the form of data (to use in ggplot)
plot_long <- target_data %>%
  select(year, country, std_residual, hat_value, cooks_d) %>%
  tidyr::pivot_longer(
    cols = c(std_residual, hat_value, cooks_d),
    names_to = "Metric",
    values_to = "Value"
  )

# visulization
ggplot(plot_long, aes(x = year, y = Value, color = Metric, group = Metric)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  facet_wrap(~ country, scales = "free_y", ncol = 1) +
  labs(
    title = "Diagnostic Metrics for Botswana and Rwanda Over Time",
    subtitle = "Identifying the source of high Cook's Distance (Residual vs. Leverage)",
    x = "Year",
    y = "Metric Value"
  ) +
  theme_minimal(base_size = 14)



############ analyze Rwanda ###############

library(dplyr)
library(ggplot2)
library(tidyr)

# Define Independent Variables (X-Variables)
predictors <- c("gdp_per_capita", "social_support", "healthy_life_expectancy", 
                "freedom_to_make_life_choices", "generosity", "perceptions_of_corruption")

# 1. Data Standardization (Z-Score Calculation)
# Z-Score: (Value - Mean) / Standard Deviation. 0 represents the mean.
df_standardized <- df_clean %>%
  # Standardize across all observations for comparative clarity
  mutate(across(all_of(predictors), scale)) %>%
  ungroup()

# 2. Data Preparation: Filter Rwanda and rename groups
comparison_data_std <- df_standardized %>%
  mutate(Group = ifelse(country == "Rwanda", "Rwanda", "All Other Countries")) %>%
  select(Group, country, year, all_of(predictors))

plot_long_std <- comparison_data_std %>%
  tidyr::pivot_longer(
    cols = all_of(predictors),
    names_to = "Variable",
    values_to = "Z_Score"
  )

# 3. Visualization: Box Plot with Rwanda's Z-Scores highlighted
ggplot(plot_long_std, aes(x = Variable, y = Z_Score)) +
  
  # 1. Box Plot (Global Distribution Z-Scores)
  geom_boxplot(aes(fill = Variable), outlier.shape = NA, alpha = 0.4) +
  
  # 2. Rwanda's Z-Scores (Points) - Plotting all years
  geom_point(data = filter(plot_long_std, Group == "Rwanda"), 
             aes(color = Group), 
             size = 4, 
             alpha = 1,
             position = position_jitter(width = 0.15)) +
  
  # 3. Y=0 line (Global Average)
  geom_hline(yintercept = 0, linetype = "dashed", color = "black", linewidth = 1) +
  
  # 4. Labels: Label Rwanda's points with the year
  geom_text(data = filter(plot_long_std, Group == "Rwanda"),
            aes(label = year, color = Group),
            vjust = -1.5, size = 3.5, position = position_jitter(width = 0.15)) +
  
  # 5. Facet Wrap
  facet_wrap(~ Variable, scales = "free_y", ncol = 3) +
  
  labs(
    title = "Rwanda's X-Variable Position: Z-Score Comparison against Global Average",
    subtitle = "Z-Score: 0 = Global Mean, ±1 = 1 Standard Deviation. Confirming low Leverage.",
    x = "", 
    y = "Z-Score (Standard Deviation from Mean)"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    axis.text.x = element_blank(), 
    axis.ticks.x = element_blank(),
    plot.title = element_text(face = "bold"),
    legend.position = "none"
  )



### Analyze Botswana ###################
library(dplyr)
library(ggplot2)
library(tidyr)

# Define Independent Variables (X-Variables)
predictors <- c("gdp_per_capita", "social_support", "healthy_life_expectancy", 
                "freedom_to_make_life_choices", "generosity", "perceptions_of_corruption")

# 1. Data Standardization (Z-Score Calculation)
# Z-Score: (Value - Mean) / Standard Deviation. 0 represents the mean.
df_standardized <- df_clean %>%
  mutate(across(all_of(predictors), scale)) %>%
  ungroup()

# 2. Data Preparation: Filter Botswana data
comparison_data_std <- df_standardized %>%
  mutate(Group = ifelse(country == "Botswana", "Botswana", "All Other Countries")) %>%
  select(Group, country, year, all_of(predictors))

plot_long_std <- comparison_data_std %>%
  tidyr::pivot_longer(
    cols = all_of(predictors),
    names_to = "Variable",
    values_to = "Z_Score"
  )

# 3. Visualization: Box Plot with Botswana's Z-Scores highlighted
ggplot(plot_long_std, aes(x = Variable, y = Z_Score)) +
  
  # 1. Box Plot (Global Distribution Z-Scores)
  geom_boxplot(aes(fill = Variable), outlier.shape = NA, alpha = 0.4) +
  
  # 2. Botswana's Z-Scores (Points) - Plotting all years
  geom_point(data = filter(plot_long_std, Group == "Botswana"), 
             aes(color = Group), 
             size = 4, 
             alpha = 1,
             position = position_jitter(width = 0.15)) +
  
  # 3. Y=0 line (Global Average)
  geom_hline(yintercept = 0, linetype = "dashed", color = "black", linewidth = 1) +
  
  # 4. Labels: Label Botswana's points with the year
  geom_text(data = filter(plot_long_std, Group == "Botswana"),
            aes(label = year, color = Group),
            vjust = -1.5, size = 3.5, position = position_jitter(width = 0.15)) +
  
  # 5. Facet Wrap
  facet_wrap(~ Variable, scales = "free_y", ncol = 3) +
  
  labs(
    title = "Botswana's X Variable Position: Z-Score Comparison Against Global Average",
    subtitle = "Identifying variables causing high Leverage (X-extremity)",
    x = "", 
    y = "Z-Score (Standard Deviation from Mean)"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    axis.text.x = element_blank(), 
    axis.ticks.x = element_blank(),
    plot.title = element_text(face = "bold"),
    legend.position = "none"
  )


#####################Randomforest###############################



# package install & load
install.packages("randomForest")
library(randomForest)

# data processing
df <- read.csv("data/full_data.csv") 
df$year    <- as.integer(df$year)
df$country <- as.factor(df$country)
df$region  <- as.factor(df$region)
key_vars <- c(
  "happiness_score",
  "gdp_per_capita",
  "social_support",
  "healthy_life_expectancy",
  "freedom_to_make_life_choices",
  "generosity",
  "perceptions_of_corruption"
)

# drop out missing values
df_clean <- na.omit(df)
df_clean$perceptions_of_corruption[df_clean$perceptions_of_corruption == "N/A"] <- NA
df_clean <- df_clean[complete.cases(df_clean), ]
df_clean$perceptions_of_corruption <- as.numeric(df_clean$perceptions_of_corruption)



# divide data into train set, and test set
train_data <- df_clean[df_clean$year <= 2022, ]
test_data  <- df_clean[df_clean$year == 2023, ]

str(df_clean)

# RF model training!!
rf_model <- randomForest(happiness_score ~ gdp_per_capita + social_support + 
                           healthy_life_expectancy + freedom_to_make_life_choices + 
                           generosity + perceptions_of_corruption, 
                         data = train_data, ntree = 100)

print(rf_model)

# predict
predictions <- predict(rf_model, newdata = test_data)

comparison <- data.frame(Actual = test_data$happiness_score, Predicted = predictions)
print(comparison)




# R^2 & RMSE check!
rmse_rf <- sqrt(mean((predictions - test_data$happiness_score)^2))
rsq_rf <- 1 - (sum((predictions - test_data$happiness_score)^2) / sum((test_data$happiness_score - mean(test_data$happiness_score))^2))

cat("Random Forest RMSE:", rmse_rf, "\n")
cat("Random Forest R^2:", rsq_rf, "\n")




# making plots!!!!!!
predictions <- predict(rf_model, newdata = test_data)

# Actual vs Predicted plot
plot(
  test_data$happiness_score, predictions,
  xlab = "Actual Happiness Score (2023)",
  ylab = "Predicted Happiness Score (2023)",
  main = "Prediction Model: Actual vs Predicted (2023)",
  pch = 19,
  col = rgb(0, 0.4, 0.8, 0.6)
)

# y = x lines
abline(0, 1, col = "red", lwd = 2)


#### heatmap
# call packages
library(ggplot2)
library(reshape2)

# set variables
vars <- c(
  "happiness_score", 
  "gdp_per_capita", 
  "social_support", 
  "healthy_life_expectancy", 
  "freedom_to_make_life_choices", 
  "generosity", 
  "perceptions_of_corruption"
)

# calculate correlation
cor_mat <- cor(df_clean[, vars], use = "complete.obs")

# to use in heatmap
cor_df <- melt(cor_mat)
names(cor_df) <- c("Var1", "Var2", "value")

# draw heatmap
ggplot(cor_df, aes(x = Var2, y = Var1, fill = value)) +
  geom_tile() +  # 타일을 사용하여 색을 채움
  geom_text(aes(label = round(value, 2)), size = 3) +  # show the correlation values
  scale_fill_gradient2(
    low = "white",
    high = "darkred",
    mid = "orange",
    midpoint = 0,
    limits = c(-1, 1)
  ) +  # color
  labs(
    title = "Correlation Heatmap of Happiness and Explanatory Variables",
    x = "",
    y = ""
  ) +  # title and label
  theme_minimal(base_size = 14) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)  # adjust x-axis
  )



# cross-validation

install.packages("caret")
library(caret)

# 
train_control <- trainControl(method = "cv", number = 10)

# adjust `mtry` by `tuneLength`
rf_model_cv <- train(
  happiness_score ~ gdp_per_capita + social_support + healthy_life_expectancy + 
    freedom_to_make_life_choices + generosity + perceptions_of_corruption,
  data = df_clean,
  method = "rf",
  trControl = train_control,
  tuneGrid = data.frame(mtry = 1:6)  # `mtry` from 1 to 6
)
# print out model
print(rf_model_cv)



# SHAP !!!
install.packages("iml")
library(iml)

X <- df_clean[, c("gdp_per_capita", "social_support", "healthy_life_expectancy", "freedom_to_make_life_choices", 
                  "generosity", "perceptions_of_corruption")]

# Predictor 
predictor <- Predictor$new(rf_model, data = X, y = df_clean$happiness_score)

# SHAP values
shap <- Shapley$new(predictor, x.interest = X[1, ])  # SHAP calculation

# SHAP plot
shap$plot()




###  initial setting ###

setwd("######cleaned_data.scv#######") 
# data processing
df <- read.csv("data/full_data.csv") 
df$year    <- as.integer(df$year)
df$country <- as.factor(df$country)
df$region  <- as.factor(df$region)
key_vars <- c(
  "happiness_score",
  "gdp_per_capita",
  "social_support",
  "healthy_life_expectancy",
  "freedom_to_make_life_choices",
  "generosity",
  "perceptions_of_corruption"
)

# drop out the missing values
df_clean <- na.omit(df)
df_clean$perceptions_of_corruption[df_clean$perceptions_of_corruption == "N/A"] <- NA
df_clean <- df_clean[complete.cases(df_clean), ]
df_clean$perceptions_of_corruption <- as.numeric(df_clean$perceptions_of_corruption)



# 2015~2022: train , 2023 : test
train_data <- df_clean[df_clean$year <= 2022, ]
test_data  <- df_clean[df_clean$year == 2023, ]

str(df_clean)



############# XGBOOST ##############

# install package
install.packages("xgboost")
library(xgboost)

# data setting
train_matrix <- as.matrix(df_clean[, c("gdp_per_capita", "social_support", "healthy_life_expectancy", 
                                       "freedom_to_make_life_choices", "generosity", "perceptions_of_corruption")])
train_labels <- df_clean$happiness_score

# xgboost train
xgb_model <- xgboost(data = train_matrix, label = train_labels, nrounds = 100, objective = "reg:squarederror")

# predict
xgb_pred <- predict(xgb_model, as.matrix(test_data[, c("gdp_per_capita", "social_support", "healthy_life_expectancy", 
                                                       "freedom_to_make_life_choices", "generosity", "perceptions_of_corruption")]))

# RMSE, R^2 
xgb_rmse <- sqrt(mean((xgb_pred - test_data$happiness_score)^2))
xgb_rsq <- 1 - sum((xgb_pred - test_data$happiness_score)^2) / sum((mean(test_data$happiness_score) - test_data$happiness_score)^2)

cat("XGBoost RMSE:", xgb_rmse, "\n")
cat("XGBoost R^2:", xgb_rsq, "\n")


## Linear regrssion ##
lm_model <- lm(happiness_score ~ gdp_per_capita + social_support + healthy_life_expectancy + 
                 freedom_to_make_life_choices + generosity + perceptions_of_corruption, 
               data = df_clean)

# prediction
lm_pred <- predict(lm_model, newdata = test_data)

# RMSE, R^2 
lm_rmse <- sqrt(mean((lm_pred - test_data$happiness_score)^2))
lm_rsq <- 1 - sum((lm_pred - test_data$happiness_score)^2) / sum((mean(test_data$happiness_score) - test_data$happiness_score)^2)

cat("Linear Regression RMSE:", lm_rmse, "\n")
cat("Linear Regression R^2:", lm_rsq, "\n")


############### LightGBM################
# install package
install.packages("lightgbm")
library(lightgbm)

# data setting
train_matrix <- as.matrix(df_clean[, c("gdp_per_capita", "social_support", "healthy_life_expectancy", 
                                       "freedom_to_make_life_choices", "generosity", "perceptions_of_corruption")])
train_labels <- df_clean$happiness_score

# lightgbm train
lgb_model <- lightgbm(data = train_matrix, label = train_labels, objective = "regression", nrounds = 100)

# prediction
lgb_pred <- predict(lgb_model, as.matrix(test_data[, c("gdp_per_capita", "social_support", "healthy_life_expectancy", 
                                                       "freedom_to_make_life_choices", "generosity", "perceptions_of_corruption")]))

# RMSE, R^2 
lgb_rmse <- sqrt(mean((lgb_pred - test_data$happiness_score)^2))
lgb_rsq <- 1 - sum((lgb_pred - test_data$happiness_score)^2) / sum((mean(test_data$happiness_score) - test_data$happiness_score)^2)

cat("LightGBM RMSE:", lgb_rmse, "\n")
cat("LightGBM R^2:", lgb_rsq, "\n")




############## SVR ###############
# install package
install.packages("e1071")
library(e1071)

# train
svr_model <- svm(happiness_score ~ gdp_per_capita + social_support + healthy_life_expectancy + 
                   freedom_to_make_life_choices + generosity + perceptions_of_corruption, 
                 data = df_clean)

# prediction
svr_pred <- predict(svr_model, newdata = test_data)

# RMSE, R^2 
svr_rmse <- sqrt(mean((svr_pred - test_data$happiness_score)^2))
svr_rsq <- 1 - sum((svr_pred - test_data$happiness_score)^2) / sum((mean(test_data$happiness_score) - test_data$happiness_score)^2)

cat("Support Vector Regression RMSE:", svr_rmse, "\n")
cat("Support Vector Regression R^2:", svr_rsq, "\n")



### summary ####
# RMSE, R² of all of the models
results <- data.frame(
  Model = c("Linear Regression", "XGBoost", "LightGBM", "SVR"),
  RMSE = c(lm_rmse, xgb_rmse, lgb_rmse, svr_rmse),
  R_squared = c(lm_rsq, xgb_rsq, lgb_rsq, svr_rsq)
)

# print out the results
print(results)


###  initial setting ###

# data processing
df <- read.csv("data/full_data.csv") 
df$year    <- as.integer(df$year)
df$country <- as.factor(df$country)
df$region  <- as.factor(df$region)
key_vars <- c(
  "happiness_score",
  "gdp_per_capita",
  "social_support",
  "healthy_life_expectancy",
  "freedom_to_make_life_choices",
  "generosity",
  "perceptions_of_corruption"
)

# drop out the missing values
df_clean <- na.omit(df)
df_clean$perceptions_of_corruption[df_clean$perceptions_of_corruption == "N/A"] <- NA
df_clean <- df_clean[complete.cases(df_clean), ]
df_clean$perceptions_of_corruption <- as.numeric(df_clean$perceptions_of_corruption)



# 2015~2022: train , 2023 : test
train_data <- df_clean[df_clean$year <= 2022, ]
test_data  <- df_clean[df_clean$year == 2023, ]

str(df_clean)


# delete duplicate
df_clean <- df_clean %>% distinct()


########## plm - Timeregression ###########
library(dplyr)
library(broom)
library(ggplot2)

all_yearly_coefs_df <- data.frame()

for(year in unique(df_clean$year)) {
  # 1. filtering
  df_year <- df_clean %>% filter(year == !!year)
  
  # 2. lm
  model <- lm(happiness_score ~ gdp_per_capita + social_support + 
                healthy_life_expectancy + freedom_to_make_life_choices + 
                generosity + perceptions_of_corruption,
              data = df_year)
  
  # 3. summarize the result bytidy()
  # estimate:
  # std.error
  # p.value
  tidy_model <- tidy(model) %>%
    filter(term != "(Intercept)") %>% # exclude Intercept
    mutate(year = year) # add year columns
  
  # 4. combine the results with data frame
  all_yearly_coefs_df <- bind_rows(all_yearly_coefs_df, tidy_model)
}

# check the dataframe
head(all_yearly_coefs_df)

############ making graphs #############
# visulization - as time goes, how betas are chaging?
ggplot(all_yearly_coefs_df, 
       aes(x = year, y = estimate, group = term, color = term)) +
  
  # 1. line graph
  geom_line(linewidth = 1) + 
  
  # 2. dot graph
  geom_point(size = 2) +
  
  # 3. 95% confidence
  # 95% confidence: estimate ± 1.96 * std.error
  geom_ribbon(aes(ymin = estimate - 1.96 * std.error, 
                  ymax = estimate + 1.96 * std.error,
                  fill = term),
              alpha = 0.1, show.legend = FALSE) +
  
  # 4. applying Facet
  # scales
  facet_wrap(~ term, scales = "free_y", ncol = 3) +
  
  # 5. Theme and title
  labs(title = "Independent Variable Coefficients Over Time",
       x = "Year",
       y = "Coefficient (Beta Estimate)",
       color = "Variable") +
  theme_minimal(base_size = 14) +
  theme(legend.position = "none",
        plot.title = element_text(face = "bold", hjust = 0.5))








