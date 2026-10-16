"""
Modulo de preparacion y feature engineering de microdatos ESI 2025
Proyecto: El costo oculto: ingresos y calidad del empleo
Autor: Raul Frugone Zaror
"""

import os
import shutil
from pathlib import Path
import numpy as np
import pandas as pd

# Rutas de origen y destino
RUTA_ORIGEN_ESI = Path(r"C:\Users\raul_\OneDrive\Escritorio\Proyectos Portafolio y Linkedn\ESI\esi_2025_personas.csv")
DIR_CODIGOS = Path(__file__).resolve().parent
DIR_INFORMES = Path(r"c:\Users\raul_\OneDrive\Escritorio\Proyectos para portafolio y linkedin\Documentacion\Informes\04_penalizacion_ingresos_ml")

# Diccionarios de mapeo para explicabilidad
MAP_REGIONES = {
    1: "Tarapaca",
    2: "Antofagasta",
    3: "Atacama",
    4: "Coquimbo",
    5: "Valparaiso",
    6: "O'Higgins",
    7: "Maule",
    8: "Biobio",
    9: "La Araucania",
    10: "Los Lagos",
    11: "Aysen",
    12: "Magallanes",
    13: "Metropolitana",
    14: "Los Rios",
    15: "Arica y Parinacota",
    16: "Nuble"
}

MAP_CINE = {
    0: "Sin educacion formal",
    1: "Primaria o basica",
    2: "Secundaria o media",
    3: "Tecnica superior",
    4: "Universitaria",
    5: "Magister o posgrado",
    6: "Doctorado",
    9: "No sabe / no responde"
}

MAP_CATEGORIA = {
    1: "Empleador",
    2: "Cuenta propia",
    3: "Asalariado privado",
    4: "Asalariado publico",
    5: "Servicio domestico",
    6: "Familiar no remunerado",
    7: "Otro",
    0: "No clasificado"
}

MAP_CAENES = {
    1: "Agricultura, ganaderia y pesca",
    2: "Explotacion de minas y canteras",
    3: "Industria manufacturera",
    4: "Suministro de electricidad y gas",
    5: "Suministro de agua y desechos",
    6: "Construccion",
    7: "Comercio al por mayor y menor",
    8: "Transporte y almacenamiento",
    9: "Alojamiento y servicios de comidas",
    10: "Informacion y comunicaciones",
    11: "Actividades financieras y de seguros",
    12: "Actividades inmobiliarias",
    13: "Servicios profesionales y cientificos",
    14: "Servicios administrativos y apoyo",
    15: "Administracion publica y defensa",
    16: "Ensenanza",
    17: "Salud humana y asistencia social",
    18: "Actividades artisticas y entretenimiento",
    19: "Otras actividades de servicios",
    20: "Hogares privados como empleadores",
    21: "Organizaciones extraterritoriales",
    999: "No clasificado"
}


def cargar_y_limpiar_esi():
    """
    Carga y procesa la muestra ocupada de la Encuesta Suplementaria de Ingresos (ESI) 2025.
    """
    if not RUTA_ORIGEN_ESI.exists():
        raise FileNotFoundError(f"No se encuentra el archivo fuente en: {RUTA_ORIGEN_ESI}")

    columnas_clave = [
        "id_identificacion", "hogar", "nro_linea", "region", "sexo", "edad",
        "habituales", "b1", "cine11_1d", "categoria_ocupacion", "ocup_form", "sector",
        "r_p_rev4cl_caenes", "fact_cal_esi", "ing_t_p"
    ]

    print(f"Cargando microdatos ESI 2025 desde {RUTA_ORIGEN_ESI.name}...")
    df = pd.read_csv(RUTA_ORIGEN_ESI, usecols=columnas_clave, sep=None, engine="python")
    print(f"Total registros cargados de la encuesta: {len(df):,}")

    # Filtrar poblacion ocupada con ingreso laboral positivo y factor de expansion valido
    df_ocup = df[
        (df["ocup_form"].isin([1, 2])) & 
        (df["ing_t_p"] > 0) & 
        (df["fact_cal_esi"] > 0)
    ].copy()

    print(f"Registros de personas ocupadas con ingresos laborales positivos: {len(df_ocup):,}")

    # Limpieza rigurosa de horas habituales trabajadas (habituales: 1 a 84 horas)
    mediana_horas = df_ocup.loc[(df_ocup["habituales"] >= 1) & (df_ocup["habituales"] <= 84), "habituales"].median()
    df_ocup["horas_semanales"] = df_ocup["habituales"].apply(lambda x: x if (1 <= x <= 84) else mediana_horas)

    # Transformaciones y variables explicativas
    df_ocup["log_ingreso"] = np.log(df_ocup["ing_t_p"])
    df_ocup["es_mujer"] = (df_ocup["sexo"] == 2).astype(int)
    df_ocup["es_informal"] = (df_ocup["ocup_form"] == 2).astype(int)
    df_ocup["edad_cuadrado"] = (df_ocup["edad"] ** 2) / 100.0

    # Escala ordinal de educacion para capital humano (Mincer / Becker)
    df_ocup["cine11_1d_ord"] = df_ocup["cine11_1d"].apply(lambda x: 2 if x not in [0, 1, 2, 3, 4, 5, 6] else int(x))

    # Grupo ocupacional CIUO-08 (columna b1 de la encuesta)
    df_ocup["ciuo_grupo"] = df_ocup["b1"].fillna(df_ocup["b1"].median()).astype(int)

    # Mapeos descriptivos
    df_ocup["region_desc"] = df_ocup["region"].map(MAP_REGIONES).fillna("Otra")
    df_ocup["nivel_educ_desc"] = df_ocup["cine11_1d"].map(MAP_CINE).fillna("Otro")
    df_ocup["categoria_desc"] = df_ocup["categoria_ocupacion"].map(MAP_CATEGORIA).fillna("Otra")
    df_ocup["rama_desc"] = df_ocup["r_p_rev4cl_caenes"].map(MAP_CAENES).fillna("Otra")

    # Salarios por hora estimados
    df_ocup["ingreso_hora"] = df_ocup["ing_t_p"] / (df_ocup["horas_semanales"] * 4.33).replace(0, np.nan)
    df_ocup["log_ingreso_hora"] = np.log(df_ocup["ingreso_hora"].replace(0, np.nan))

    # Guardar dataset procesado
    DIR_CODIGOS.mkdir(parents=True, exist_ok=True)
    DIR_INFORMES.mkdir(parents=True, exist_ok=True)

    archivo_csv_codigos = DIR_CODIGOS / "microdatos_esi_ocupados_preparados.csv"
    archivo_csv_informes = DIR_INFORMES / "microdatos_esi_ocupados_preparados.csv"

    print("Guardando dataset procesado en subcarpetas de Codigos e Informes...")
    df_ocup.to_csv(archivo_csv_codigos, index=False, encoding="utf-8")
    shutil.copy2(archivo_csv_codigos, archivo_csv_informes)

    # Resumen representativo ponderado
    total_expandido = df_ocup["fact_cal_esi"].sum()
    w_formal = df_ocup[df_ocup["es_informal"] == 0]["fact_cal_esi"].sum()
    w_informal = df_ocup[df_ocup["es_informal"] == 1]["fact_cal_esi"].sum()

    ing_medio_formal = np.average(df_ocup[df_ocup["es_informal"] == 0]["ing_t_p"], weights=df_ocup[df_ocup["es_informal"] == 0]["fact_cal_esi"])
    ing_medio_informal = np.average(df_ocup[df_ocup["es_informal"] == 1]["ing_t_p"], weights=df_ocup[df_ocup["es_informal"] == 1]["fact_cal_esi"])

    ing_medio_hombres = np.average(df_ocup[df_ocup["es_mujer"] == 0]["ing_t_p"], weights=df_ocup[df_ocup["es_mujer"] == 0]["fact_cal_esi"])
    ing_medio_mujeres = np.average(df_ocup[df_ocup["es_mujer"] == 1]["ing_t_p"], weights=df_ocup[df_ocup["es_mujer"] == 1]["fact_cal_esi"])

    print("\n--- Resumen de representatividad nacional expandida (ESI 2025) ---")
    print(f"Poblacion ocupada expandida total: {total_expandido:,.0f} trabajadores")
    print(f"Ocupados formales expandidos: {w_formal:,.0f} ({w_formal/total_expandido*100:.1f}%)")
    print(f"Ocupados informales expandidos: {w_informal:,.0f} ({w_informal/total_expandido*100:.1f}%)")
    print(f"Ingreso medio formal ponderado: ${ing_medio_formal:,.0f} CLP")
    print(f"Ingreso medio informal ponderado: ${ing_medio_informal:,.0f} CLP")
    print(f"Penalizacion salarial bruta por informalidad: {(ing_medio_informal/ing_medio_formal - 1)*100:.1f}%")
    print(f"Ingreso medio hombres ponderado: ${ing_medio_hombres:,.0f} CLP")
    print(f"Ingreso medio mujeres ponderado: ${ing_medio_mujeres:,.0f} CLP")
    print(f"Brecha salarial bruta de genero: {(ing_medio_mujeres/ing_medio_hombres - 1)*100:.1f}%")

    return df_ocup


if __name__ == "__main__":
    cargar_y_limpiar_esi()
