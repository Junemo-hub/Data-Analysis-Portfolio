###  initial setting ###

setwd("D:/998.Python/Data-Analysis-Portfolio/project_06_total_happiness_R") 
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



## XGBOOST #####

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


## LightGBM##
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




## SVR ###
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




