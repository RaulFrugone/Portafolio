# Script de Análisis Causal - Taller Final MEA U3
# Autor: Antigravity Coding Assistant
# Fecha: 2026-06-21

# Habilitar manejo de errores limpio
options(show.error.messages = TRUE)

cat("========================================================================\n")
cat("INICIANDO ANÁLISIS DE ESTIMACIÓN CAUSAL (DATASET LALONDE)\n")
cat("========================================================================\n\n")

# Cargar librerías necesarias
library(MatchIt)
library(cobalt)
library(survey)
library(ggplot2)
library(dplyr)

# Cargar dataset Lalonde
data_path <- "lalonde.csv"
if (!file.exists(data_path)) {
  stop("El archivo lalonde.csv no existe en el directorio especificado.")
}
lalonde <- read.csv(data_path)

cat("--- Datos Cargados Correctamente ---\n")
cat("Número total de observaciones:", nrow(lalonde), "\n")
cat("Tratados (Taller):", sum(lalonde$treat == 1), "\n")
cat("Controles (CPS observacionales):", sum(lalonde$treat == 0), "\n\n")

# ==============================================================================
# 1. ESTIMACIÓN NO CAUSAL (ASOCIACIONAL / DESCRIPTIVA)
# ==============================================================================
cat("========================================================================\n")
cat("1. ESTIMACIONES NO CAUSALES (REGRESIÓN DESCRIPTIVA Y DIF. DE MEDIAS)\n")
cat("========================================================================\n")

# Diferencia simple de medias (Sin ajustar por covariables)
mean_treated <- mean(lalonde$re78[lalonde$treat == 1])
mean_control <- mean(lalonde$re78[lalonde$treat == 0])
diff_simple <- mean_treated - mean_control

cat("Ingreso promedio Tratados ($Y|D=1):", round(mean_treated, 2), "\n")
cat("Ingreso promedio Controles ($Y|D=0):", round(mean_control, 2), "\n")
cat("Diferencia simple de medias (Sesgada):", round(diff_simple, 2), "\n\n")

# Regresión Lineal Bivariada (Equivalente a la diferencia simple)
fit_biv <- lm(re78 ~ treat, data = lalonde)
cat("Coeficiente de regresión bivariada:\n")
print(summary(fit_biv)$coefficients["treat", ])

# Regresión Lineal Multivariada OLS (Ajustando por covariables de manera lineal convencional)
fit_ols <- lm(re78 ~ treat + age + educ + race + married + nodegree + re74 + re75, data = lalonde)
cat("\nCoeficiente de regresión multivariada OLS (con controles directos):\n")
print(summary(fit_ols)$coefficients["treat", ])
cat("\n")

# ==============================================================================
# 2. MODELO DE PROPENSITY SCORE (LOGIT)
# ==============================================================================
cat("========================================================================\n")
cat("2. AJUSTE DEL MODELO DE PROPENSITY SCORE (LOGIT)\n")
cat("========================================================================\n")

# Modelo Logístico para estimar la probabilidad de participar en la capacitación (Propensity Score)
ps_model <- glm(treat ~ age + educ + race + married + nodegree + re74 + re75, 
                family = binomial(link = "logit"), data = lalonde)
cat("Resumen del Modelo de Propensity Score:\n")
print(summary(ps_model))

# Guardar los Propensity Scores en la base de datos
lalonde$ps <- predict(ps_model, type = "response")

# Visualización del solapamiento (Soporte Común) antes del matching
png("propensity_overlap.png", 
    width = 1200, height = 800, res = 150)
ggplot(lalonde, aes(x = ps, fill = factor(treat))) +
  geom_density(alpha = 0.5) +
  scale_fill_manual(values = c("#FF6B6B", "#4D96FF"), labels = c("Control", "Tratado")) +
  labs(title = "Distribución del Propensity Score por Grupo (Soporte Común)",
       subtitle = "Antes del Emparejamiento",
       x = "Propensity Score Estaimado (p(X))", y = "Densidad", fill = "Grupo") +
  theme_minimal() +
  theme(legend.position = "top", plot.title = element_text(face = "bold", size = 14))
dev.off()
cat("Gráfico de solapamiento guardado en 'propensity_overlap.png'\n\n")

# ==============================================================================
# 3. ESTIMACIÓN CAUSAL - PROPENSITY SCORE MATCHING (PSM)
# ==============================================================================
cat("========================================================================\n")
cat("3. ESTIMACIÓN CAUSAL: PROPENSITY SCORE MATCHING (PSM)\n")
cat("========================================================================\n")

# Emparejamiento por vecino más cercano 1:1 sin reemplazo con calibre de 0.05
# Se usa calibre para mejorar el balance y asegurar soporte común estricto
m_out <- matchit(treat ~ age + educ + race + married + nodegree + re74 + re75,
                 method = "nearest", distance = "glm", link = "logit", 
                 caliper = 0.05, data = lalonde)

cat("Resumen del proceso de Matching:\n")
print(m_out)

# Obtener los datos emparejados
matched_data <- match.data(m_out)
cat("\nObservaciones emparejadas totales:", nrow(matched_data), "\n")
cat("Tratados emparejados:", sum(matched_data$treat == 1), "\n")
cat("Controles emparejados:", sum(matched_data$treat == 0), "\n\n")

# Gráfico de balance de covariables (Love Plot)
png("love_plot.png", 
    width = 1200, height = 800, res = 150)
love.plot(m_out, binary = "std", thresholds = c(m = .1),
          colors = c("#FF6B6B", "#4D96FF"),
          shapes = c("circle", "triangle"),
          title = "Balance de Covariables (Love Plot)",
          stars = "raw") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14))
dev.off()
cat("Gráfico de balance guardado en 'love_plot.png'\n\n")

# Estimación del efecto causal (ATT) en los datos emparejados
# Regresión lineal simple en el dataset emparejado (ATT sin covariables)
fit_att_simple <- lm(re78 ~ treat, data = matched_data, weights = weights)
cat("Estimación del ATT mediante PSM (Regresión Simple en muestra emparejada):\n")
print(summary(fit_att_simple)$coefficients["treat", ])

# Regresión lineal con ajuste de covariables en el dataset emparejado (Double Robustness)
fit_att_dr <- lm(re78 ~ treat + age + educ + race + married + nodegree + re74 + re75, 
                 data = matched_data, weights = weights)
cat("\nEstimación del ATT mediante PSM (Doble Robustez - Regresión Ajustada en muestra emparejada):\n")
print(summary(fit_att_dr)$coefficients["treat", ])
cat("\n")

# ==============================================================================
# 4. ESTIMACIÓN CAUSAL - INVERSE PROBABILITY WEIGHTING (IPW)
# ==============================================================================
cat("========================================================================\n")
cat("4. ESTIMACIÓN CAUSAL: INVERSE PROBABILITY WEIGHTING (IPW)\n")
cat("========================================================================\n")

# Calcular pesos de IPW para estimar el ATT
# Peso = 1 para tratados, p/(1-p) para controles
lalonde$weights_att <- ifelse(lalonde$treat == 1, 1, lalonde$ps / (1 - lalonde$ps))

# Verificar que no haya pesos extremos que inflen la varianza
cat("Distribución de los pesos de IPW para el grupo de control:\n")
print(summary(lalonde$weights_att[lalonde$treat == 0]))

# Usar el paquete survey para estimar el ATT ponderado y obtener errores estándar correctos
design_att <- svydesign(ids = ~1, weights = ~weights_att, data = lalonde)
fit_ipw_att <- svyglm(re78 ~ treat, design = design_att)

cat("\nEstimación del ATT mediante IPW (Ponderación de Probabilidad Inversa):\n")
print(summary(fit_ipw_att)$coefficients["treat", ])
cat("\n")

# ==============================================================================
# 5. TABLA RESUMEN COMPARATIVA
# ==============================================================================
cat("========================================================================\n")
cat("5. TABLA RESUMEN COMPARATIVA DE ESTIMACIONES\n")
cat("========================================================================\n")

resumen <- data.frame(
  Metodo = c("Diferencia Simple (No Causal)", 
             "Regresión OLS Ajustada (No Causal)", 
             "PSM Nearest Neighbor ATT (Causal)", 
             "PSM Double Robust ATT (Causal)", 
             "IPW ATT (Causal)"),
  Estimado = c(
    coef(fit_biv)["treat"],
    coef(fit_ols)["treat"],
    coef(fit_att_simple)["treat"],
    coef(fit_att_dr)["treat"],
    coef(fit_ipw_att)["treat"]
  ),
  Error_Estandar = c(
    summary(fit_biv)$coefficients["treat", "Std. Error"],
    summary(fit_ols)$coefficients["treat", "Std. Error"],
    summary(fit_att_simple)$coefficients["treat", "Std. Error"],
    summary(fit_att_dr)$coefficients["treat", "Std. Error"],
    summary(fit_ipw_att)$coefficients["treat", "Std. Error"]
  )
)

resumen$Estadistico_t <- resumen$Estimado / resumen$Error_Estandar
resumen$P_Valor <- 2 * (1 - pnorm(abs(resumen$Estadistico_t)))

print(resumen, digits = 4)

cat("\n========================================================================\n")
cat("ANÁLISIS COMPLETADO CON ÉXITO\n")
cat("========================================================================\n")
