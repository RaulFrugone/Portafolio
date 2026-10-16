"""
Modulo de generacion de visualizaciones interactivas y notebook reproducible
Proyecto: El costo oculto: ingresos y calidad del empleo
Autor: Raul Frugone Zaror
"""

import json
import shutil
from pathlib import Path
import numpy as np
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import matplotlib.pyplot as plt
import seaborn as sns

DIR_CODIGOS = Path(__file__).resolve().parent
DIR_INFORMES = Path(r"c:\Users\raul_\OneDrive\Escritorio\Proyectos para portafolio y linkedin\Documentacion\Informes\04_penalizacion_ingresos_ml")


def generar_visualizaciones():
    """
    Genera graficos interactivos en HTML y estaticos en PNG sobre las brechas de ingresos.
    """
    csv_preparado = DIR_CODIGOS / "microdatos_esi_ocupados_preparados.csv"
    excel_metricas = DIR_CODIGOS / "metrics_penalizacion_ingresos.xlsx"

    print("Cargando datos para generacion de graficos...")
    df = pd.read_csv(csv_preparado)
    df_importancia = pd.read_excel(excel_metricas, sheet_name="Importancia_Variables_ML")
    df_ramas = pd.read_excel(excel_metricas, sheet_name="Brechas_por_Rama_Economica")

    # 1. Grafico de distribucion salarial por formalidad y genero (Plotly)
    print("1. Creando grafico interactivo de distribucion salarial...")
    df_sub = df.sample(n=min(10000, len(df)), random_state=42).copy()
    df_sub["Condicion_Laboral"] = np.where(df_sub["es_informal"] == 1, "Informal", "Formal")
    df_sub["Genero"] = np.where(df_sub["es_mujer"] == 1, "Mujer", "Hombre")
    df_sub["Segmento"] = df_sub["Condicion_Laboral"] + " - " + df_sub["Genero"]

    fig_dist = px.box(
        df_sub,
        x="Segmento",
        y="ing_t_p",
        color="Segmento",
        points="outliers",
        labels={"ing_t_p": "Ingreso mensual ocupacion principal (CLP)", "Segmento": "Segmento laboral"},
        title="Distribucion del ingreso mensual por condicion de formalidad y genero en Chile (ESI 2025)",
        color_discrete_map={
            "Formal - Hombre": "#1f77b4",
            "Formal - Mujer": "#2ca02c",
            "Informal - Hombre": "#ff7f0e",
            "Informal - Mujer": "#d62728"
        }
    )
    fig_dist.update_layout(
        template="plotly_white",
        yaxis_type="log",
        yaxis_title="Ingreso mensual (CLP, escala logaritmica)",
        showlegend=False,
        font=dict(family="Arial, sans-serif", size=12)
    )

    ruta_html_dist = DIR_CODIGOS / "grafico_distribucion_salarial_interactivo.html"
    fig_dist.write_html(str(ruta_html_dist), include_plotlyjs="cdn")
    shutil.copy2(ruta_html_dist, DIR_INFORMES / "grafico_distribucion_salarial_interactivo.html")

    # 2. Grafico de importancia de caracteristicas en LightGBM
    print("2. Creando grafico interactivo de importancia de caracteristicas...")
    map_nombres_fe = {
        "es_informal": "Condicion de informalidad laboral",
        "horas_semanales": "Horas habituales de trabajo semanal",
        "cine11_1d": "Nivel educativo maximo alcanzado (CINE)",
        "categoria_ocupacion": "Categoria ocupacional (asalariado, cuenta propia, etc.)",
        "r_p_rev4cl_caenes": "Rama de actividad economica (CAENES)",
        "edad": "Edad del trabajador (experiencia potencial)",
        "es_mujer": "Genero (Mujer vs Hombre)",
        "region": "Region geografica de residencia"
    }
    df_importancia["Nombre_Legible"] = df_importancia["Caracteristica"].map(map_nombres_fe).fillna(df_importancia["Caracteristica"])
    df_imp_sorted = df_importancia.sort_values(by="Porcentaje_Ganancia", ascending=True)

    fig_imp = px.bar(
        df_imp_sorted,
        x="Porcentaje_Ganancia",
        y="Nombre_Legible",
        orientation="h",
        text=df_imp_sorted["Porcentaje_Ganancia"].apply(lambda v: f"{v:.1f}%"),
        labels={"Porcentaje_Ganancia": "Importancia relativa en varianza explicada (% ganancia)", "Nombre_Legible": "Factor determinante"},
        title="Factores determinantes del ingreso laboral: importancia predictiva en LightGBM (ESI 2025)",
        color="Porcentaje_Ganancia",
        color_continuous_scale="Viridis"
    )
    fig_imp.update_layout(template="plotly_white", showlegend=False)

    ruta_html_imp = DIR_CODIGOS / "grafico_importancia_caracteristicas.html"
    fig_imp.write_html(str(ruta_html_imp), include_plotlyjs="cdn")
    shutil.copy2(ruta_html_imp, DIR_INFORMES / "grafico_importancia_caracteristicas.html")

    # 3. Grafico sectorial de brechas por rama economica
    print("3. Creando grafico sectorial de brechas por rama economica...")
    fig_ramas = px.scatter(
        df_ramas,
        x="Tasa_Informalidad_Pct",
        y="Brecha_Genero_Pct",
        size="Total_Trabajadores_Expandido",
        color="Ingreso_Medio_Formal_CLP",
        hover_name="Rama_Economica",
        labels={
            "Tasa_Informalidad_Pct": "Tasa de informalidad sectorial (%)",
            "Brecha_Genero_Pct": "Brecha de genero salarial (%)",
            "Ingreso_Medio_Formal_CLP": "Ingreso medio formal (CLP)",
            "Total_Trabajadores_Expandido": "Ocupados representados"
        },
        title="Vulnerabilidad sectorial: informalidad vs brecha salarial de genero por rama economica",
        color_continuous_scale="Plasma"
    )
    fig_ramas.add_hline(y=0, line_dash="dash", line_color="gray")
    fig_ramas.update_layout(template="plotly_white")

    ruta_html_ramas = DIR_CODIGOS / "grafico_brecha_ramas_economicas.html"
    fig_ramas.write_html(str(ruta_html_ramas), include_plotlyjs="cdn")
    shutil.copy2(ruta_html_ramas, DIR_INFORMES / "grafico_brecha_ramas_economicas.html")

    # 4. Grafico estatico en PNG de perfiles edad-ingreso (Curvas Mincer)
    print("4. Generando curvas de edad-ingresos estaticas en PNG...")
    plt.figure(figsize=(10, 6))
    sns.set_theme(style="whitegrid")
    
    # Agrupacion por tramos de edad y condicion laboral
    df["tramo_edad_cat"] = pd.cut(df["edad"], bins=[15, 25, 35, 45, 55, 65, 80], labels=["15-24", "25-34", "35-44", "45-54", "55-64", "65+"])
    df_curvas = df.groupby(["tramo_edad_cat", "es_informal"], observed=True).apply(
        lambda g: np.average(g["ing_t_p"], weights=g["fact_cal_esi"])
    ).reset_index(name="ingreso_medio")
    df_curvas["Condicion"] = np.where(df_curvas["es_informal"] == 1, "Empleo informal", "Empleo formal")

    ax = sns.lineplot(data=df_curvas, x="tramo_edad_cat", y="ingreso_medio", hue="Condicion", marker="o", linewidth=2.5, palette=["#1f77b4", "#d62728"])
    plt.title("Curvas de ingreso medio segun tramo etario: formalidad vs informalidad en Chile", fontsize=13, pad=15)
    plt.xlabel("Tramo de edad (anos)", fontsize=11)
    plt.ylabel("Ingreso mensual medio ponderado (CLP)", fontsize=11)
    plt.gca().yaxis.set_major_formatter("${x:,.0f}")
    plt.tight_layout()

    ruta_png_curvas = DIR_CODIGOS / "grafico_curvas_edad_ingresos.png"
    plt.savefig(ruta_png_curvas, dpi=200)
    plt.close()
    shutil.copy2(ruta_png_curvas, DIR_INFORMES / "grafico_curvas_edad_ingresos.png")

    print("Visualizaciones interactivas y estaticas generadas exitosamente.")


def generar_jupyter_notebook():
    """
    Construye de forma programatica el cuaderno Jupyter reproducible del Proyecto 4.
    """
    print("\nConstruyendo Jupyter Notebook reproducible: analisis_brecha_ingresos_ml.ipynb...")

    cells = [
        {
            "cell_type": "markdown",
            "metadata": {},
            "source": [
                "# El costo oculto: ingresos, brecha de genero y penalizacion por informalidad laboral en Chile\n",
                "### Proyecto de modelado econometrico y machine learning explicable (ESI 2025)\n",
                "**Autor:** Raul Frugone Zaror  \n",
                "**Fecha:** Octubre 2026  \n",
                "\n",
                "---\n",
                "\n",
                "## 1. Resumen ejecutivo y contexto del problema\n",
                "Este estudio analiza la estructura salarial en Chile utilizando los microdatos oficiales de la **Encuesta Suplementaria de Ingresos (ESI 2025)** del INE.\n",
                "Se aplican dos enfoques analiticos complementarios:\n",
                "1. **Enfoque econometrico de Mincer (WLS con ponderadores muestrales):** Cuantifica el efecto neto causal ceteris paribus de la brecha de genero y la penalizacion salarial por informalidad.\n",
                "2. **Enfoque de Machine Learning (LightGBM con optimizacion Optuna):** Modela no-linealidades complejas, interacciones entre experiencia y educacion, e identifica los factores determinantes del ingreso mediante importancia de caracteristicas."
            ]
        },
        {
            "cell_type": "code",
            "execution_count": None,
            "metadata": {},
            "outputs": [],
            "source": [
                "import pandas as pd\n",
                "import numpy as np\n",
                "import statsmodels.api as sm\n",
                "import lightgbm as lgb\n",
                "from sklearn.model_selection import train_test_split\n",
                "import matplotlib.pyplot as plt\n",
                "import seaborn as sns\n",
                "\n",
                "# Cargar microdatos procesados de la ESI 2025\n",
                "df = pd.read_csv('microdatos_esi_ocupados_preparados.csv')\n",
                "print(f'Muestra ocupada analizada: {len(df):,} personas')\n",
                "print(f'Poblacion nacional expandida: {df[\"fact_cal_esi\"].sum():,.0f} trabajadores')\n",
                "df[['edad', 'horas_semanales', 'ing_t_p', 'fact_cal_esi']].describe().round(1)"
            ]
        },
        {
            "cell_type": "markdown",
            "metadata": {},
            "source": [
                "## 2. Estimacion econometrica minceriana (WLS con pesos muestrales)\n",
                "Se ajusta una ecuacion salarial de corte transversal considerando errores estandar consistentes ante heterocedasticidad (HC1):\n",
                "$$\\ln(w_i) = \\beta_0 + \\beta_1 \\text{es\\_mujer}_i + \\beta_2 \\text{es\\_informal}_i + \\beta_3 \\text{edad}_i + \\beta_4 \\text{edad}^2_i + \\beta_5 \\text{horas}_i + \\sum_k \\delta_k \\text{educ}_{ik} + \\sum_j \\gamma_j \\text{region}_{ij} + \\varepsilon_i$$"
            ]
        },
        {
            "cell_type": "code",
            "execution_count": None,
            "metadata": {},
            "outputs": [],
            "source": [
                "vars_x = ['es_mujer', 'es_informal', 'edad', 'edad_cuadrado', 'horas_semanales', 'cine11_1d', 'region']\n",
                "X_wls = pd.get_dummies(df[vars_x], columns=['cine11_1d', 'region'], drop_first=True, dtype=float)\n",
                "X_wls = sm.add_constant(X_wls)\n",
                "y = df['log_ingreso']\n",
                "weights = df['fact_cal_esi']\n",
                "\n",
                "modelo_wls = sm.WLS(y, X_wls, weights=weights).fit(cov_type='HC1')\n",
                "print(f'R2 Ponderado del modelo Minceriano: {modelo_wls.rsquared:.4f}')\n",
                "\n",
                "coef_mujer = modelo_wls.params['es_mujer']\n",
                "coef_informal = modelo_wls.params['es_informal']\n",
                "print(f'Efecto neto penalizacion genero (Mujer vs Hombre): {(np.exp(coef_mujer) - 1)*100:.2f}% (p-val: {modelo_wls.pvalues[\"es_mujer\"]:.2e})')\n",
                "print(f'Efecto neto penalizacion por empleo informal: {(np.exp(coef_informal) - 1)*100:.2f}% (p-val: {modelo_wls.pvalues[\"es_informal\"]:.2e})')"
            ]
        },
        {
            "cell_type": "markdown",
            "metadata": {},
            "source": [
                "## 3. Modelo de Machine Learning: LightGBM con pesos muestrales\n",
                "Entrenamos un modelo de gradient boosting con `sample_weight` para capturar patrones no lineales y de interaccion sectorial."
            ]
        },
        {
            "cell_type": "code",
            "execution_count": None,
            "metadata": {},
            "outputs": [],
            "source": [
                "features_ml = ['es_mujer', 'es_informal', 'edad', 'horas_semanales', 'cine11_1d', 'categoria_ocupacion', 'region', 'r_p_rev4cl_caenes']\n",
                "X_ml = df[features_ml].copy()\n",
                "for c in ['cine11_1d', 'categoria_ocupacion', 'region', 'r_p_rev4cl_caenes']:\n",
                "    X_ml[c] = X_ml[c].astype('category')\n",
                "\n",
                "X_train, X_test, y_train, y_test, w_train, w_test = train_test_split(\n",
                "    X_ml, y, weights, test_size=0.2, random_state=42, stratify=df[['es_mujer', 'es_informal']]\n",
                ")\n",
                "\n",
                "lgb_model = lgb.LGBMRegressor(\n",
                "    n_estimators=180, learning_rate=0.06, max_depth=6, num_leaves=35, random_state=42, verbose=-1\n",
                ")\n",
                "lgb_model.fit(X_train, y_train, sample_weight=w_train)\n",
                "\n",
                "y_pred = lgb_model.predict(X_test)\n",
                "w_mean = np.average(y_test, weights=w_test)\n",
                "r2_test = 1.0 - (np.sum(w_test * (y_test - y_pred)**2) / np.sum(w_test * (y_test - w_mean)**2))\n",
                "rmse_test = np.sqrt(np.average((y_test - y_pred)**2, weights=w_test))\n",
                "print(f'R2 Ponderado en conjunto Test: {r2_test:.4f}')\n",
                "print(f'RMSE Ponderado en conjunto Test: {rmse_test:.4f}')"
            ]
        },
        {
            "cell_type": "markdown",
            "metadata": {},
            "source": [
                "## 4. Importancia de caracteristicas y explicabilidad\n",
                "Evaluacion de la ganancia relativa de cada variable en la reduccion de error del modelo."
            ]
        },
        {
            "cell_type": "code",
            "execution_count": None,
            "metadata": {},
            "outputs": [],
            "source": [
                "imp = pd.Series(lgb_model.booster_.feature_importance(importance_type='gain'), index=features_ml)\n",
                "imp_pct = (imp / imp.sum()) * 100\n",
                "imp_pct.sort_values(ascending=True).plot(kind='barh', figsize=(8, 4), color='#1f77b4')\n",
                "plt.title('Importancia de caracteristicas en la explicacion del ingreso laboral (% ganancia)')\n",
                "plt.xlabel('Porcentaje de ganancia')\n",
                "plt.tight_layout()\n",
                "plt.show()"
            ]
        }
    ]

    notebook_content = {
        "cells": cells,
        "metadata": {
            "language_info": {
                "name": "python",
                "version": "3.11"
            },
            "authors": [{"name": "Raul Frugone Zaror"}]
        },
        "nbformat": 4,
        "nbformat_minor": 4
    }

    ruta_nb_codigos = DIR_CODIGOS / "analisis_brecha_ingresos_ml.ipynb"
    ruta_nb_informes = DIR_INFORMES / "analisis_brecha_ingresos_ml.ipynb"

    with open(ruta_nb_codigos, "w", encoding="utf-8") as f:
        json.dump(notebook_content, f, indent=2, ensure_ascii=False)

    shutil.copy2(ruta_nb_codigos, ruta_nb_informes)
    print("Notebook Jupyter generado y duplicado exitosamente.")


if __name__ == "__main__":
    generar_visualizaciones()
    generar_jupyter_notebook()
