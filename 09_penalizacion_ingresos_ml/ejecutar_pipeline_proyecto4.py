"""
Orquestador integral del pipeline del Proyecto 4
Proyecto: El costo oculto: ingresos, brecha de genero y penalizacion por informalidad laboral
Autor: Raul Frugone Zaror
"""

import sys
import time
from pathlib import Path
from importlib import import_module

DIR_ACTUAL = Path(__file__).resolve().parent
sys.path.append(str(DIR_ACTUAL))


def ejecutar_pipeline_completo():
    """
    Ejecuta secuencialmente los modulos del Proyecto 4, incluyendo explicabilidad SHAP.
    """
    print("=" * 75)
    print("INICIO DEL PIPELINE: PROYECTO 4 - MODELADO SALARIAL Y PRODUCTO INTERACTIVO")
    print("Autor: Raul Frugone Zaror")
    print("=" * 75)

    t_inicio_total = time.time()

    # Paso 1: Ingesta y Feature Engineering
    print("\n[Paso 1/4] Ingesta y preparacion de microdatos ESI 2025...")
    t0 = time.time()
    mod_ingesta = import_module("01_preparacion_microdatos_esi")
    df_ocup = mod_ingesta.cargar_y_limpiar_esi()
    print(f"Paso 1 completado en {time.time() - t0:.2f} segundos.")

    # Paso 2: Modelado Econometrico y Machine Learning Benchmark
    print("\n[Paso 2/4] Modelado econometrico (WLS) y Machine Learning (LightGBM)...")
    t0 = time.time()
    mod_modelado = import_module("02_modelado_predictivo_y_metricas")
    df_modelos, df_coefs, df_imp, df_ramas = mod_modelado.ejecutar_modelado()
    print(f"Paso 2 completado en {time.time() - t0:.2f} segundos.")

    # Paso 3: Visualizaciones y Cuaderno Jupyter
    print("\n[Paso 3/4] Generacion de visualizaciones interactivas y notebook...")
    t0 = time.time()
    mod_vis = import_module("03_generar_visualizaciones_y_notebook")
    mod_vis.generar_visualizaciones()
    mod_vis.generar_jupyter_notebook()
    print(f"Paso 3 completado en {time.time() - t0:.2f} segundos.")

    # Paso 4: Entrenamiento final, Serializacion y Explicabilidad SHAP (XAI)
    print("\n[Paso 4/5] Serializacion del modelo y calculo de valores SHAP...")
    t0 = time.time()
    mod_shap = import_module("04_entrenar_guardar_modelo_y_shap")
    mod_shap.entrenar_y_generar_shap()
    print(f"Paso 4 completado en {time.time() - t0:.2f} segundos.")

    # Paso 5: Auditoria Tecnica Profesional (QA)
    print("\n[Paso 5/5] Ejecutando auditoria tecnica profesional (QA)...")
    t0 = time.time()
    mod_audit = import_module("auditoria_profesional_proyecto4")
    mod_audit.ejecutar_auditoria_completa()
    print(f"Paso 5 completado en {time.time() - t0:.2f} segundos.")

    duracion_total = time.time() - t_inicio_total

    print("\n" + "=" * 75)
    print("RESUMEN DE VALIDACION DEL PIPELINE (PROYECTO 4)")
    print("=" * 75)
    print(f"Tiempo total de ejecucion: {duracion_total:.2f} segundos")
    print(f"Muestra analizada: {len(df_ocup):,} personas ocupadas")
    print(f"Poblacion representada expandida: {df_ocup['fact_cal_esi'].sum():,.0f} trabajadores")
    print("\nArtefactos interactivos disponibles:")
    print(" - Aplicacion web Streamlit: app_simulador_salarios.py")
    print(" - Modelo serializado: modelo_lgbm_ingresos.joblib")
    print(" - Infografia SHAP Beeswarm: grafico_shap_beeswarm.png")
    print(" - Descomposicion individual SHAP: grafico_shap_waterfall.png")
    print("=" * 75)


if __name__ == "__main__":
    ejecutar_pipeline_completo()
