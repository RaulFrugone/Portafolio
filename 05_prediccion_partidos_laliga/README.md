# Modelado predictivo de resultados de futbol: La Liga espanola

## 1. Descripcion general

Este proyecto implementa un sistema econometrico y de aprendizaje estadistico para predecir la probabilidad de victoria en partidos de futbol profesional de La Liga espanola, utilizando una base de datos longitudinal de 4,700 encuentros oficiales.

El enfoque metodologico aborda la estructura jerarquica y de medidas repetidas inherente al deporte profesional:
1. **Modelo de referencia (Benchmark logistico):** Evaluacion del impacto de los goles esperados generados ($xG$), posesion de balon y factor localia sobre el desenlace del partido.
2. **Modelo longitudinal con efectos aleatorios:** Captura de la heterogeneidad no observada de cada club mediante efectos mixtos por equipo (`glmer`), evaluando la correlacion intraclase (ICC) y ganancia por razon de verosimilitud (LRT).
3. **Modelo predictivo pre-partido con efectos mixtos cruzados:** Diseno de variables dinamicas de rendimiento reciente (`form_xg`, `form_xga`, `form_poss`) calculadas estrictamente con rezagos historicos (`lag(cummean())`) para eliminar cualquier riesgo de fuga de datos hacia el futuro (*data leakage*), complementado con una estructura cruzada de efectos aleatorios por equipo local y rival.
4. **Simulador de partidos:** Modulo interactivo para estimar la probabilidad de victoria antes de la celebracion de cualquier encuentro.

---

## 2. Tecnologias utilizadas

* **Lenguaje:** R (version 4.0 o superior)
* **Paquetes principales:**
  * Modelado jerarquico y mixto: `lme4`
  * Manipulacion de datos: `readr`, `dplyr`, `tidyr`
  * Metricas de clasificacion y ROC: `pROC`, `caret`
  * Tablas econometricas reproducibles: `stargazer`
  * Visualizacion complementaria: `plotly`, `ggplot2`

---

## 3. Estructura de archivos del proyecto

* `prediccion_laliga.R`: Script principal ejecutable y autocontenido que realiza la limpieza, entrenamiento de los tres modelos, calculo de metricas, simulacion de encuentros y exportacion a LaTeX.
* `matches_laliga.csv`: Base de datos de partidos de La Liga que contiene estadisticas avanzadas (fecha, localia, resultado, goles a favor/contra, $xG$, $xGA$, posesion, formaciones y arbitros).
* `modelos_comparacion.tex`: Tabla comparativa en codigo LaTeX (generada con `stargazer`) que contrasta el modelo logistico tradicional frente al modelo longitudinal de efectos mixtos.
* `modelo_final_cruzado.tex`: Tabla LaTeX con los coeficientes del modelo de efectos mixtos cruzados pre-partido.
* `modelo_final_seleccion.tex`: Tabla LaTeX de especificacion final pre-partido.

---

## 4. Requisitos e instalacion

Para instalar las dependencias requeridas en R:

```r
paquetes <- c("readr", "dplyr", "lme4", "pROC", "caret", "stargazer", "tidyr")
paquetes_faltantes <- paquetes[!(paquetes %in% installed.packages()[, "Package"])]
if (length(paquetes_faltantes) > 0) {
  install.packages(paquetes_faltantes, dependencies = TRUE)
}
```

---

## 5. Instrucciones de ejecucion

Ejecute directamente el script desde la terminal o consola de R:

```bash
Rscript prediccion_laliga.R
```

O en la consola de RStudio:

```r
source("prediccion_laliga.R")
```

El script imprimira en consola los coeficientes estimados, la metrica AUC, la correlacion intraclase, la simulacion de partidos clasicos (ej: Real Madrid vs Barcelona) y regenerara la tabla `modelos_comparacion.tex`.

---

## 6. Resultados econometricos clave

* **Significancia del xG sobre la posesion:** La capacidad de generacion de ocasiones de peligro ($xG$) exhibe un impacto positivo y altamente significativo ($z > 20$, $p < 10^{-90}$), mientras que la posesion bruta muestra una asociacion negativa marginal cuando no se traduce en peligro real.
* **Ventaja de localia:** Jugar en condicion de local confiere un incremento estadisticamente solido en los odds de victoria en todos los modelos evaluados.
* **Heterogeneidad de clubes:** La inclusion de efectos aleatorios por equipo (`ICC \approx 0.09`) reduce el AIC significativamente respecto al modelo logistico simple, evidenciando que existen factores estructurales de plantilla e institucion que persisten a lo largo de las temporadas.

---

## 7. Informacion de autoria y licencia

* **Desarrollado por:** [Nombre del autor]
* **Fuente de datos:** Registros de rendimiento avanzado de partidos de futbol profesional (La Liga).
* **Licencia:** MIT License.
