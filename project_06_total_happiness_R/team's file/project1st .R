library(dplyr)
library(ggplot2)

# data processing
df <- total_happiness_2015_2023
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
df_clean <- df[complete.cases(df[key_vars]), ]
nrow(df_clean)
# train: 2015–2022
train <- df_clean[df_clean$year <= 2022, ]
# test: 2023
test  <- df_clean[df_clean$year == 2023, ]

#Regression Model
dim(train)
dim(test)
model <- lm(
  happiness_score ~ gdp_per_capita +
    social_support +
    healthy_life_expectancy +
    freedom_to_make_life_choices +
    generosity +
    perceptions_of_corruption,
  data = train
)

summary(model)

#Predict 2023
test$pred <- predict(model, newdata = test)

rmse <- sqrt(mean((test$pred - test$happiness_score)^2))
mae  <- mean(abs(test$pred - test$happiness_score))

cat("RMSE =", rmse, "\n")
cat("MAE  =", mae, "\n")

plot(
  test$happiness_score, test$pred,
  xlab = "Actual Happiness Score (2023)",
  ylab = "Predicted Happiness Score (2023)",
  main = "Prediction Model: Actual vs Predicted (2023)",
  pch = 19,
  col = rgb(0, 0.4, 0.8, 0.6)
)

abline(0, 1, col = "red", lwd = 2)

plot(
  train$happiness_score, train$gdp_per_capita,
  xlab = "Happiness Score (Train 2015–2022)",
  ylab = "GDP per Capita",
  main = "Distribution of the Training Model: Happiness vs GDP",
  pch = 19,
  col = rgb(0,0.4,0.8,0.6)
)

abline(lm(gdp_per_capita ~ happiness_score, data = train), col = "red", lwd = 2)

vars <- c(
  "happiness_score",
  "gdp_per_capita",
  "social_support",
  "healthy_life_expectancy",
  "freedom_to_make_life_choices",
  "generosity",
  "perceptions_of_corruption"
)

# heatmap
cor_mat <- cor(df_clean[, vars], use = "complete.obs")
cor_mat
cor_df <- melt(cor_mat)
names(cor_df) <- c("Var1", "Var2", "value")
ggplot(cor_df, aes(x = Var2, y = Var1, fill = value)) +
  geom_tile() +
  geom_text(aes(label = round(value, 2)), size = 3) +
  scale_fill_gradient2(
    low = "white",
    high = "darkred",
    mid = "orange",
    midpoint = 0,
    limits = c(-1, 1)
  ) +
  labs(
    title = "Correlation Heatmap of Happiness and Explanatory Variables",
    x = "",
    y = ""
  ) +
  theme_minimal(base_size = 14) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

#Draw map
whr2023 <- df_clean[df_clean$year == 2023, ]
head(whr2023[, c("country", "happiness_score")])
sPDF <- joinCountryData2Map(
  whr2023,
  joinCode = "NAME",         
  nameJoinColumn = "country"  
)
par(mai = c(0,0,0.2,0.4)) 
mapCountryData(
  sPDF_2023,
  nameColumnToPlot = "happiness_score",
  mapTitle = "Happiness / Ladder Score Map 2023",
  colourPalette = "heat",   
  catMethod = "pretty"     
)

library(dplyr)

region_stats <- df_clean %>%
  filter(year == 2023) %>%
  group_by(region) %>%
  summarise(
    mean_happy = mean(happiness_score, na.rm = TRUE),
    sd_happy   = sd(happiness_score,   na.rm = TRUE),
    n          = n(),
    se_happy   = sd_happy / sqrt(n)   
  ) %>%
  arrange(desc(mean_happy))

ggplot(region_stats, aes(x = reorder(region, mean_happy), y = mean_happy)) +
  geom_col(fill = "orange") +
  geom_errorbar(aes(ymin = mean_happy - se_happy,
                    ymax = mean_happy + se_happy),
                width = 0.2) +
  coord_flip() +
  labs(
    title = "Happiness Score for Different Regions (2023)",
    x = "Region",
    y = "Average Happiness Score"
  ) +
  theme_minimal(base_size = 14)


#Draw Happiness Vs 6 independent factors
vars <- c(
  "gdp_per_capita",
  "social_support",
  "healthy_life_expectancy",
  "freedom_to_make_life_choices",
  "generosity",
  "perceptions_of_corruption"
)

var_labels <- c(
  "GDP per Capita",
  "Social Support",
  "Healthy Life Expectancy",
  "Freedom to Make Life Choices",
  "Generosity",
  "Perceptions of Corruption"
)
par(mfrow = c(2, 3))
for (i in seq_along(vars)) {
  y <- train[[vars[i]]]
  
  plot(
    train$happiness_score, y,
    xlab = "Happiness Score (Train 2015–2022)",
    ylab = var_labels[i],
    pch  = 19,
    col  = rgb(0, 0.4, 0.8, 0.6),
    main = paste("Happiness vs", var_labels[i])
  )

  abline(lm(y ~ train$happiness_score), col = "red", lwd = 2)
}
par(mfrow = c(1, 1))







