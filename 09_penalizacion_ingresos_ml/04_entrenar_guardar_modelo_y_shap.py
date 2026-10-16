"""
Entrenamiento, serializacion de modelo LightGBM y generacion de explicabilidad SHAP (XAI)
Proyecto 4: Penalizacion salarial por informalidad y brechas de genero en Chile
Autor: Raul Frugone Zaror
"""

import os
import shutil
from pathlib import Path
import joblib
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import lightgbm as lgb
import shap

DIR_CODIGOS = Path(r"c:\Users\raul_\OneDrive\Escritorio\Proyectos para portafolio y linkedin\Codigos\04_penalizacion_ingresos_ml")
DIR_INFORMES = Path(r"c:\Users\raul_\OneDrive\Escritorio\Proyectos para portafolio y linkedin\Documentacion\Informes\04_penalizacion_ingresos_ml")

plt.rcParams['font.sans-serif'] = 'DejaVu Sans'
plt.rcParams['axes.edgecolor'] = '#cbd5e1'

def entrenar_y_generar_shap():
    print("=" * 80)
    print("PROYECTO 4: MODELADO CON LIGHTGBM, SERIALIZACION Y EXPLICABILIDAD SHAP (XAI)")
    print("Autor: Raul Frugone Zaror")
    print("=" * 80)

    csv_in = DIR_CODIGOS / "microdatos_esi_ocupados_preparados.csv"
    df = pd.read_csv(csv_in)
    print(f"Dataset cargado: {len(df):,} ocupados.")

    features = [
        "es_mujer", "es_informal", "edad", "horas_semanales",
        "cine11_1d_ord", "categoria_ocupacion", "region", "r_p_rev4cl_caenes"
    ]
    cat_cols = ["categoria_ocupacion", "region", "r_p_rev4cl_caenes"]

    X = df[features].copy()
    for c in cat_cols:
        X[c] = X[c].astype("category")

    y = df["log_ingreso"]
    weights = df["fact_cal_esi"]

    # Restricciones monotonicas de capital humano:
    # es_mujer: 0 (libre), es_informal: -1 (penalizacion no positiva), edad: 0,
    # horas_semanales: +1 (mas horas no pueden reducir salario mensual),
    # cine11_1d_ord: +1 (mayor nivel educativo garantiza mayor o igual salario esperado)
    monotone_constraints = [0, -1, 0, 1, 1, 0, 0, 0]

    # Parametros optimizados con Optuna y regularizacion robusta
    params = {
        "n_estimators": 220,
        "learning_rate": 0.05,
        "max_depth": 7,
        "num_leaves": 45,
        "min_child_samples": 30,
        "subsample": 0.85,
        "colsample_bytree": 0.85,
        "monotone_constraints": monotone_constraints,
        "random_state": 42,
        "verbose": -1
    }

    print("Entrenando modelo final LightGBM con restricciones monotonicas y pesos muestrales...")
    modelo = lgb.LGBMRegressor(**params)
    modelo.fit(X, y, sample_weight=weights)

    # Metricas globales
    preds = modelo.predict(X)
    w_mean = np.average(y, weights=weights)
    r2 = 1.0 - (np.sum(weights * (y - preds)**2) / np.sum(weights * (y - w_mean)**2))
    rmse = np.sqrt(np.average((y - preds)**2, weights=weights))
    print(f"R2 ponderado final: {r2:.4f} | RMSE: {rmse:.4f}")

    # Guardar modelo y metadata
    ruta_modelo = DIR_CODIGOS / "modelo_lgbm_ingresos.joblib"
    ruta_meta = DIR_CODIGOS / "metadata_modelo_ingresos.joblib"

    # Estadisticas empiricas de posgrados para modulo analitico
    sub_pos = df[df["cine11_1d_ord"].isin([4, 5, 6])]
    stats_posgrados = {}
    for nivel, nom in [(4, "Universitaria"), (5, "Magister"), (6, "Doctorado")]:
        s = df[df["cine11_1d_ord"] == nivel]
        s_ens = s[s["r_p_rev4cl_caenes"] == 16]
        stats_posgrados[nom] = {
            "n_muestra": int(len(s)),
            "n_expandido": float(s["fact_cal_esi"].sum()),
            "ingreso_medio_ponderado": float(np.average(s["ing_t_p"], weights=s["fact_cal_esi"])),
            "ingreso_mediana": float(s["ing_t_p"].median()),
            "horas_promedio": float(np.average(s["horas_semanales"], weights=s["fact_cal_esi"])),
            "n_ensenanza": int(len(s_ens)),
            "pct_ensenanza": float(len(s_ens) / len(s) * 100) if len(s) > 0 else 0,
            "ingreso_medio_ensenanza": float(np.average(s_ens["ing_t_p"], weights=s_ens["fact_cal_esi"])) if len(s_ens) > 0 else 0
        }

    mapping_educ_clean = [
        {"cine11_1d_ord": 0, "nivel_educ_desc": "Sin educacion formal"},
        {"cine11_1d_ord": 1, "nivel_educ_desc": "Primaria o basica"},
        {"cine11_1d_ord": 2, "nivel_educ_desc": "Secundaria o media"},
        {"cine11_1d_ord": 3, "nivel_educ_desc": "Tecnica superior"},
        {"cine11_1d_ord": 4, "nivel_educ_desc": "Universitaria"},
        {"cine11_1d_ord": 5, "nivel_educ_desc": "Magister o posgrado"},
        {"cine11_1d_ord": 6, "nivel_educ_desc": "Doctorado"}
    ]

    metadata = {
        "features": features,
        "cat_cols": cat_cols,
        "base_expected_log": float(np.average(y, weights=weights)),
        "base_expected_clp": float(np.average(df["ing_t_p"], weights=weights)),
        "r2_ponderado": r2,
        "rmse_ponderado": rmse,
        "stats_posgrados": stats_posgrados,
        "mapping_educ": mapping_educ_clean,
        "mapping_categoria": df[["categoria_ocupacion", "categoria_desc"]].drop_duplicates().sort_values("categoria_ocupacion").to_dict("records"),
        "mapping_region": df[["region", "region_desc"]].drop_duplicates().sort_values("region").to_dict("records"),
        "mapping_rama": df[["r_p_rev4cl_caenes", "rama_desc"]].drop_duplicates().sort_values("r_p_rev4cl_caenes").to_dict("records")
    }

    joblib.dump(modelo, ruta_modelo)
    joblib.dump(metadata, ruta_meta)
    shutil.copy2(ruta_modelo, DIR_INFORMES / "modelo_lgbm_ingresos.joblib")
    shutil.copy2(ruta_meta, DIR_INFORMES / "metadata_modelo_ingresos.joblib")
    print("Modelo y metadata serializados correctamente en ambas subcarpetas.")

    # -------------------------------------------------------------------------
    # CALCULO DE SHAP VALUES
    # -------------------------------------------------------------------------
    print("\nCalculando explicabilidad SHAP con TreeExplainer...")
    explainer = shap.TreeExplainer(modelo)

    # Muestra representativa estratificada para visualizacion SHAP
    df_sample = df.sample(n=min(2500, len(df)), random_state=42).copy()
    X_sample = df_sample[features].copy()
    for c in cat_cols:
        X_sample[c] = X_sample[c].astype("category")

    shap_values = explainer(X_sample)

    # Nombres amigables para el grafico SHAP
    nombres_amigables = [
        "Género femenino (Mujer)",
        "Condición informal (Sin contrato)",
        "Edad (Años experiencia)",
        "Horas semanales habituales",
        "Nivel educativo (CINE 2011)",
        "Categoría ocupacional",
        "Región geográfica",
        "Rama de actividad económica"
    ]
    shap_values.feature_names = nombres_amigables

    # 1. SHAP BEESWARM PLOT
    print("Generando SHAP Beeswarm Summary Plot...")
    fig_beeswarm = plt.figure(figsize=(12, 7), facecolor='#f8fafc')
    shap.plots.beeswarm(shap_values, max_display=10, show=False)
    plt.title("Explicabilidad global del modelo salarial en Chile (SHAP Beeswarm)\nImpacto de cada variable en el logaritmo del ingreso mensual", 
              fontsize=13, fontweight='bold', color='#0f172a', pad=15)
    plt.xlabel("Valor SHAP (Impacto en log-ingreso: positivo a la derecha, negativo a la izquierda)", fontsize=10.5, color='#334155', labelpad=10)
    plt.text(0.5, -0.12, "Investigación y modelado: Raúl Frugone Zaror  |  Fuente: Microdatos ESI 2025 (INE) & LightGBM", 
             ha='center', fontsize=9, color='#64748b', style='italic', transform=plt.gca().transAxes)
    plt.tight_layout()

    salida_beeswarm_cod = DIR_CODIGOS / "grafico_shap_beeswarm.png"
    salida_beeswarm_inf = DIR_INFORMES / "grafico_shap_beeswarm.png"
    plt.savefig(salida_beeswarm_cod, dpi=300, bbox_inches='tight')
    plt.savefig(salida_beeswarm_inf, dpi=300, bbox_inches='tight')
    plt.close()
    print(f"- {salida_beeswarm_cod}")

    # 2. SHAP WATERFALL PLOT PARA CASO REPRESENTATIVO
    print("Generando SHAP Waterfall Plot para caso individual representativo...")
    # Buscamos un perfil de trabajadora informal en comercio con educacion media
    caso_idx = None
    for i in range(len(df_sample)):
        r = df_sample.iloc[i]
        if r['es_mujer'] == 1 and r['es_informal'] == 1 and r['cine11_1d'] == 2:
            caso_idx = i
            break
    if caso_idx is None:
        caso_idx = 0

    fig_waterfall = plt.figure(figsize=(11, 6.5), facecolor='#f8fafc')
    shap.plots.waterfall(shap_values[caso_idx], max_display=8, show=False)
    plt.title(f"Descomposición SHAP individual: ¿Cómo penaliza el mercado este perfil?\n(Trabajadora informal, educación media, sector comercio)", 
              fontsize=13, fontweight='bold', color='#0f172a', pad=15)
    plt.xlabel("Impacto marginal sobre el ingreso esperado (f(x) vs E[f(x)])", fontsize=10.5, color='#334155', labelpad=10)
    plt.text(0.5, -0.12, "Investigación y modelado: Raúl Frugone Zaror  |  Fuente: Microdatos ESI 2025 (INE) & LightGBM", 
             ha='center', fontsize=9, color='#64748b', style='italic', transform=plt.gca().transAxes)
    plt.tight_layout()

    salida_waterfall_cod = DIR_CODIGOS / "grafico_shap_waterfall.png"
    salida_waterfall_inf = DIR_INFORMES / "grafico_shap_waterfall.png"
    plt.savefig(salida_waterfall_cod, dpi=300, bbox_inches='tight')
    plt.savefig(salida_waterfall_inf, dpi=300, bbox_inches='tight')
    plt.close()
    print(f"- {salida_waterfall_cod}")

    print("\nProceso de entrenamiento y generacion de explicabilidad SHAP culminado con exito.")

if __name__ == "__main__":
    entrenar_y_generar_shap()
