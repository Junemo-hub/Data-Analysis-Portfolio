1. EDA 기본 체크리스트

초기선언 
import pandas as pd
df = pd.read_csv("../data/boston.csv")  # 파일 경로 확인 필수

# 1. 구조 파악
df.shape
df.info()
df.head()

# 2. 결측치
df.isnull().sum()

# 3. 기초 통계
df.describe()

# 4. 범주형 분석
df['지역'].value_counts()

# 5. 시각화
초기선언
import seaborn as sns
import matplotlib.pyplot as plt  # 함께 쓰는 게 좋음

sns.histplot(df['CRIM'])
plt.show()  # 그래프 보여주기

sns.scatterplot(x='면적', y='가격', data=df)

# 6. 상관관계
sns.heatmap(df.corr(), annot=True)



2. 전처리

🔧 전처리는 꼭 결측치 처리만이 아니다!
EDA에서 결측치가 없더라도, 모델링을 위해 아래와 같은 전처리가 필요할 수 있습니다:

전처리 종류	예시	Boston Housing 예시
❌ 결측치 처리	.dropna(), fillna()	없음 → 스킵 가능
🧹 이상치 제거	Z-score, IQR 필터링	CRIM, TAX, LSTAT 이상치 가능
🧩 파생 변수 생성   	비율, 로그, 조합 등	log(CRIM), LSTAT ** 2 등
🔄 스케일링	정규화 / 표준화	StandardScaler 사용 (중요!)
🔣 인코딩	범주형 → 숫자	CHAS는 이미 0/1로 되어 있어 OK

차트 종류	보는 포인트
📊 히스토그램	분포가 치우쳐 있는가? (왜도, skewed)
📦 박스플롯	이상치가 많은가? (동그라미: IQR 바깥의 값들)
📐 x축 범위	스케일 차이가 큰가? → 스케일링 대상 가능





