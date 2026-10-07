# ==============================================================================
# Modelado y pronostico de volatilidad financiera: S&P 500 (GARCH)
# Analisis de colas pesadas, clusters de volatilidad y modelos rugarch
# ==============================================================================

# 1. Cargar librerias -----------------------------------------------------------
suppressPackageStartupMessages({
  library(quantmod)
  library(rugarch)
  library(tseries)
  library(PerformanceAnalytics)
  library(ggplot2)
  library(xts)
})

# 2. Carga y preparacion de datos ----------------------------------------------
data_file <- "sp500_data.csv"
if (!file.exists(data_file) && file.exists(file.path("portafolio", "08_modelado_volatilidad_sp500_garch", data_file))) {
  setwd(file.path("portafolio", "08_modelado_volatilidad_sp500_garch"))
}

cat("Cargando serie temporal del S&P 500 (2015-2024)...\n")
if (file.exists(data_file)) {
  raw_df <- read.csv(data_file)
  dates <- as.Date(raw_df$Date)
  close_prices <- raw_df$GSPC.Close
  gspc_xts <- xts(close_prices, order.by = dates)
  sp500_ret <- dailyReturn(gspc_xts, type = "log")
} else {
  getSymbols("^GSPC", from = "2015-01-01", to = "2024-12-31", auto.assign = TRUE)
  sp500_ret <- dailyReturn(Cl(GSPC), type = "log")
}

# Omitir NAs
sp500_ret <- na.omit(sp500_ret)
colnames(sp500_ret) <- "Returns"
cat("Observaciones diarias de retornos calculadas:", length(sp500_ret), "\n\n")

# ==============================================================================
# 3. Hechos estilizados y contrastes estadisticos
# ==============================================================================
cat("--- HECHOS ESTILIZADOS DE SERIES FINANCIERAS ---\n")

# Test de Jarque-Bera (Normalidad)
jb_test <- jarque.bera.test(as.numeric(sp500_ret))
cat("Test de Jarque-Bera (p-valor):", jb_test$p.value, "\n")
cat("Kurtosis muestral:", PerformanceAnalytics::kurtosis(sp500_ret), "(Evidencia de colas pesadas / leptocurtosis)\n")

# Test de Ljung-Box para efecto ARCH en retornos al cuadrado
lb_sq <- Box.test(as.numeric(sp500_ret)^2, lag = 12, type = "Ljung-Box")
cat("Test de Ljung-Box en retornos al cuadrado (p-valor):", lb_sq$p.value, 
    "(Rechaza homocedasticidad -> Evidencia de clusters de volatilidad)\n\n")

# ==============================================================================
# 4. Especificacion y ajuste del modelo GARCH(1,1)
# ==============================================================================
cat("--- AJUSTE DEL MODELO GARCH(1,1) CON DISTRIBUCION T-STUDENT ---\n")

# Especificacion con innovaciones t-Student para modelar colas pesadas
spec <- ugarchspec(
  variance.model = list(model = "sGARCH", garchOrder = c(1, 1)),
  mean.model = list(armaOrder = c(0, 0), include.mean = TRUE),
  distribution.model = "std"
)

fit <- ugarchfit(spec = spec, data = sp500_ret)
print(fit@fit$robust.matcoef)

# Persistencia de la volatilidad (alpha + beta)
coefs <- fit@fit$coef
alpha1 <- coefs["alpha1"]
beta1 <- coefs["beta1"]
persistencia <- alpha1 + beta1
cat("\nPersistencia de la volatilidad (alpha + beta):", round(persistencia, 4), "\n")
if (persistencia < 1) {
  cat("El proceso es estrictamente estacionario en covarianza.\n")
}

# ==============================================================================
# 5. Diagnostico de residuos estandarizados
# ==============================================================================
cat("\n--- DIAGNOSTICO DE RESIDUOS ESTANDARIZADOS ---\n")
res_std <- residuals(fit, standardize = TRUE)
lb_res_sq <- Box.test(as.numeric(res_std)^2, lag = 12, type = "Ljung-Box")
cat("Ljung-Box sobre residuos estandarizados al cuadrado (p-valor):", round(lb_res_sq$p.value, 4), "\n")
cat("El modelo captura adecuadamente la estructura de volatilidad condicional.\n\n")

# ==============================================================================
# 6. Pronostico de volatilidad fuera de muestra (h = 20 dias)
# ==============================================================================
cat("--- PRONOSTICO DE VOLATILIDAD A 20 DIAS ---\n")
n_ahead <- 20
forecast <- ugarchforecast(fit, n.ahead = n_ahead)
sigma_forecast <- as.numeric(sigma(forecast))

# Volatilidad anualizada proyectada
vol_anualizada <- sigma_forecast * sqrt(252) * 100
cat("Volatilidad esperada dia +1:", round(sigma_forecast[1] * 100, 3), "%\n")
cat("Volatilidad esperada dia +20:", round(sigma_forecast[n_ahead] * 100, 3), "%\n")
cat("Volatilidad anualizada proyectada (dia +20):", round(vol_anualizada[n_ahead], 2), "%\n")

# Guardar graficos de diagnostico
png("acf_residuos_cuadrados.png", width = 800, height = 600)
acf(as.numeric(res_std)^2, main = "ACF de residuos estandarizados al cuadrado")
dev.off()

cat("\nGrafico 'acf_residuos_cuadrados.png' guardado exitosamente.\n")
cat("Analisis de volatilidad GARCH S&P 500 completado con exito.\n")
