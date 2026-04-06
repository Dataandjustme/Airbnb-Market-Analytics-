#Importar datos 
import pandas as pd 
import numpy as np 

df = pd.read_csv("listing_final.csv")

#Entender la estructura de los datos
print(df.head())
print(df.info())

#EDA

#Univariate

import matplotlib.pyplot as plt
import seaborn as sns

# --- Distribución de occupancy_rate segmentada por room_type ---
plt.figure(figsize=(10,6))
sns.histplot(data=df, x="occupancy_rate", hue="room_type", bins=30, kde=False, multiple="stack")
plt.title("Distribución de occupancy_rate por tipo de habitación")
plt.xlabel("Occupancy Rate")
plt.ylabel("Frecuencia")
plt.show()

# --- Distribución de review_scores_rating segmentada por superhost ---
plt.figure(figsize=(10,6))
sns.histplot(data=df[df["review_scores_rating"].notnull()],
             x="review_scores_rating", hue="host_is_superhost", bins=20, kde=False, multiple="stack")
plt.title("Distribución de ratings por superhost")
plt.xlabel("Review Scores Rating")
plt.ylabel("Frecuencia")
plt.show()

# --- Boxplot para ver diferencias más claras ---
plt.figure(figsize=(10,6))
sns.boxplot(data=df, x="room_type", y="occupancy_rate")
plt.title("Boxplot de occupancy_rate por tipo de habitación")
plt.show()

# --- La mayoría de los listings exhiben altos niveles de reseñas, lo que sugiere que las reseñas funcionan más como un indicador confiable de calidad que como un factor diferenciador entre propiedades.

# --- Correlaciones 

corr_matrix = df.corr(numeric_only=True)
corr_with_occupancy = corr_matrix['occupancy_rate'].sort_values(ascending=False)

print("Correlaciones con occupancy_rate:")
print(corr_with_occupancy)


# --- La correlación lineal muestra relaciones débiles entre la tasa de ocupación y las variables numéricas individuales, lo que sugiere que la ocupación está determinada principalmente por interacciones no lineales y factores categóricos como la localidad y el tipo de propiedad.

from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.metrics import r2_score, mean_squared_error
from sklearn.metrics import mean_squared_error

# Limpiar NaN con la media
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.metrics import r2_score, mean_squared_error
import numpy as np
import matplotlib.pyplot as plt

# --- Preparación de datos ---
df_filled = df[['accommodates', 'number_of_reviews', 'review_scores_rating', 'occupancy_rate']].fillna(df.mean(numeric_only=True))

X = df_filled[['accommodates', 'number_of_reviews', 'review_scores_rating']]
y = df_filled['occupancy_rate']

# --- Split ---
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# --- Modelo ---
model = LinearRegression()
model.fit(X_train, y_train)

# --- Resultados ---
print("Coeficientes:", model.coef_)
print("Intercepto:", model.intercept_)

y_pred = model.predict(X_test)

# Métricas
r2 = r2_score(y_test, y_pred)
rmse = np.sqrt(mean_squared_error(y_test, y_pred))
print("R²:", r2)
print("RMSE:", rmse)

# --- Gráfico simple ---
plt.scatter(y_test, y_pred, alpha=0.5)
plt.xlabel("Valores reales (y_test)")
plt.ylabel("Predicciones (y_pred)")
plt.title("Predicciones vs Valores reales")
plt.show()

# --- Conclusión 

"""El modelo de regresión lineal mostró un bajo poder explicativo (R² ≈ 0.01), 
lo que confirma que la tasa de ocupación no está determinada por relaciones lineales con variables numéricas, 
sino principalmente por factores categóricos y interacciones complejas """

df.to_csv("listing_final_clean.csv", index=False)
