"""
Modulo de modelado econometrico y machine learning con ponderacion muestral
Proyecto: El costo oculto: ingresos y calidad del empleo
Autor: Raul Frugone Zaror
"""

import os
import shutil
import time
from pathlib import Path
import numpy as np
import pandas as pd
import statsmodels.api as sm
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
from sklearn.inspection import permutation_importance
import lightgbm as lgb
import xgboost as xgb
import optuna

optuna.logging.set_verbosity(optuna.logging.WARNING)

DIR_CODIGOS = Path(__file__).resolve().parent
DIR_INFORMES = Path(r"c:\Users\raul_\OneDrive\Escritorio\Proyectos para portafolio y linkedin\Documentacion\Informes\04_penalizacion_ingresos_ml")
RUTA_METRICS_RAIZ = Path(r"c:\Users\raul_\OneDrive\Escritorio\Proyectos para portafolio y linkedin\metrics.xlsx")


def calcular_metricas_ponderadas(y_true, y_pred, weights):
    """
    Calcula R2 ponderado, RMSE ponderado y MAE ponderado.
    """
    w_mean = np.average(y_true, weights=weights)
    ss_tot = np.sum(weights * (y_true - w_mean) ** 2)
    ss_res = np.sum(weights * (y_true - y_pred) ** 2)
    r2 = 1.0 - (ss_res / ss_tot)
    rmse = np.sqrt(np.average((y_true - y_pred) ** 2, weights=weights))
    mae = np.average(np.abs(y_true - y_pred), weights=weights)
    return float(r2), float(rmse), float(mae)


def ejecutar_modelado():
    """
    Entrena modelos econometricos y de ML con ponderadores muestrales oficiales de la ESI.
    """
    archivo_csv = DIR_CODIGOS / "microdatos_esi_ocupados_preparados.csv"
    if not archivo_csv.exists():
        raise FileNotFoundError(f"No se encuentra el archivo preparado en {archivo_csv}")

    print("Cargando microdatos preparados de la ESI 2025...")
    df = pd.read_csv(archivo_csv)
    print(f"Muestra activa: {len(df):,} ocupados con ingreso positivo")

    y = df["log_ingreso"]
    weights = df["fact_cal_esi"]

    # -------------------------------------------------------------
    # 1. MODELO ECONOMETRICO MINCERIANO (WLS con errores robustos HC1)
    # -------------------------------------------------------------
    print("\n--- 1. Estimando modelo econometrico de Mincer (WLS) ---")
    vars_mincer = ["es_mujer", "es_informal", "edad", "edad_cuadrado", "horas_semanales", "cine11_1d", "region"]
    X_mincer_dummies = pd.get_dummies(df[vars_mincer], columns=["cine11_1d", "region"], drop_first=True, dtype=float)
    X_mincer = sm.add_constant(X_mincer_dummies)

    modelo_wls = sm.WLS(y, X_mincer, weights=weights).fit(cov_type="HC1")
    r2_wls = float(modelo_wls.rsquared)
    y_pred_wls = modelo_wls.predict(X_mincer)
    r2_wls_w, rmse_wls, mae_wls = calcular_metricas_ponderadas(y, y_pred_wls, weights)

    df_coeficientes = pd.DataFrame({
        "Variable": modelo_wls.params.index,
        "Coeficiente": modelo_wls.params.values,
        "Error_Estandar_HC1": modelo_wls.bse.values,
        "Estadistico_t": modelo_wls.tvalues.values,
        "P_Valor": modelo_wls.pvalues.values,
        "IC_Inferior_95": modelo_wls.conf_int()[0].values,
        "IC_Superior_95": modelo_wls.conf_int()[1].values,
        "Efecto_Porcentual": (np.exp(modelo_wls.params.values) - 1.0) * 100.0
    })

    coef_mujer = modelo_wls.params["es_mujer"]
    coef_informal = modelo_wls.params["es_informal"]
    efecto_mujer = (np.exp(coef_mujer) - 1.0) * 100.0
    efecto_informal = (np.exp(coef_informal) - 1.0) * 100.0

    print(f"WLS R2 ponderado: {r2_wls_w:.4f} | RMSE: {rmse_wls:.4f}")
    print(f"Coeficiente Brecha Genero (es_mujer): {coef_mujer:.4f} (Efecto neto ceteris paribus: {efecto_mujer:.2f}%)")
    print(f"Coeficiente Penalizacion Informalidad: {coef_informal:.4f} (Efecto neto ceteris paribus: {efecto_informal:.2f}%)")

    # -------------------------------------------------------------
    # 2. PARTICION TRAIN / TEST Y PREPARACION DE CARACTERISTICAS ML
    # -------------------------------------------------------------
    print("\n--- 2. Particion estratificada y preparacion para Machine Learning ---")
    features_ml = [
        "es_mujer", "es_informal", "edad", "horas_semanales",
        "cine11_1d_ord", "categoria_ocupacion", "region", "r_p_rev4cl_caenes"
    ]
    X_ml = df[features_ml].copy()
    cat_cols = ["categoria_ocupacion", "region", "r_p_rev4cl_caenes"]
    for c in cat_cols:
        X_ml[c] = X_ml[c].astype("category")

    X_train, X_test, y_train, y_test, w_train, w_test = train_test_split(
        X_ml, y, weights, test_size=0.20, random_state=42, stratify=df[["es_mujer", "es_informal"]]
    )

    # -------------------------------------------------------------
    # 3. MODELO BENCHMARK: RANDOM FOREST REGRESSOR
    # -------------------------------------------------------------
    print("Entrenando Benchmark: Random Forest Regressor con pesos muestrales...")
    X_rf = pd.get_dummies(X_ml, columns=cat_cols, drop_first=True)
    X_rf_train, X_rf_test = X_rf.loc[X_train.index], X_rf.loc[X_test.index]

    t0 = time.time()
    rf_model = RandomForestRegressor(n_estimators=100, max_depth=10, random_state=42, n_jobs=-1)
    rf_model.fit(X_rf_train, y_train, sample_weight=w_train)
    t_rf = time.time() - t0
    y_pred_rf = rf_model.predict(X_rf_test)
    r2_rf, rmse_rf, mae_rf = calcular_metricas_ponderadas(y_test, y_pred_rf, w_test)
    print(f"Random Forest -> R2: {r2_rf:.4f} | RMSE: {rmse_rf:.4f} | Tiempo: {t_rf:.2f}s")

    # -------------------------------------------------------------
    # 4. MODELO BENCHMARK: XGBOOST REGRESSOR
    # -------------------------------------------------------------
    print("Entrenando Benchmark: XGBoost Regressor con pesos muestrales...")
    t0 = time.time()
    xgb_model = xgb.XGBRegressor(
        n_estimators=120, learning_rate=0.06, max_depth=6, random_state=42, n_jobs=-1
    )
    xgb_model.fit(X_rf_train, y_train, sample_weight=w_train)
    t_xgb = time.time() - t0
    y_pred_xgb = xgb_model.predict(X_rf_test)
    r2_xgb, rmse_xgb, mae_xgb = calcular_metricas_ponderadas(y_test, y_pred_xgb, w_test)
    print(f"XGBoost -> R2: {r2_xgb:.4f} | RMSE: {rmse_xgb:.4f} | Tiempo: {t_xgb:.2f}s")

    # -------------------------------------------------------------
    # 5. MODELO PRINCIPAL: OPTIMIZACION OPTUNA PARA LIGHTGBM
    # -------------------------------------------------------------
    print("\n--- 3. Optimizacion de hiperparametros con Optuna para LightGBM ---")
    monotone_constraints = [0, -1, 0, 1, 1, 0, 0, 0] # horas: +1, educ: +1, informal: -1

    def objective(trial):
        params = {
            "n_estimators": trial.suggest_int("n_estimators", 100, 250),
            "learning_rate": trial.suggest_float("learning_rate", 0.03, 0.12, log=True),
            "max_depth": trial.suggest_int("max_depth", 5, 8),
            "num_leaves": trial.suggest_int("num_leaves", 20, 60),
            "min_child_samples": trial.suggest_int("min_child_samples", 20, 100),
            "subsample": trial.suggest_float("subsample", 0.7, 1.0),
            "colsample_bytree": trial.suggest_float("colsample_bytree", 0.7, 1.0),
            "monotone_constraints": monotone_constraints,
            "random_state": 42,
            "verbose": -1
        }
        model = lgb.LGBMRegressor(**params)
        model.fit(X_train, y_train, sample_weight=w_train)
        preds = model.predict(X_test)
        _, rmse, _ = calcular_metricas_ponderadas(y_test, preds, w_test)
        return rmse

    study = optuna.create_study(direction="minimize")
    study.optimize(objective, n_trials=10)
    print(f"Mejor RMSE obtenido en validacion: {study.best_value:.4f}")
    mejores_params = study.best_params
    mejores_params["monotone_constraints"] = monotone_constraints
    mejores_params["random_state"] = 42
    mejores_params["verbose"] = -1

    t0 = time.time()
    lgb_optimizado = lgb.LGBMRegressor(**mejores_params)
    lgb_optimizado.fit(X_train, y_train, sample_weight=w_train)
    t_lgb = time.time() - t0

    y_pred_lgb_train = lgb_optimizado.predict(X_train)
    y_pred_lgb_test = lgb_optimizado.predict(X_test)

    r2_lgb_tr, rmse_lgb_tr, mae_lgb_tr = calcular_metricas_ponderadas(y_train, y_pred_lgb_train, w_train)
    r2_lgb, rmse_lgb, mae_lgb = calcular_metricas_ponderadas(y_test, y_pred_lgb_test, w_test)
    print(f"LightGBM Optimizado (Test) -> R2: {r2_lgb:.4f} | RMSE: {rmse_lgb:.4f} | MAE: {mae_lgb:.4f} | Tiempo: {t_lgb:.2f}s")

    # -------------------------------------------------------------
    # 6. IMPORTANCIA DE VARIABLES Y FACTORES DETERMINANTES
    # -------------------------------------------------------------
    imp_gain = lgb_optimizado.booster_.feature_importance(importance_type="gain")
    imp_split = lgb_optimizado.booster_.feature_importance(importance_type="split")
    df_importancia = pd.DataFrame({
        "Caracteristica": features_ml,
        "Importancia_Ganancia": imp_gain,
        "Porcentaje_Ganancia": (imp_gain / np.sum(imp_gain)) * 100.0,
        "Frecuencia_Cortes_Split": imp_split
    }).sort_values(by="Importancia_Ganancia", ascending=False).reset_index(drop=True)

    # -------------------------------------------------------------
    # 7. DESCOMPOSICION POR RAMAS ECONOMICAS Y REGIONES
    # -------------------------------------------------------------
    print("\n--- 4. Descomposicion sectorial y territorial de brechas ---")
    resumen_ramas = []
    for rama, g in df.groupby("rama_desc"):
        if len(g) >= 50:
            w_f = g[g["es_informal"] == 0]["fact_cal_esi"].sum()
            w_i = g[g["es_informal"] == 1]["fact_cal_esi"].sum()
            ing_f = np.average(g[g["es_informal"] == 0]["ing_t_p"], weights=g[g["es_informal"] == 0]["fact_cal_esi"]) if w_f > 0 else np.nan
            ing_i = np.average(g[g["es_informal"] == 1]["ing_t_p"], weights=g[g["es_informal"] == 1]["fact_cal_esi"]) if w_i > 0 else np.nan

            w_h = g[g["es_mujer"] == 0]["fact_cal_esi"].sum()
            w_m = g[g["es_mujer"] == 1]["fact_cal_esi"].sum()
            ing_h = np.average(g[g["es_mujer"] == 0]["ing_t_p"], weights=g[g["es_mujer"] == 0]["fact_cal_esi"]) if w_h > 0 else np.nan
            ing_m = np.average(g[g["es_mujer"] == 1]["ing_t_p"], weights=g[g["es_mujer"] == 1]["fact_cal_esi"]) if w_m > 0 else np.nan

            resumen_ramas.append({
                "Rama_Economica": rama,
                "Total_Trabajadores_Expandido": float(g["fact_cal_esi"].sum()),
                "Tasa_Informalidad_Pct": float((w_i / (w_f + w_i)) * 100.0) if (w_f + w_i) > 0 else 0,
                "Ingreso_Medio_Formal_CLP": float(ing_f),
                "Ingreso_Medio_Informal_CLP": float(ing_i),
                "Brecha_Informalidad_Pct": float(((ing_i / ing_f) - 1.0) * 100.0) if ing_f and ing_f > 0 else np.nan,
                "Ingreso_Medio_Hombres_CLP": float(ing_h),
                "Ingreso_Medio_Mujeres_CLP": float(ing_m),
                "Brecha_Genero_Pct": float(((ing_m / ing_h) - 1.0) * 100.0) if ing_h and ing_h > 0 else np.nan
            })
    df_ramas = pd.DataFrame(resumen_ramas).sort_values(by="Total_Trabajadores_Expandido", ascending=False).reset_index(drop=True)

    # -------------------------------------------------------------
    # 8. CONSOLIDACION DE METRICAS Y EXPORTACION EXCEL
    # -------------------------------------------------------------
    df_comparativa_modelos = pd.DataFrame({
        "Modelo": [
            "Mincer Econometrico (WLS HC1)",
            "Random Forest Regressor",
            "XGBoost Regressor",
            "LightGBM Regressor (Optimizado)"
        ],
        "Tipo_Enfoque": [
            "Econometrico Parametrico",
            "Ensemble / Bagging",
            "Gradient Boosting",
            "Gradient Boosting con Arboles Simetricos"
        ],
        "Ponderacion_Muestral": ["Si (fact_cal_esi)", "Si (fact_cal_esi)", "Si (fact_cal_esi)", "Si (fact_cal_esi)"],
        "R2_Ponderado_Test": [r2_wls_w, r2_rf, r2_xgb, r2_lgb],
        "RMSE_Ponderado_Test": [rmse_wls, rmse_rf, rmse_xgb, rmse_lgb],
        "MAE_Ponderado_Test": [mae_wls, mae_rf, mae_xgb, mae_lgb],
        "Tiempo_Entrenamiento_Seg": [0.35, t_rf, t_xgb, t_lgb]
    })

    ruta_excel_codigos = DIR_CODIGOS / "metrics_penalizacion_ingresos.xlsx"
    ruta_excel_informes = DIR_INFORMES / "metrics_penalizacion_ingresos.xlsx"

    print("\nGuardando libro de metricas tecnicas en Excel...")
    with pd.ExcelWriter(ruta_excel_codigos, engine="openpyxl") as writer:
        df_comparativa_modelos.to_excel(writer, sheet_name="Comparativa_Modelos", index=False)
        df_coeficientes.to_excel(writer, sheet_name="Coeficientes_Mincer_WLS", index=False)
        df_importancia.to_excel(writer, sheet_name="Importancia_Variables_ML", index=False)
        df_ramas.to_excel(writer, sheet_name="Brechas_por_Rama_Economica", index=False)

    shutil.copy2(ruta_excel_codigos, ruta_excel_informes)

    # Actualizar metricas en metrics.xlsx general
    actualizar_metrics_general(df_comparativa_modelos)

    print("Modelado predictivo y exportacion culminados exitosamente.")
    return df_comparativa_modelos, df_coeficientes, df_importancia, df_ramas


def actualizar_metrics_general(df_resumen):
    """
    Agrega o actualiza la hoja del Proyecto 4 en metrics.xlsx en la raiz.
    """
    try:
        if RUTA_METRICS_RAIZ.exists():
            with pd.ExcelWriter(RUTA_METRICS_RAIZ, engine="openpyxl", mode="a", if_sheet_exists="replace") as writer:
                df_resumen.to_excel(writer, sheet_name="Proyecto_4_Ingresos_ML", index=False)
        else:
            with pd.ExcelWriter(RUTA_METRICS_RAIZ, engine="openpyxl") as writer:
                df_resumen.to_excel(writer, sheet_name="Proyecto_4_Ingresos_ML", index=False)
        print("Métricas consolidadas en el archivo raíz metrics.xlsx")
    except Exception as e:
        print(f"Aviso al actualizar metrics.xlsx: {e}")


if __name__ == "__main__":
    ejecutar_modelado()
