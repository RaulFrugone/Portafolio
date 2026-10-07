# Control estadistico de calidad y procesos (SPC)

## 1. Descripcion general

Este proyecto implementa el conjunto fundamental de tecnicas de Control Estadistico de Procesos (Statistical Process Control - SPC) para la monitorizacion, aseguramiento de la calidad y reduccion de la variabilidad en lineas de manufactura y servicios.

El repositorio incluye dos enfoques complementarios:
1. **Implementacion algoritmica desde principios fundamentales:** Funciones matematicas puras en R que calculan constantes de control de Shewhart ($A_2, d_2, D_3, D_4$) sin depender de librerias de caja negra, permitiendo un entendimiento cabal del calculo de limites de control (UCL, LCL, Center Line).
2. **Implementacion industrial con `qcc`:** Graficos de control por variables ($\bar{X}-R, \bar{X}-S$), observaciones individuales ($I-MR$), cartas por atributos ($p, np, c, u$) y cartas de sumas acumuladas (CUSUM) para detectar pequenos desplazamientos en la media o variabilidad.

---

## 2. Tecnologias utilizadas

* **Lenguaje:** R (version 4.0 o superior)
* **Paquetes principales:**
  * Control de calidad: `qcc`
  * Visualizacion grafica: `ggplot2`
  * Compilacion reproducible: `rmarkdown`, `knitr`

---

## 3. Estructura de archivos del proyecto

* `Codigo Cartas de Control.R`: Implementacion propia desde cero de las formulas analiticas de cartas de control Shewhart, tablas de factores y graficacion vectorial en base R.
* `QCC.R`: Script de aplicacion profesional con la libreria especializada `qcc`, integrando cartas de variables, atributos y CUSUM.
* `Cartas Completo.Rmd`: Cuaderno reproducible en RMarkdown que analiza casos practicos industriales, evaluacion de causas asignables y reglas de decision Western Electric.
* `Reporte_Cartas_Control.html`: Reporte compilado en formato HTML interactivo.
* `defects.csv`: Dataset industrial de ejemplo para analisis de defectos por lote.

---

## 4. Requisitos e instalacion

Instale los paquetes necesarios en R:

```r
paquetes <- c("qcc", "ggplot2", "rmarkdown", "knitr")
paquetes_faltantes <- paquetes[!(paquetes %in% installed.packages()[, "Package"])]
if (length(paquetes_faltantes) > 0) {
  install.packages(paquetes_faltantes, dependencies = TRUE)
}
```

---

## 5. Instrucciones de ejecucion

1. **Ejecucion de la implementacion matematica base:**
   Ejecute en consola de R:

```r
source("Codigo Cartas de Control.R")
```

2. **Ejecucion del pipeline industrial con `qcc`:**

```bash
Rscript QCC.R
```

3. **Generacion del reporte completo en HTML:**

```r
rmarkdown::render("Cartas Completo.Rmd")
```

---

## 6. Metodologia y conceptos abordados

* **Cartas por variables:** Monitorizacion de tendencia central ($\bar{X}$) y dispersion ($R$ o $S$) en subgrupos racionales.
* **Cartas por atributos:** Control de unidades no conformes (cartas $p$ y $np$) y conteo de no conformidades por unidad (cartas $c$ y $u$).
* **Indices de capacidad de proceso:** Calculo de $C_p$, $C_{pk}$, $C_{pm}$ y proporcion de partes por millon fuera de especificacion (PPM).
* **Cartas de memoria CUSUM:** Deteccion precoz de desplazamientos sutiles ($\le 1.5\sigma$) frente a las cartas tradicionales de memoria nula.

---

## 7. Informacion de autoria y licencia

* **Desarrollado por:** [Nombre del autor]
* **Metodologia de referencia:** Montgomery, D. C. *Introduction to Statistical Quality Control*. John Wiley & Sons.
* **Licencia:** MIT License.
