import pandas as pd
import sqlite3
import matplotlib.pyplot as plt
import seaborn as sns

# DB 연결
conn = sqlite3.connect("tmdb.db")

# SQL 실행 결과 가져오기
query = """
SELECT SUBSTR(release_date, 1, 4) AS year, AVG(roi) AS avg_roi
FROM movie_clean
WHERE release_date IS NOT NULL
GROUP BY year
HAVING year >= '1980'
ORDER BY year;
"""
df = pd.read_sql(query, conn)

# 연도 숫자 변환
df['year'] = df['year'].astype(int)

# 시각화
plt.figure(figsize=(10,5))
sns.lineplot(data=df, x='year', y='avg_roi', marker='o')
plt.title("📈 연도별 평균 ROI 추이")
plt.xlabel("Year")
plt.ylabel("Average ROI")
plt.grid(True)
plt.tight_layout()
plt.show()
