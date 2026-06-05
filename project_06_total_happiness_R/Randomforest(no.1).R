
# 1. Randomforest



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




