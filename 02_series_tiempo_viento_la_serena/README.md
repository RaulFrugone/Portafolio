# Pronostico y modelado de series de tiempo meteorologicas

## 1. Descripcion general

Este proyecto desarrolla un estudio cuantitativo y predictivo sobre la dinamica de la velocidad del viento en la estacion meteorologica La Florida (La Serena, Chile - Codigo DMC 290004), administrada por la Direccion Meteorologica de Chile.

El flujo metodologico abarca el analisis exploratorio de datos de alta frecuencia, tratamiento e imputacion de valores faltantes mediante tecnicas estadisticas, y la comparacion de modelos clasicos autoregresivos (ARIMA, SARIMA con covariables meteorologicas) frente a arquitecturas de aprendizaje profundo secuencial, especificamente redes convolucionales temporales (Temporal Convolutional Networks - TCN).

---

## 2. Tecnologias utilizadas

* **Lenguajes:** Python (3.9+) y R (4.0+)
* **Bibliotecas de Python:**
  * Manipulacion de datos: `pandas`, `numpy`, `openpyxl`
  * Modelado estadistico y series de tiempo: `statsmodels`, `pmdarima`
  * Aprendizaje automatico y profundo: `scikit-learn`, `tensorflow` / `keras` (para arquitectura TCN), `joblib`
  * Visualizacion grafica: `matplotlib`, `seaborn`
* **Paquetes de R:**
  * Imputacion y manipulacion: `readxl`, `dplyr`, `imputeTS`, `tidyr`, `lubridate`

---

## 3. Estructura de archivos del proyecto

* `EDA_Estacion_290004.ipynb`: Cuaderno Jupyter que contiene el analisis exploratorio de datos (EDA), perfiles estacionales diarios y mensuales, y deteccion de anomalías de la estacion 290004.
* `Inputacion de datos faltantes.R`: Script en R para la reconstruccion e interpolacion robusta de vacios temporales en series climaticas.
* `Prediccion_de_covariables.ipynb`: Cuaderno para la proyeccion preliminar de variables auxiliares (temperatura, presion atmosferica, humedad).
* `ARIMA-SARIMA_viento.ipynb`: Cuaderno de ajuste, validacion de supuestos sobre residuos (Ljung-Box, normalidad) y pronostico fuera de muestra mediante modelos SARIMAX.
* `TCN_Velocidad_del_viento.ipynb`: Implementacion de la red convolucional temporal (TCN) con convoluciones causales dilatadas para modelado no lineal de largo alcance.
* `datos_290004.xlsx`: Base de datos cruda consolidada de la estacion meteorologica.
* `Datos_290004_con_predicciones_covariables_filtrado_2024.xlsx`: Conjunto depurado y listo para entrenamiento y validacion de modelos.
* `Informe Velocidad del viento en La Serena Chile.pdf`: Informe cientifico y metodologico completo con formulacion matematica y discusion de resultados.
* `Poster Velocidad del viento en La Serena.pdf`: Poster academico en formato cientifico que sintetiza la investigacion.

---

## 4. Requisitos e instalacion

Se recomienda crear un entorno virtual de Python para reproducir los cuadernos:

```bash
python -m venv venv
# En Windows:
venv\Scripts\activate
# En Linux/macOS:
source venv/bin/activate

pip install pandas numpy openpyxl matplotlib seaborn scikit-learn statsmodels pmdarima tensorflow joblib
```

---

## 5. Instrucciones de ejecucion

1. **Revision del analisis exploratorio:**
   Abra y ejecute `EDA_Estacion_290004.ipynb` para inspeccionar la descomposicion estacional y estacionariedad (test Dickey-Fuller aumentado).
2. **Modelado estadistico clasico:**
   Ejecute `ARIMA-SARIMA_viento.ipynb` para entrenar el modelo SARIMAX, visualizar la funcion de autocorrelacion (ACF/PACF) y generar el horizonte de pronostico de 720 horas.
3. **Modelado con redes convolucionales (TCN):**
   Ejecute `TCN_Velocidad_del_viento.ipynb` para el entrenamiento de la arquitectura profunda, ajuste de hiperparametros y comparacion de metricas de desempeno (MAE, RMSE, MAPE).

---

## 6. Resultados y conclusiones destacadas

* Se evidencia un patron circadiano marcado en la bahia de Coquimbo/La Serena, gobernado por la brisa marina valle-costa.
* La incorporacion de variables exogenas (gradientes de presion y temperatura) mejora la capacidad predictiva respecto a modelos univariados puros.
* La arquitectura TCN ofrece ventajas en la captura de picos no lineales extremos de velocidad de viento con tiempos de inferencia altamente competitivos.

---

## 7. Informacion de autoria y licencia

* **Desarrollado por:** [Nombre del autor]
* **Fuente de datos:** Direccion Meteorologica de Chile (DMC) - Registro publico de datos climatologicos.
* **Licencia:** MIT License.
