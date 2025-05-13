import sqlite3
import pandas as pd

# 데이터 불러오기
df = pd.read_csv("data/tmdb_5000_movies.csv")

# DB 연결
conn = sqlite3.connect("tmdb.db")
df.to_sql("movies", conn, if_exists="replace", index=False)

# 커서 생성
cursor = conn.cursor()

# SQL 실행 함수
def run_sql_file(file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        sql = f.read()
    queries = [q.strip() for q in sql.split(";") if q.strip()]
    for q in queries:
        print(f"\n📄 Running query:\n{q}")
        if q.lower().startswith("select"):
            result = pd.read_sql_query(q, conn)
            print(result.head())
        else:
            cursor.execute(q)
            print("✅ Query executed (no result)")

# 실행
run_sql_file("SQL/01_explore_schema.sql")
run_sql_file("SQL/02_budget_revenue_cleaning.sql")
run_sql_file("SQL/03_ROI_trend_year.sql")


# 커밋 및 종료
conn.commit()
conn.close()
