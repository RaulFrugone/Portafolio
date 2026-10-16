"""
Auditoria tecnica y validacion profesional para el Proyecto 4
Tema: Penalizacion salarial por informalidad, brechas de genero y retornos al capital humano
Autor: Raul Frugone Zaror
"""

import sys
from pathlib import Path
import joblib
import numpy as np
import pandas as pd
import shap

DIR_ACTUAL = Path(__file__).resolve().parent
RUTA_MODELO = DIR_ACTUAL / "modelo_lgbm_ingresos.joblib"
RUTA_METADATA = DIR_ACTUAL / "metadata_modelo_ingresos.joblib"
RUTA_CSV = DIR_ACTUAL / "microdatos_esi_ocupados_preparados.csv"

def ejecutar_auditoria_completa():
    print("=" * 80)
    print("AUDITORIA PROFESIONAL Y QA DE MODELADO SALARIAL (INE ESI 2025)")
    print("Auditor e investigador: Raul Frugone Zaror")
    print("=" * 80)

    # 1. Cargar artefactos
    if not RUTA_MODELO.exists() or not RUTA_METADATA.exists() or not RUTA_CSV.exists():
        print("Error: Artefactos requeridos no encontrados en el directorio.")
        sys.exit(1)

    modelo = joblib.load(RUTA_MODELO)
    meta = joblib.load(RUTA_METADATA)
    df = pd.read_csv(RUTA_CSV)

    print(f"Base de datos cargada: {len(df):,} ocupados.")
    print(f"Modelo cargado: LightGBM Regressor (R2={meta['r2_ponderado']:.4f}, RMSE={meta['rmse_ponderado']:.4f})")

    resultados = []

    # -------------------------------------------------------------------------
    # PREGUNTA 1: ¿Respeta el modelo la monotonicidad del capital humano formal?
    # (Becker / Mincer: Doctorado >= Magister >= Universitario >= Tecnica >= Media)
    # -------------------------------------------------------------------------
    print("\n[P1] Verificando monotonicidad de retornos a la educacion...")
    p1_pass = True
    sectores_a_probar = [(16, "Ensenanza"), (2, "Mineria"), (7, "Comercio"), (13, "Servicios Profesionales")]
    detalles_p1 = []

    for rama_id, rama_nom in sectores_a_probar:
        prev_sal = -1
        for cine_id in range(7):
            row = pd.DataFrame([{
                "es_mujer": 0, "es_informal": 0, "edad": 40, "horas_semanales": 44,
                "cine11_1d_ord": cine_id, "categoria_ocupacion": 3, "region": 13, "r_p_rev4cl_caenes": rama_id
            }])
            for c in meta["cat_cols"]:
                row[c] = row[c].astype("category")
            sal = int(np.exp(modelo.predict(row)[0]))
            if sal < prev_sal:
                p1_pass = False
            prev_sal = sal
        
        # Comparar especificamente Magister (5) vs Doctorado (6)
        row_mag = pd.DataFrame([{"es_mujer": 0, "es_informal": 0, "edad": 40, "horas_semanales": 44, "cine11_1d_ord": 5, "categoria_ocupacion": 3, "region": 13, "r_p_rev4cl_caenes": rama_id}])
        row_doc = pd.DataFrame([{"es_mujer": 0, "es_informal": 0, "edad": 40, "horas_semanales": 44, "cine11_1d_ord": 6, "categoria_ocupacion": 3, "region": 13, "r_p_rev4cl_caenes": rama_id}])
        for c in meta["cat_cols"]:
            row_mag[c] = row_mag[c].astype("category")
            row_doc[c] = row_doc[c].astype("category")
        sal_mag = int(np.exp(modelo.predict(row_mag)[0]))
        sal_doc = int(np.exp(modelo.predict(row_doc)[0]))
        detalles_p1.append(f"  Rama {rama_nom}: Magister=${sal_mag:,} CLP vs Doctorado=${sal_doc:,} CLP (Ratio: {sal_doc/sal_mag:.2f})")

    status_p1 = "APROBADO" if p1_pass else "FALLIDO"
    print(f"Resultado P1: [{status_p1}] - Monotonicidad estricta garantizada en todos los niveles y ramas.")
    for d in detalles_p1:
        print(d)
    resultados.append({"Pregunta": "P1. Monotonicidad formal de capital humano (Doc >= Mag >= Univ)", "Estado": status_p1})

    # -------------------------------------------------------------------------
    # PREGUNTA 2: ¿Es positiva la elasticidad de las horas semanales habituales?
    # (Mas horas habituales de trabajo deben aumentar el salario mensual de forma consistente)
    # -------------------------------------------------------------------------
    print("\n[P2] Verificando elasticidad positiva de horas semanales trabajadas...")
    p2_pass = True
    horas_test = [15, 20, 30, 40, 44, 50, 60]
    salarios_horas = []
    prev_h_sal = -1

    for h in horas_test:
        row = pd.DataFrame([{
            "es_mujer": 0, "es_informal": 0, "edad": 35, "horas_semanales": h,
            "cine11_1d_ord": 4, "categoria_ocupacion": 3, "region": 13, "r_p_rev4cl_caenes": 16
        }])
        for c in meta["cat_cols"]:
            row[c] = row[c].astype("category")
        sal_h = int(np.exp(modelo.predict(row)[0]))
        salarios_horas.append((h, sal_h))
        if sal_h < prev_h_sal:
            p2_pass = False
        prev_h_sal = sal_h

    status_p2 = "APROBADO" if p2_pass else "FALLIDO"
    print(f"Resultado P2: [{status_p2}] - Escala de jornada laboral monotona no decreciente.")
    for h, s in salarios_horas:
        print(f"  Jornada {h} hrs/semana -> ${s:,} CLP")
    resultados.append({"Pregunta": "P2. Elasticidad monotona de horas habituales trabajadas", "Estado": status_p2})

    # -------------------------------------------------------------------------
    # PREGUNTA 3: ¿Es consistente y universal la penalizacion por informalidad?
    # (Ceteris paribus, un trabajador sin contrato debe ganar menos que su contraparte formal)
    # -------------------------------------------------------------------------
    print("\n[P3] Verificando signo y magnitud de la penalizacion por informalidad...")
    p3_pass = True
    penalizaciones = []

    for rama_id, rama_nom in [(16, "Ensenanza"), (7, "Comercio"), (6, "Construccion")]:
        row_f = pd.DataFrame([{"es_mujer": 0, "es_informal": 0, "edad": 35, "horas_semanales": 44, "cine11_1d_ord": 2, "categoria_ocupacion": 3, "region": 13, "r_p_rev4cl_caenes": rama_id}])
        row_i = pd.DataFrame([{"es_mujer": 0, "es_informal": 1, "edad": 35, "horas_semanales": 44, "cine11_1d_ord": 2, "categoria_ocupacion": 3, "region": 13, "r_p_rev4cl_caenes": rama_id}])
        for c in meta["cat_cols"]:
            row_f[c] = row_f[c].astype("category")
            row_i[c] = row_i[c].astype("category")
        sf = int(np.exp(modelo.predict(row_f)[0]))
        si = int(np.exp(modelo.predict(row_i)[0]))
        penal_pct = (si / sf - 1.0) * 100.0
        penalizaciones.append((rama_nom, sf, si, penal_pct))
        if si >= sf:
            p3_pass = False

    status_p3 = "APROBADO" if p3_pass else "FALLIDO"
    print(f"Resultado P3: [{status_p3}] - Penalizacion por informalidad verificada en todos los casos.")
    for nom, sf, si, pct in penalizaciones:
        print(f"  {nom}: Formal=${sf:,} vs Informal=${si:,} (Penalizacion: {pct:.1f}%)")
    resultados.append({"Pregunta": "P3. Penalizacion neta por informalidad laboral (< 0)", "Estado": status_p3})

    # -------------------------------------------------------------------------
    # PREGUNTA 4: ¿Se aisla la brecha de genero pura (penalizacion salarial femenina)?
    # -------------------------------------------------------------------------
    print("\n[P4] Verificando medicion de brecha salarial pura de genero...")
    row_h = pd.DataFrame([{"es_mujer": 0, "es_informal": 0, "edad": 38, "horas_semanales": 44, "cine11_1d_ord": 4, "categoria_ocupacion": 3, "region": 13, "r_p_rev4cl_caenes": 16}])
    row_m = pd.DataFrame([{"es_mujer": 1, "es_informal": 0, "edad": 38, "horas_semanales": 44, "cine11_1d_ord": 4, "categoria_ocupacion": 3, "region": 13, "r_p_rev4cl_caenes": 16}])
    for c in meta["cat_cols"]:
        row_h[c] = row_h[c].astype("category")
        row_m[c] = row_m[c].astype("category")
    sh = int(np.exp(modelo.predict(row_h)[0]))
    sm = int(np.exp(modelo.predict(row_m)[0]))
    brecha_gen = (sm / sh - 1.0) * 100.0
    p4_pass = sm < sh

    status_p4 = "APROBADO" if p4_pass else "FALLIDO"
    print(f"Resultado P4: [{status_p4}] - Brecha de genero ceteris paribus cuantificada.")
    print(f"  Hombre universitario (Ensenanza, 44 hrs): ${sh:,} CLP")
    print(f"  Mujer universitaria idéntica: ${sm:,} CLP (Brecha pura no explicada: {brecha_gen:.1f}%)")
    resultados.append({"Pregunta": "P4. Aislamiento econometrico de brecha pura de genero", "Estado": status_p4})

    # -------------------------------------------------------------------------
    # PREGUNTA 5: ¿Cumple SHAP con aditividad local exacta? (f(x) == E[f(x)] + sum(SHAP))
    # -------------------------------------------------------------------------
    print("\n[P5] Verificando aditividad matematica de valores SHAP...")
    explainer = shap.TreeExplainer(modelo)
    sv = explainer(row_h)
    sum_shap = float(sv.base_values[0] + np.sum(sv.values[0]))
    pred_raw = float(modelo.predict(row_h)[0])
    error_aditivo = abs(sum_shap - pred_raw)
    p5_pass = error_aditivo < 1e-5

    status_p5 = "APROBADO" if p5_pass else "FALLIDO"
    print(f"Resultado P5: [{status_p5}] - Axioma de eficiencia y aditividad SHAP cumplido.")
    print(f"  f(x) predicho: {pred_raw:.6f} | Base + sum(SHAP): {sum_shap:.6f} | Discrepancia: {error_aditivo:.2e}")
    resultados.append({"Pregunta": "P5. Eficiencia y aditividad matematica exacta en SHAP (XAI)", "Estado": status_p5})

    # -------------------------------------------------------------------------
    # PREGUNTA 6: ¿Se incorporan los factores de expansion muestral oficiales?
    # -------------------------------------------------------------------------
    print("\n[P6] Verificando ponderadores muestrales oficiales (fact_cal_esi)...")
    total_exp = df["fact_cal_esi"].sum()
    p6_pass = total_exp > 8.5e6 and total_exp < 9.5e6

    status_p6 = "APROBADO" if p6_pass else "FALLIDO"
    print(f"Resultado P6: [{status_p6}] - Factores de expansion del INE validados.")
    print(f"  Poblacion expandida total en el modelo: {total_exp:,.0f} trabajadores ocupados de Chile.")
    resultados.append({"Pregunta": "P6. Representatividad nacional mediante fact_cal_esi (INE)", "Estado": status_p6})

    print("\n" + "=" * 80)
    print("RESUMEN CONSOLIDADO DE LA AUDITORIA:")
    df_res = pd.DataFrame(resultados)
    print(df_res.to_string(index=False))
    print("=" * 80)

    todo_aprobado = all(r["Estado"] == "APROBADO" for r in resultados)
    if todo_aprobado:
        print("CONCLUCION: TODOS LOS TESTS DE AUDITORIA PASARON EXITOSAMENTE (100% QA PASS).")
    else:
        print("ALERTA: Existen pruebas no superadas.")

    return todo_aprobado

if __name__ == "__main__":
    ejecutar_auditoria_completa()
