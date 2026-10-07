# Mineria de datos y aprendizaje automatico ambiental: Lago Caburgua

## 1. Descripcion general

Este proyecto aplica tecnicas avanzadas de mineria de datos, ingenieria de caracteristicas y aprendizaje supervisado para modelar el comportamiento hidrologico y la variacion del nivel de agua del Lago Caburgua (Region de La Araucania, Chile).

La investigacion analiza el impacto de la variabilidad climatica (precipitaciones, temperatura, escorrentia) y evalua el efecto de intervenciones antropicas e hidraulicas (como el dique del rio Trafampulli) sobre el espejo de agua lacustre a lo largo de series temporales multidecadales.

---

## 2. Tecnologias utilizadas

* **Lenguaje:** Python (version 3.9 o superior)
* **Bibliotecas principales:**
  * Analisis de datos: `pandas`, `numpy`, `openpyxl`
  * Visualizacion cientifica: `matplotlib`, `seaborn`
  * Aprendizaje automatico: `scikit-learn`, `xgboost`, `lightgbm`
  * Modelado secuencial y redes neuronales: `tensorflow` / `keras` (modelos LSTM para memoria temporal)
  * Entorno interactivo: `jupyter`, `ipykernel`

---

## 3. Estructura de archivos del proyecto

* `Lago_Caburgua.ipynb`: Cuaderno principal que implementa el preprocesamiento, analisis multivariante, correlaciones rezagadas, ingenieria de covariables y ajuste de modelos predictivos bajo diferentes escenarios (con y sin reinstalacion de dique).
* `Predicciones_Covariables_Lago_Caburgua.ipynb`: Cuaderno de apoyo metodologico para la estimacion y proyeccion de series hidroclimaticas auxiliares.
* `Base_Lago_Caburgua.xlsx`: Archivo de datos limpios estructurado en hojas diferenciadas por escenario de modelacion (`LSTM_Sin Reinstalacion Dique`, `LSTM_Con Reinstalacion Dique`).
* `Datos_Lagos.xlsx`: Base de datos regional complementaria que recopila registros meteorologicos y limnologicos de referencia.

---

## 4. Requisitos e instalacion

Para instalar el entorno de trabajo en Python:

```bash
pip install pandas numpy openpyxl matplotlib seaborn scikit-learn xgboost tensorflow jupyter
```

---

## 5. Instrucciones de ejecucion

1. Abra una terminal o entorno de desarrollo (Jupyter Lab, VS Code o Jupyter Notebook):

```bash
jupyter notebook Lago_Caburgua.ipynb
```

2. Ejecute las celdas secuencialmente para:
   * Cargar las hojas de trabajo desde `Base_Lago_Caburgua.xlsx`.
   * Realizar el escalado de variables continuas y construccion de tensores con ventanas temporales rezagadas.
   * Entrenar los modelos predictivos y visualizar las curvas de perdida (Train vs Validation Loss).
   * Evaluar las metricas de desempeno en prueba (MAE, RMSE, R2).

---

## 6. Aportes analiticos principales

* **Modelado de escenarios contrafactuales:** Comparacion cuantitativa de la trayectoria del nivel lacustre ante la presencia o ausencia de caudal aportante desviado.
* **Captura de no linealidades hidrologicas:** Uso de arquitecturas recurrentes (LSTM) para modelar la inercia termica y de almacenamiento de la cuenca lacustre frente a sequias prolongadas.
* **Procesamiento de datos ambientales:** Metodologias rigurosas para tratar registros satelitales y estaciones meteorologicas terrestres dispersas.

---

## 7. Informacion de autoria y licencia

* **Desarrollado por:** [Nombre del autor]
* **Origen de los datos:** Registros de la Direccion General de Aguas (DGA) y Direccion Meteorologica de Chile (DMC).
* **Licencia:** MIT License.
