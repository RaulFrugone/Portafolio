# ==============================================================================
# Modelado predictivo de resultados de futbol: La Liga espanola
# Analisis de rendimiento esperado (xG) y efectos mixtos cruzados pre-partido
# ==============================================================================

# 1. Cargar librerias -----------------------------------------------------------
suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(lme4)      # Regresion longitudinal y efectos mixtos cruzados
  library(pROC)      # Curvas ROC y calculo de AUC
  library(stargazer) # Exportacion de tablas econometricas a formato LaTeX
})

# 2. Carga y preparacion de datos ----------------------------------------------
data_file <- "matches_laliga.csv"
if (!file.exists(data_file) && file.exists(file.path("portafolio", "05_prediccion_partidos_laliga", data_file))) {
  setwd(file.path("portafolio", "05_prediccion_partidos_laliga"))
}

cat("Cargando base de datos de partidos de La Liga...\n")
df_raw <- read_csv(data_file, show_col_types = FALSE)

# Filtrar y codificar variables base
df <- df_raw %>%
  mutate(
    win = as.factor(ifelse(result == "W", 1, 0)),
    home_advantage = ifelse(venue == "Home", 1, 0),
    team = as.factor(team),
    opponent = as.factor(opponent),
    gf = as.numeric(gf),
    ga = as.numeric(ga),
    xg = as.numeric(xg),
    xga = as.numeric(xga),
    poss = as.numeric(poss)
  ) %>%
  tidyr::drop_na(win, gf, xg, poss, home_advantage, team)

cat("Partidos totales procesados:", nrow(df), "\n\n")

# ==============================================================================
# 3. Modelo 1: Regresion logistica tradicional (Benchmark)
# ==============================================================================
cat("--- MODELO 1: REGRESION LOGISTICA ---\n")
mod_log <- glm(win ~ xg + poss + home_advantage, data = df, family = binomial)
print(summary(mod_log)$coefficients)

# Calculo de AUC
pred_prob_log <- predict(mod_log, type = "response")
roc_obj <- roc(df$win, pred_prob_log, quiet = TRUE)
cat("AUC Modelo Logistico:", round(auc(roc_obj), 4), "\n\n")

# ==============================================================================
# 4. Modelo 2: Regresion longitudinal con efectos aleatorios de equipo
# ==============================================================================
cat("--- MODELO 2: EFECTOS MIXTOS (JERARQUIA POR EQUIPO) ---\n")
mod_long <- glmer(
  win ~ xg + poss + home_advantage + (1 | team),
  data = df,
  family = binomial,
  control = glmerControl(optimizer = "bobyqa")
)
print(summary(mod_long)$coefficients)

# Comparacion con modelo simple (Likelihood Ratio Test)
lrt <- anova(mod_log, mod_long, test = "Chisq")
cat("Test de razon de verosimilitud (p-valor):", lrt[["Pr(>Chisq)"]][2], "\n")

# Correlacion intraclase aproximada (ICC)
var_team <- as.numeric(VarCorr(mod_long))
icc <- var_team / (var_team + (pi^2 / 3))
cat("Correlacion intraclase (ICC):", round(icc, 4), "\n\n")

# ==============================================================================
# 5. Modelo 3: Modelo predictivo pre-partido con efectos mixtos cruzados
# ==============================================================================
cat("--- MODELO 3: MODELO PREDICTIVO PRE-PARTIDO (SIN FUGA DE DATOS) ---\n")

# Feature engineering: metricas acumuladas pre-partido con rezago (lag)
df_pred <- df %>%
  arrange(team, date) %>%
  group_by(team) %>%
  mutate(
    # Promedios acumulados hasta la fecha previa al partido
    form_xg   = lag(cummean(xg)),
    form_xga  = lag(cummean(xga)),
    form_poss = lag(cummean(poss))
  ) %>%
  ungroup() %>%
  tidyr::drop_na(win, form_xg, form_xga, form_poss, home_advantage, team, opponent)

cat("Partidos con historial previo suficiente:", nrow(df_pred), "\n")

# Modelo de efectos mixtos cruzados (equipo local + equipo rival)
mod_pred <- glmer(
  win ~ form_xg + form_xga + form_poss + home_advantage +
    (1 | team) + (1 | opponent),
  data = df_pred,
  family = binomial,
  control = glmerControl(optimizer = "bobyqa")
)
print(summary(mod_pred)$coefficients)

# ==============================================================================
# 6. Simulador interactivo de partidos
# ==============================================================================
obtener_forma_actual <- function(equipo) {
  df_pred %>%
    filter(team == equipo) %>%
    arrange(desc(date)) %>%
    slice(1) %>%
    select(form_xg, form_xga, form_poss)
}

predecir_partido <- function(local, visita) {
  forma_loc <- obtener_forma_actual(local)
  if (nrow(forma_loc) == 0) stop("Equipo local no encontrado en el registro.")
  
  nuevo_partido <- data.frame(
    team = factor(local, levels = levels(df_pred$team)),
    opponent = factor(visita, levels = levels(df_pred$opponent)),
    home_advantage = 1,
    form_xg = forma_loc$form_xg,
    form_xga = forma_loc$form_xga,
    form_poss = forma_loc$form_poss
  )
  
  prob <- predict(mod_pred, newdata = nuevo_partido, type = "response", allow.new.levels = TRUE)
  return(as.numeric(prob))
}

cat("\n--- SIMULACION DE ENCUENTROS ---\n")
prob_clasico <- predecir_partido("Real Madrid", "Barcelona")
cat("Probabilidad estimada de victoria local: Real Madrid vs Barcelona:", round(prob_clasico * 100, 2), "%\n")

prob_atletico <- predecir_partido("Atletico Madrid", "Sevilla")
cat("Probabilidad estimada de victoria local: Atletico Madrid vs Sevilla:", round(prob_atletico * 100, 2), "%\n\n")

# ==============================================================================
# 7. Exportacion de tablas LaTeX para informe
# ==============================================================================
stargazer(
  mod_log, mod_long,
  type = "latex",
  title = "Resultados de modelos categoricos: Logistico vs Longitudinal",
  dep.var.labels = c("Probabilidad de victoria"),
  covariate.labels = c("Goles esperados (xG)", "Posesion", "Localia"),
  style = "aer",
  out = "modelos_comparacion.tex"
)
cat("Tabla 'modelos_comparacion.tex' generada exitosamente.\n")
cat("Analisis de prediccion de La Liga completado con exito.\n")
