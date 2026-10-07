# Inferencia causal y emparejamiento por propension (matching)

## 1. Descripcion general

Este proyecto aborda la estimacion del efecto causal de un programa de capacitacion laboral sobre los ingresos posteriores de los participantes, utilizando el dataset clasico cuasi-experimental de Lalonde (1986).

En estudios observacionales, la asignacion del tratamiento no es aleatoria, lo que genera sesgo de seleccion por variables confusoras. En este repositorio se implementan y comparan rigurosamente tecnicas modernas de inferencia causal:
1. Regresion descriptiva y diferencia simple de medias (estimacion sesgada de referencia).
2. Modelo de probabilidad de tratamiento (Propensity Score) mediante regresion logistica.
3. Emparejamiento por vecino mas cercano (Nearest Neighbor Matching) con tolerancia de soporte comun (caliper).
4. Evaluacion grafica y numerica del balance de covariables (Love plot y distribucion de propension).
5. Estimador doblemente robusto (Double Robust Estimator).
6. Ponderacion por probabilidad inversa de tratamiento (Inverse Probability Weighting - IPW).

---

## 2. Tecnologias utilizadas

* **Lenguaje:** R (version 4.0 o superior)
* **Paquetes principales:**
  * Inferencia causal y matching: `MatchIt`, `cobalt`
  * Ponderacion y muestreo complejo: `survey`
  * Manipulacion de datos: `dplyr`
  * Visualizacion grafica: `ggplot2`, `grid`
  * Reportes reproducibles: `rmarkdown`, `knitr`

---

## 3. Estructura de archivos del proyecto

* `codigo.R`: Script ejecutable completo y autocontenido que ajusta todos los modelos, calcula metricas causales, genera tablas comparativas y exporta graficos diagnosticos.
* `lalonde.csv`: Conjunto de datos observacional que incluye covariables socioeconomicas (`age`, `educ`, `race`, `married`, `nodegree`, `re74`, `re75`) y la variable de resultado (`re78`).
* `love_plot.png`: Grafico de diagnostico de balance que compara las diferencias de medias estandarizadas antes y despues del emparejamiento.
* `propensity_overlap.png`: Grafico de densidad que valida la condicion de soporte comun y solapamiento del propensity score entre tratados y controles.
* `informe_escrito.Rmd`: Documento tecnico en RMarkdown que detalla la fundamentacion teorica, supuestos de identificacion causal (ignorabilidad y positividad) e interpretacion economica.
* `informe_escrito.pdf`: Informe compilado en formato PDF listo para lectura.

---

## 4. Requisitos e instalacion

Para instalar los paquetes necesarios en R, ejecute:

```r
paquetes <- c("MatchIt", "cobalt", "survey", "ggplot2", "dplyr", "rmarkdown", "knitr")
paquetes_faltantes <- paquetes[!(paquetes %in% installed.packages()[, "Package"])]
if (length(paquetes_faltantes) > 0) {
  install.packages(paquetes_faltantes, dependencies = TRUE)
}
```

---

## 5. Instrucciones de ejecucion

Ejecute directamente el script desde la linea de comandos o consola de R:

```bash
Rscript codigo.R
```

O en la consola de R:

```r
source("codigo.R")
```

El script ejecutara el analisis completo y generara la tabla resumen de efectos promedio sobre los tratados (ATT) directamente en la consola, actualizando los graficos diagnosticos `propensity_overlap.png` y `love_plot.png`.

---

## 6. Resultados comparativos de estimacion

| Metodologia | Estimacion del efecto | Error estandar | p-valor | Interpretacion causal |
| :--- | :--- | :--- | :--- | :--- |
| **Diferencia simple** | -$635 | $657.1 | 0.334 | Altamente sesgado por autoseleccion negativa |
| **Regresion OLS con controles** | $1,548 | $781.3 | 0.048 | Controla linealmente pero asume forma funcional estricta |
| **PSM Vecino mas cercano (ATT)** | $2,278 | $994.0 | 0.022 | Causal, balancea covariables y recupera efecto positivo significativo |
| **PSM Doble robusto (ATT)** | $2,229 | $992.7 | 0.025 | Causal, consistente si el modelo de propension o el de regresion es correcto |
| **IPW (ATT)** | $1,214 | $824.7 | 0.141 | Ponderacion por pesos normalizados |

---

## 7. Informacion de autoria y licencia

* **Desarrollado por:** [Nombre del autor]
* **Conjunto de datos:** Lalonde, R. J. (1986). Evaluating the econometric evaluations of training programs with experimental data. *American Economic Review*, 76(4), 604-620.
* **Licencia:** MIT License.
