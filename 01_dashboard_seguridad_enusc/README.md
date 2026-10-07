# Dashboard de seguridad ciudadana (ENUSC)

## 1. Descripcion general

Este proyecto implementa una aplicacion analitica e interactiva construida en R Shiny para el analisis espacial, descriptivo y multivariante de la Encuesta Nacional Urbana de Seguridad Ciudadana (ENUSC), administrada por el Instituto Nacional de Estadisticas (INE) de Chile.

La herramienta integra visualizacion cartografica mediante capas vectoriales (shapefiles) de las comunas y ciudades de Chile, filtros dinamicos por region, genero y tipo de delito, mineria de datos basada en reglas de asociacion (Apriori), tecnicas de agrupamiento (clustering) y generacion automatizada de reportes ejecutivos en PDF mediante RMarkdown.

---

## 2. Tecnologias utilizadas

* **Lenguaje:** R (version 4.0 o superior)
* **Entorno interactivo:** Shiny, ShinyDashboard, ShinyJS
* **Analisis espacial y cartografia:** sf (Simple Features), Leaflet
* **Manipulacion y agregacion de datos:** dplyr, tidyr, purrr, forcats, readxl
* **Visualizacion grafica:** ggplot2, plotly, treemapify, RColorBrewer
* **Mineria de datos y asociacion:** arules, arulesViz, igraph, visNetwork
* **Analisis multivariante y agrupamiento:** FactoMineR, factoextra, cluster, klaR, ExPosition
* **Reportes dinámicos:** rmarkdown, tinytex, knitr

---

## 3. Estructura de archivos del proyecto

* `Dashboard.R`: Script principal autocontenido que define la interfaz de usuario (UI), el servidor (Server) y la logica reactiva de la aplicacion Shiny.
* `Datos_ENUSC.xlsx`: Base de datos anonimizada y depurada proveniente de la encuesta ENUSC oficial.
* `ciudades/`: Directorio que contiene los archivos de cartografia vectorial (`Ciudades_2017.shp`, `.shx`, `.dbf`, `.prj`, `.cpg`, `.sbn`, `.sbx`) para la representacion geografica en Leaflet.
* `reporte.Rmd`: Plantilla reproducible para la generacion automatizada de informes tecnicos y ejecutivos con parametros reactivos.
* `Informe_Dashboard_Seguridad.pdf`: Documento de referencia con el analisis metodologico y resultados de la aplicacion.
* `Instrucciones de uso.txt`: Guia complementaria sobre el despliegue del aplicativo.

---

## 4. Requisitos e instalacion

Para ejecutar este proyecto en un entorno local, clone el repositorio y ejecute en la consola de R el siguiente bloque para asegurar que todas las dependencias requeridas esten instaladas:

```r
paquetes <- c(
  "readxl", "shiny", "leaflet", "dplyr", "RColorBrewer", 
  "sf", "shinydashboard", "stringr", "plotly", "shinyjs", 
  "tidyr", "ggplot2", "treemapify", "arules", "arulesViz", 
  "igraph", "visNetwork", "forcats", "rmarkdown", "tinytex", 
  "FactoMineR", "factoextra", "klaR", "purrr", "DescTools", 
  "DT", "cluster"
)

paquetes_faltantes <- paquetes[!(paquetes %in% installed.packages()[, "Package"])]
if (length(paquetes_faltantes) > 0) {
  install.packages(paquetes_faltantes, dependencies = TRUE)
}
```

---

## 5. Instrucciones de ejecucion

1. Abra una sesion de R o RStudio.
2. Establezca el directorio de trabajo en la carpeta del proyecto o abra directamente el archivo `Dashboard.R`.
3. Inicie la aplicacion ejecutando:

```r
shiny::runApp("Dashboard.R")
```

4. La aplicacion se desplegara automaticamente en su navegador web predeterminado o en el visor interno de RStudio.

---

## 6. Funcionalidades analiticas principales

* **Modulo geoespacial:** Visualizacion interactiva con Leaflet de la percepcion de inseguridad y prevalencia delictual sobre la division politica y urbana de Chile.
* **Filtros cruzados reactivos:** Segmentacion instantanea por region, tramo etario, genero y nivel socioeconomico.
* **Analisis de canasta de delitos:** Algoritmos de reglas de asociacion para identificar patrones simultaneos de victimizacion.
* **Generacion de informes:** Descarga de reportes ejecutivos en PDF filtrados segun la seleccion actual del usuario.

---

## 7. Informacion de autoria y licencia

* **Desarrollado por:** [Nombre del autor]
* **Origen de los datos:** Instituto Nacional de Estadisticas (INE), Gobierno de Chile (Datos publicos abiertos).
* **Licencia:** MIT License.
