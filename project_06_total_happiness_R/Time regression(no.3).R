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





