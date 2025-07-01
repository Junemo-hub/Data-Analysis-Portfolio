import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd

df = pd.read_csv("outputs/movie_clean.csv")

# 로그 스케일 (0보다 큰 값만)
df_filtered = df[df['roi'] > 0]
df_filtered['log_roi'] = np.log10(df_filtered['roi'])

sns.histplot(df_filtered['log_roi'], bins=50)
plt.title("Log-Scaled ROI Distribution")
plt.xlabel("Log10(ROI)")
plt.ylabel("Count")
plt.show()
