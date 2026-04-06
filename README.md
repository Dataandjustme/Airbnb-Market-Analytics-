Análisis del Mercado de Airbnb 
Descripción del Proyecto
Este proyecto analiza datos de Airbnb para comprender el rendimiento del mercado, la distribución de la demanda y los factores clave que influyen en la ocupación. El objetivo es generar insights accionables que ayuden a optimizar el desempeño de los listings.

Objetivos
•	Analizar patrones de ocupación
•	Identificar zonas de alta demanda (análisis geográfico)
•	Evaluar drivers de ocupación
•	Proponer recomendaciones de negocio basadas en datos

Herramientas y Tecnologías
•	SQL (PostgreSQL) → Limpieza y transformación de datos
•	Python (Pandas, análisis básico) → Exploración y validación
•	Tableau → Visualización y storytelling

 Dataset
El análisis se basa en tres datasets principales:
•	listings.csv → Información de propiedades y hosts
•	calendar.csv → Disponibilidad y ocupación
•	reviews.csv → Opiniones de usuarios




Procesamiento de Datos (SQL)
Se construyó un pipeline estructurado:
1.	Limpieza del calendario
o	Conversión de disponibilidad a variable binaria
o	Creación de occupied_flag
2.	Feature Engineering
o	Cálculo de occupancy rate
o	Agregación por listing:
	total_days
	total_occupied_days
	occupancy_rate
3.	Dataset final
o	Integración de métricas con atributos del listing

Análisis en Python
•	Análisis exploratorio (EDA)
•	Distribuciones
•	Correlaciones
•	Modelo de regresión simple
Hallazgo clave:
•	Bajo poder predictivo (R² ≈ 0.01)
 La ocupación depende más de factores categóricos y no lineales.

Dashboards en Tableau
1. Executive Dashboard
•	KPIs:
o	Tasa de ocupación promedio
o	Total de listings
o	Rating promedio

2. Geo Dashboard 
•	Mapa con latitud y longitud
•	Segmentación por volumen de reseñas
•	Identificación de zonas con alta demanda

 Storytelling (Tableau Story)
Story 1 — Contexto del mercado
•	Panorama general y KPIs
Story 2 — Distribución de la demanda
•	La demanda se concentra en zonas específicas
Story 3 — Insights clave
•	Las private rooms dominan la ocupación
•	La ubicación es crítica
•	El rating influye, pero con límites
•	Superhost no impacta significativamente
Story 4 — Recomendaciones
•	Enfocarse en propiedades de alta demanda
•	Priorizar ubicación sobre rating extremo
•	Optimizar precio y disponibilidad
•	Detectar oportunidades ocultas

 Insights Principales
•	Las private rooms tienen mayor ocupación
•	La demanda está concentrada geográficamente
•	El rating tiene impacto limitado
•	Superhost no es un factor decisivo

 Recomendaciones de Negocio
•	Invertir en ubicación y tipo de propiedad
•	Evitar sobreoptimizar el rating
•	Optimizar pricing y disponibilidad
•	Detectar listings subutilizados en zonas fuertes
Conclusión
Este proyecto demuestra un flujo completo de análisis:
•	Extracción y transformación de datos (SQL)
•	Análisis y validación (Python)
•	Storytelling y visualización (Tableau)
 Mostrando cómo los datos pueden impulsar decisiones estratégicas en mercados competitivos.

Autor
Joan Garcia
