-- Check column names and basic stats
SELECT * FROM movies LIMIT 5;

-- Count how many movies have budget or revenue = 0
SELECT 
    COUNT(*) AS total_movies,
    SUM(CASE WHEN budget = 0 THEN 1 ELSE 0 END) AS zero_budget,
    SUM(CASE WHEN revenue = 0 THEN 1 ELSE 0 END) AS zero_revenue
FROM movies;
