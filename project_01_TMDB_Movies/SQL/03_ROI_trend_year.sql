SELECT SUBSTR(release_date, 1, 4) AS year, AVG(roi) AS avg_roi
FROM movie_clean
WHERE release_date IS NOT NULL
GROUP BY year
ORDER BY year;
