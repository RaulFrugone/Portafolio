# Diseno de experimentos y analisis de covarianza (ANCOVA)

## 1. Descripcion general

Este proyecto implementa tecnicas de Diseno de Experimentos (DOE) y Analisis de Covarianza (ANCOVA) para evaluar el efecto de tratamientos factoriales controlando simultaneamente por el efecto de una o mas variables continuas concomitantes (covariables).

El proposito fundamental del ANCOVA es reducir la varianza del error experimental y ajustar las medias de los tratamientos segun las diferencias iniciales en la covariable, incrementando sustancialmente la potencia estadistica de las pruebas de hipotesis (F-tests).

---

## 2. Tecnologias utilizadas

* **Lenguaje:** R (version 4.0 o superior)
* **Paquetes principales:**
  * Modelado lineal y diagnostico: `car`, `lmtest`, `broom`, `tibble`, `dplyr`
  * Tablas tecnicas y formatos: `knitr`, `kableExtra`
  * Visualizacion grafica: `ggplot2`
  * Reportes reproducibles: `rmarkdown`, `rmdformats`

---

## 3. Estructura de archivos del proyecto

* `Ejercicio resuelto.Rmd`: Cuaderno analitico reproducible que contiene la formulacion del problema, ajuste del modelo ANCOVA, contrastes de hipotesis y verificacion exhaustiva de supuestos.
* `Ejercicio-resuelto.html`: Documento compilado en formato HTML interactivo bajo plantilla moderna `rmdformats::material`.
* `Informe_ANCOVA.Rmd`: Informe tecnico formal en RMarkdown con redaccion cientifica y conclusiones.
* `Informe_ANCOVA.pdf`: Documento compilado en formato PDF para lectura ejecutiva y academica.
* `Presentacion_ANCOVA.pdf`: Diapositivas de exposicion con la sintesis visual de los hallazgos.
* `styles.css`: Hoja de estilos complementaria para la presentacion web.

---

## 4. Requisitos e instalacion

Instale los paquetes necesarios en R ejecutando:

```r
paquetes <- c("dplyr", "knitr", "kableExtra", "broom", "car", "lmtest", "ggplot2", "tibble", "rmarkdown", "rmdformats")
paquetes_faltantes <- paquetes[!(paquetes %in% installed.packages()[, "Package"])]
if (length(paquetes_faltantes) > 0) {
  install.packages(paquetes_faltantes, dependencies = TRUE)
}
```

---

## 5. Instrucciones de ejecucion

Para compilar el cuaderno y regenerar las salidas reproducibles:

```r
rmarkdown::render("Ejercicio resuelto.Rmd")
```

O para compilar el informe en PDF:

```r
rmarkdown::render("Informe_ANCOVA.Rmd", output_format = "pdf_document")
```

---

## 6. Supuestos y diagnosticos evaluados

El flujo de analisis valida formalmente los supuestos criticos del ANCOVA:
1. **Homogeneidad de pendientes de regresion:** Test de interaccion tratamiento $\times$ covariable ($F$-test) para asegurar que la relacion entre la covariable y la respuesta es constante entre grupos.
2. **Normalidad de residuos:** Test de Shapiro-Wilk y graficos Q-Q normativos.
3. **Homocedasticidad:** Test de Breusch-Pagan para constancia de varianza del error.
4. **Independencia:** Test de Durbin-Watson para ausencia de autocorrelacion serial.
5. **Especificacion funcional:** Test Ramsey RESET para validar la linealidad del modelo.
6. **Medias ajustadas:** Estimacion de medias marginales ajustadas por la covariable mediante contrastes post-hoc.

---

## 7. Informacion de autoria y licencia

* **Desarrollado por:** [Nombre del autor]
* **Metodologia de referencia:** Montgomery, D. C. *Design and Analysis of Experiments*. John Wiley & Sons.
* **Licencia:** MIT License.
