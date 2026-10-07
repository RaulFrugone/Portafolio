# Modelado y pronostico de volatilidad financiera: S&P 500 (GARCH)

## 1. Descripcion general

Este proyecto implementa modelos econometricos de heterocedasticidad condicional autorregresiva generalizada (GARCH) para el analisis y pronostico de la volatilidad del indice bursatil Standard & Poor's 500 (S&P 500 / `^GSPC`), abarcando una decada completa de transacciones diarias (2015-2024).

Las series de retornos financieros presentan violaciones sistematicas a los supuestos de homocedasticidad y normalidad (hechos estilizados de Mandelbrot y Fama). En este repositorio se modelan formalmente:
1. **Agrupamiento de volatilidad (*volatility clustering*):** Periodos de alta turbulencia seguidos por turbulencia, y calma seguida de calma.
2. **Colas pesadas (*fat tails*):** Leptocurtosis pronunciada modelada mediante innovaciones con distribucion $t$-Student.
3. **Persistencia condicional:** Estimacion de la tasa de decaimiento del shock de volatilidad ($\alpha_1 + \beta_1$).
4. **Pronostico dinamico fuera de muestra:** Proyeccion de la desviacion estandar condicional a un horizonte de 20 dias y calculo de volatilidad anualizada.

---

## 2. Tecnologias utilizadas

* **Lenguaje:** R (version 4.0 o superior)
* **Paquetes principales:**
  * Econometria financiera y modelado GARCH: `rugarch`, `tseries`
  * Series temporales y datos de mercado: `quantmod`, `xts`, `PerformanceAnalytics`
  * Visualizacion grafica: `ggplot2`

---

## 3. Estructura de archivos del proyecto

* `modelo_garch_sp500.R`: Script principal ejecutable y autocontenido que realiza el calculo de retornos logaritmicos, pruebas de no linealidad, ajuste del modelo GARCH(1,1) y pronostico de volatilidad.
* `sp500_data.csv`: Base de datos historica consolidada (2,515 dias de cotizacion) para garantizar la ejecucion 100% *offline*.
* `Prediccion volatilidad.png`: Grafico de proyeccion de la banda de volatilidad condicional hacia el horizonte futuro.
* `Retorno y volatilidad.png`: Serie temporal comparativa entre retornos diarios y variabilidad condicional estimada.
* `ACF RETORNOS.png` y `ACF RETORNOS^2.png`: Comparacion de autocorrelacion que valida la presencia de dependencia no lineal (efecto ARCH).
* `Residuos Hist t student.png`: Diagnostico empirico del ajuste de colas pesadas de la distribucion $t$.
* `Referencias/`: Documentos tecnicos y cientificos de consulta sobre extensiones ARCH, GARCH y EGARCH.

---

## 4. Requisitos e instalacion

Instale los paquetes necesarios en R ejecutando:

```r
paquetes <- c("quantmod", "rugarch", "tseries", "PerformanceAnalytics", "ggplot2", "xts")
paquetes_faltantes <- paquetes[!(paquetes %in% installed.packages()[, "Package"])]
if (length(paquetes_faltantes) > 0) {
  install.packages(paquetes_faltantes, dependencies = TRUE)
}
```

---

## 5. Instrucciones de ejecucion

Ejecute directamente el script desde la terminal o consola de R:

```bash
Rscript modelo_garch_sp500.R
```

O en la consola de RStudio:

```r
source("modelo_garch_sp500.R")
```

El script imprimira los tests de Jarque-Bera y Ljung-Box, los parametros estimados robustos del modelo ($\mu, \omega, \alpha_1, \beta_1, \text{shape}$), la persistencia del proceso y el vector de volatilidades anualizadas esperadas.

---

## 6. Resultados econometricos destacados

* **Rechazo de normalidad:** La kurtosis muestral de 15.72 y el test de Jarque-Bera ($p < 10^{-16}$) justifican plenamente el abandono de la hipotesis gaussiana a favor de innovaciones $t$-Student con parametro de forma estimado $\nu \approx 5.64$.
* **Evidencia de clusters ARCH:** El test de Ljung-Box sobre retornos al cuadrado ($p < 10^{-5}$) confirma la dependencia temporal en la varianza condicional.
* **Persistencia y estacionariedad:** La suma $\alpha_1 + \beta_1 = 0.9969 < 1$ evidencia una memoria prolongada de los shocks en el mercado accionario estadounidense, manteniendo la estricta estacionariedad en covarianza del proceso.
* **Adecuacion del modelo:** Los residuos estandarizados al cuadrado resultan ser ruido blanco (Ljung-Box $p = 0.6203$), confirmando que el modelo sGARCH(1,1) purifica la estructura de autocorrelacion de la volatilidad.

---

## 7. Informacion de autoria y licencia

* **Desarrollado por:** [Nombre del autor]
* **Fuente de datos:** Yahoo Finance (`^GSPC` - S&P 500 Index).
* **Licencia:** MIT License.
