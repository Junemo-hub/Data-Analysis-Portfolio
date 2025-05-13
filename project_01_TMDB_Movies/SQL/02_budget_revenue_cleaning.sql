DROP TABLE IF EXISTS movie_clean;
-- Create clean subset where budget and revenue are valid
CREATE TABLE movie_clean AS
SELECT
    id,
    title,
    budget,
    revenue,
    release_date,
    genres,
    CASE WHEN budget > 0 THEN (revenue * 1.0 / budget) ELSE NULL END AS roi
FROM movies
WHERE budget > 0 AND revenue > 0;
