#  ROI Trend by Year - Summary

## Analysis Overview
This analysis focuses on the year-over-year trend of ROI (Return on Investment) for movies.

- Source: `movie_clean` table (filtered to remove rows with 0 budget or revenue)
- ROI is calculated as: `revenue / budget`

## Key Findings
- ROI was relatively high in the early 2000s, but gradually declined in recent years.
- Several outlier years show extremely high ROI, likely due to a small number of high-profit films.
- Further investigation into genres or production types may explain these trends.

## Next Steps
- Analyze ROI trends by genre across time
- Compare ROI by production company
- Identify high-ROI movies and their common traits

```
project/
├── data/ # Original dataset
│ └── tmdb_5000_movies.csv
│
├── outputs/ # Cleaned data and visualizations
│ └── movie_clean.csv
│
├── SQL/ # SQL scripts
│ ├── 01_explore_schema.sql # Inspect nulls, zeros, structure
│ ├── 02_budget_revenue_cleaning.sql # Remove 0s and calculate ROI
│ └── 03_ROI_trend_year.sql # Yearly ROI average
│
├── R/ # (Optional) R analysis scripts
│ ├── 01_roi_analysis.py # ROI histogram and scatter plot
│ └── 02_roi_year_analysis.py # Year-wise ROI line chart
│
├── run_sql.py # Python script to execute SQL files
├── tmdb.db # SQLite database file
└── README.md # Project summary
```
