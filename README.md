# Portafolio de proyectos en ciencia de datos y estadistica aplicada

Bienvenido al repositorio de proyectos profesionales y academicos en ciencia de datos, estadistica computacional, aprendizaje automatico y econometria.

Este portafolio recopila desarrollos analiticos reproducibles, basados exclusivamente en datos publicos abiertos, estudios cuasi-experimentales y conjuntos de datos academicos, preservando estrictamente la confidencialidad y la gobernanza de datos privados.

---

## Indice de proyectos

| Identificador | Titulo del proyecto | Area de especialidad | Tecnologias clave | Estado de validacion |
| :--- | :--- | :--- | :--- | :--- |
| **01** | [Dashboard de seguridad ciudadana (ENUSC)](01_dashboard_seguridad_enusc/) | Inteligencia de negocios y analitica espacial | R Shiny, Leaflet, sf, RMarkdown | Validado y funcional |
| **02** | [Pronostico y series de tiempo meteorologicas](02_series_tiempo_viento_la_serena/) | Modelado predictivo de series de tiempo | Python, R, SARIMAX, TCN, TensorFlow | Validado y funcional |
| **03** | [Inferencia causal y matching](03_inferencia_causal_matching/) | Econometria e inferencia causal observacional | R, MatchIt, cobalt, survey | Validado y funcional |
| **04** | [Mineria de datos ambiental: Lago Caburgua](04_mineria_datos_lago_caburgua/) | Aprendizaje automatico e hidrologia | Python, Pandas, Scikit-Learn, LSTM | Validado y funcional |
| **05** | [Prediccion de partidos: La Liga espanola](05_prediccion_partidos_laliga/) | Modelos longitudinales y efectos mixtos cruzados | R, lme4, pROC, stargazer | Validado y funcional |
| **06** | [Control estadistico de calidad y procesos (SPC)](06_control_estadistico_procesos/) | Aseguramiento de calidad industrial | R, qcc, Cartas Shewhart, CUSUM | Validado y funcional |
| **07** | [Diseno de experimentos y ANCOVA](07_diseno_experimentos_ancova/) | Estadistica experimental y control de covariables | R, car, lmtest, rmdformats | Validado y funcional |
| **08** | [Modelado de volatilidad: S&P 500 (GARCH)](08_modelado_volatilidad_sp500_garch/) | Econometria financiera y series de tiempo | R, rugarch, quantmod, tseries | Validado y funcional |

---

## Resumen de proyectos

### 01. Dashboard de seguridad ciudadana (ENUSC)
* **Objetivo:** Analisis interactivo y geoespacial de la Encuesta Nacional Urbana de Seguridad Ciudadana (ENUSC) del INE Chile.
* **Capacidades:** Visualizacion de capas vectoriales en Leaflet, reglas de asociacion (Apriori), agrupamiento jerarquico y generacion automatizada de reportes ejecutivos en PDF.
* **Acceso:** [Ver proyecto y manual](01_dashboard_seguridad_enusc/)

### 02. Pronostico y modelado de series de tiempo meteorologicas
* **Objetivo:** Modelado de alta frecuencia y proyeccion de la velocidad del viento en la bahia de Coquimbo/La Serena con datos de la Direccion Meteorologica de Chile.
* **Capacidades:** Imputacion de vacios temporales, modelos autorregresivos estacionales SARIMAX con covariables climaticas y redes convolucionales temporales (TCN).
* **Acceso:** [Ver proyecto y manual](02_series_tiempo_viento_la_serena/)

### 03. Inferencia causal y emparejamiento por propension (matching)
* **Objetivo:** Evaluacion del impacto causal del entrenamiento laboral sobre ingresos futuros con el dataset de Lalonde (1986).
* **Capacidades:** Regresion logistica de propensity score, emparejamiento con soporte comun (caliper), evaluacion de balance con Love plots, estimador doblemente robusto y ponderacion IPW.
* **Acceso:** [Ver proyecto y manual](03_inferencia_causal_matching/)

### 04. Mineria de datos y aprendizaje automatico ambiental: Lago Caburgua
* **Objetivo:** Modelado hidrologico de niveles lacustres ante variabilidad climatica y evaluacion de intervenciones hidraulicas en cuenca.
* **Capacidades:** Preprocesamiento de registros de la Direccion General de Aguas (DGA), ingenieria de variables rezagadas y redes neuronales secuenciales LSTM.
* **Acceso:** [Ver proyecto y manual](04_mineria_datos_lago_caburgua/)

### 05. Prediccion de partidos: La Liga espanola
* **Objetivo:** Estimacion de la probabilidad de victoria en futbol profesional con 4,700 partidos de La Liga espanola.
* **Capacidades:** Construccion de variables pre-partido sin fuga de datos (`form_xg`, `form_xga`), modelos de efectos mixtos cruzados por equipo atacante y rival (`lme4`), simulacion interactiva de clasicos y exportacion a LaTeX con `stargazer`.
* **Acceso:** [Ver proyecto y manual](05_prediccion_partidos_laliga/)

### 06. Control estadistico de calidad y procesos (SPC)
* **Objetivo:** Monitorizacion de estabilidad de procesos y analisis de capacidad en manufactura.
* **Capacidades:** Implementacion matematica propia de constantes Shewhart, calculo de limites de control, integracion de libreria industrial `qcc`, cartas por atributos y esquemas CUSUM.
* **Acceso:** [Ver proyecto y manual](06_control_estadistico_procesos/)

### 07. Diseno de experimentos y analisis de covarianza (ANCOVA)
* **Objetivo:** Reduccion del error experimental y comparacion de medias ajustadas mediante control de covariables continuas.
* **Capacidades:** Validacion de supuestos fundamentales (homogeneidad de pendientes, normalidad, homocedasticidad), contrastes post-hoc y reporte web reproducible.
* **Acceso:** [Ver proyecto y manual](07_diseno_experimentos_ancova/)

### 08. Modelado y pronostico de volatilidad financiera: S&P 500 (GARCH)
* **Objetivo:** Estimacion y proyeccion de la estructura de volatilidad condicional diaria del indice S&P 500 (2015-2024).
* **Capacidades:** Identificacion de hechos estilizados (clusters de volatilidad, colas pesadas), especificacion GARCH(1,1) con distribucion $t$-Student mediante `rugarch`, pronostico fuera de muestra y diagnostico de residuos.
* **Acceso:** [Ver proyecto y manual](08_modelado_volatilidad_sp500_garch/)

---

## Politica de datos y gobernanza etica

Todos los proyectos incluidos en este portafolio cumplen estrictamente con los estandares de etica analitica y privacidad:
* Se excluyen en su totalidad datos clinicos, hospitalarios o cualquier informacion confidencial identificable.
* Se omiten proyectos de investigacion en curso o tesis sujetas a reserva o derechos de autor protegidos.
* Las fuentes de datos utilizadas corresponden a repositorios publicos oficiales (INE Chile, DMC, DGA, Yahoo Finance) o datasets abiertos estandarizados para fines docentes y de investigacion.

---

## Informacion de contacto y autoria

* **Autor:** [Nombre del autor]
* **Licencia general:** MIT License.
