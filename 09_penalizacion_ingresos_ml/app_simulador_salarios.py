"""
Aplicacion interactiva de simulacion salarial y analisis de ingresos en Chile
Proyecto 4: El costo oculto: ingresos, brecha de genero y calidad del empleo
Autor: Raul Frugone Zaror
"""

import os
from pathlib import Path
import joblib
import numpy as np
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import streamlit as st
import shap

# Configuracion de pagina
st.set_page_config(
    page_title="Simulador Salarial y Brechas (INE ESI)",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Estilo visual sobrio, moderno y limpio
st.markdown("""
<style>
    .main-header {
        font-size: 2.1rem;
        font-weight: 800;
        color: #0f172a;
        margin-bottom: 0.2rem;
    }
    .sub-header {
        font-size: 1.05rem;
        color: #475569;
        margin-bottom: 1.5rem;
    }
    .card-kpi {
        background-color: #f8fafc;
        border: 1px solid #e2e8f0;
        border-radius: 10px;
        padding: 1.2rem;
        box-shadow: 0 1px 3px rgba(0,0,0,0.04);
    }
    .kpi-title {
        font-size: 0.82rem;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        color: #64748b;
        font-weight: 700;
    }
    .kpi-val {
        font-size: 1.75rem;
        font-weight: 800;
        color: #0f172a;
        margin-top: 0.2rem;
    }
    .kpi-delta-pos {
        color: #059669;
        font-size: 0.9rem;
        font-weight: 600;
    }
    .kpi-delta-neg {
        color: #dc2626;
        font-size: 0.9rem;
        font-weight: 600;
    }
</style>
""", unsafe_allow_html=True)

# Rutas de artefactos
DIR_ACTUAL = Path(__file__).resolve().parent
RUTA_MODELO = DIR_ACTUAL / "modelo_lgbm_ingresos.joblib"
RUTA_METADATA = DIR_ACTUAL / "metadata_modelo_ingresos.joblib"
RUTA_CSV = DIR_ACTUAL / "microdatos_esi_ocupados_preparados.csv"
RUTA_METRICS = DIR_ACTUAL / "metrics_penalizacion_ingresos.xlsx"

@st.cache_resource
def cargar_modelo_y_metadata():
    if not RUTA_MODELO.exists() or not RUTA_METADATA.exists():
        st.error("No se encontraron los artefactos del modelo serializado. Por favor ejecute 04_entrenar_guardar_modelo_y_shap.py primero.")
        st.stop()
    modelo = joblib.load(RUTA_MODELO)
    meta = joblib.load(RUTA_METADATA)
    explainer = shap.TreeExplainer(modelo)
    return modelo, meta, explainer

@st.cache_data
def cargar_datos_base():
    df = pd.read_csv(RUTA_CSV)
    df_ramas = pd.read_excel(RUTA_METRICS, sheet_name="Brechas_por_Rama_Economica")
    df_comp = pd.read_excel(RUTA_METRICS, sheet_name="Comparativa_Modelos")
    return df, df_ramas, df_comp

modelo, meta, explainer = cargar_modelo_y_metadata()
df, df_ramas, df_comp = cargar_datos_base()

# Titulo principal
st.markdown('<div class="main-header">Simulador salarial y análisis de ingresos en Chile</div>', unsafe_allow_html=True)
st.markdown('<div class="sub-header">Basado en microdatos de la Encuesta Suplementaria de Ingresos (ESI 2025, INE) y Machine Learning. | Autor: <b>Raúl Frugone Zaror</b></div>', unsafe_allow_html=True)

# BARRA LATERAL: ENTRADA DE VARIABLES DEL USUARIO
st.sidebar.header("Perfil laboral a simular")
st.sidebar.markdown("Ajusta las características del trabajador para calcular en tiempo real el ingreso esperado:")

# Opciones de mapeo
dict_educ = {item['nivel_educ_desc']: item['cine11_1d_ord'] for item in meta['mapping_educ']}
dict_cat = {item['categoria_desc']: item['categoria_ocupacion'] for item in meta['mapping_categoria']}
dict_reg = {item['region_desc']: item['region'] for item in meta['mapping_region']}
dict_rama = {item['rama_desc']: item['r_p_rev4cl_caenes'] for item in meta['mapping_rama']}

# Formulario de entrada
edad = st.sidebar.slider("Edad del trabajador:", min_value=18, max_value=65, value=38, step=1)
genero_sel = st.sidebar.radio("Género:", options=["Hombre", "Mujer"], index=0)
es_mujer = 1 if genero_sel == "Mujer" else 0

form_sel = st.sidebar.radio("Situación contractual:", options=["Formal (Con contrato laboral)", "Informal (Sin contrato)"], index=0)
es_informal = 1 if "Informal" in form_sel else 0

educ_sel = st.sidebar.selectbox("Nivel educativo:", options=list(dict_educ.keys()), index=4) # Universitaria
horas = st.sidebar.slider("Horas semanales de trabajo habituales:", min_value=10, max_value=60, value=44, step=1)

cat_sel = st.sidebar.selectbox("Categoría ocupacional:", options=list(dict_cat.keys()), index=2) # Asalariado privado
rama_sel = st.sidebar.selectbox("Sector o rama económica:", options=list(dict_rama.keys()), index=15) # Ensenanza
region_sel = st.sidebar.selectbox("Región de residencia:", options=list(dict_reg.keys()), index=12) # Metropolitana

# Construir vector de entrada para prediccion
row_input = pd.DataFrame([{
    "es_mujer": es_mujer,
    "es_informal": es_informal,
    "edad": edad,
    "horas_semanales": horas,
    "cine11_1d_ord": dict_educ[educ_sel],
    "categoria_ocupacion": dict_cat[cat_sel],
    "region": dict_reg[region_sel],
    "r_p_rev4cl_caenes": dict_rama[rama_sel]
}])

for c in meta['cat_cols']:
    row_input[c] = row_input[c].astype("category")

# Prediccion log-ingreso y conversion a CLP
pred_log = modelo.predict(row_input)[0]
pred_clp = np.exp(pred_log)

# Calculos contrafactuales:
# 1. Contrafactual formalidad
row_contrafact_form = row_input.copy()
row_contrafact_form["es_informal"] = 0 if es_informal == 1 else 1
pred_log_cf_form = modelo.predict(row_contrafact_form)[0]
pred_clp_cf_form = np.exp(pred_log_cf_form)
delta_formalidad = pred_clp_cf_form - pred_clp

# 2. Contrafactual genero
row_contrafact_gen = row_input.copy()
row_contrafact_gen["es_mujer"] = 0 if es_mujer == 1 else 1
pred_log_cf_gen = modelo.predict(row_contrafact_gen)[0]
pred_clp_cf_gen = np.exp(pred_log_cf_gen)
delta_genero = pred_clp_cf_gen - pred_clp

# ORGANIZACION EN TABS
tab1, tab2, tab3, tab4 = st.tabs([
    "Calculadora salarial", 
    "Mágister vs. Doctorado en Chile", 
    "Preguntas habituales",
    "Modelos y explicabilidad (SHAP)"
])

# =============================================================================
# TAB 1: CALCULADORA SALARIAL
# =============================================================================
with tab1:
    col1, col2, col3 = st.columns(3)
    
    with col1:
        st.markdown(f"""
        <div class="card-kpi">
            <div class="kpi-title">Ingreso mensual estimado</div>
            <div class="kpi-val">${int(pred_clp):,} CLP</div>
            <div style="color: #64748b; font-size: 0.85rem; margin-top: 0.3rem;">Rango estimado habitual: ${int(pred_clp * 0.85):,} - ${int(pred_clp * 1.15):,} CLP</div>
        </div>
        """.replace(",", "."), unsafe_allow_html=True)
        
    with col2:
        if es_informal == 1:
            texto_form = f"+${abs(int(delta_formalidad)):,} CLP (+{abs(delta_formalidad/pred_clp)*100:.1f}%)"
            clase_form = "kpi-delta-pos"
            sub_form = "Ganancia estimada si pasara a tener contrato formal"
        else:
            texto_form = f"-${abs(int(delta_formalidad)):,} CLP (-{abs(delta_formalidad/pred_clp)*100:.1f}%)"
            clase_form = "kpi-delta-neg"
            sub_form = "Pérdida estimada si trabajara sin contrato formal"
            
        st.markdown(f"""
        <div class="card-kpi">
            <div class="kpi-title">Efecto de tener contrato</div>
            <div class="kpi-val {clase_form}">{texto_form}</div>
            <div style="color: #64748b; font-size: 0.85rem; margin-top: 0.3rem;">{sub_form}</div>
        </div>
        """.replace(",", "."), unsafe_allow_html=True)
        
    with col3:
        if es_mujer == 1:
            texto_gen = f"+${abs(int(delta_genero)):,} CLP (+{abs(delta_genero/pred_clp)*100:.1f}%)"
            clase_gen = "kpi-delta-pos"
            sub_gen = "Sueldo que percibiría un hombre idéntico en este perfil"
        else:
            texto_gen = f"-${abs(int(delta_genero)):,} CLP (-{abs(delta_genero/pred_clp)*100:.1f}%)"
            clase_gen = "kpi-delta-neg"
            sub_gen = "Sueldo que percibiría una mujer idéntica en este perfil"
            
        st.markdown(f"""
        <div class="card-kpi">
            <div class="kpi-title">Brecha de género en este perfil</div>
            <div class="kpi-val {clase_gen}">{texto_gen}</div>
            <div style="color: #64748b; font-size: 0.85rem; margin-top: 0.3rem;">{sub_gen}</div>
        </div>
        """.replace(",", "."), unsafe_allow_html=True)

    st.markdown("<br>", unsafe_allow_html=True)
    
    col_izq, col_der = st.columns([1.1, 1])
    
    with col_izq:
        st.subheader("Desglose del sueldo estimado")
        st.write("El gráfico muestra qué factores suman o restan dinero respecto al ingreso base nacional promedio:")
        
        # Calculo exacto de SHAP values para este vector
        sv = explainer(row_input)
        shap_vals = sv.values[0]
        base_val = sv.base_values[0]
        
        nombres_labels = [
            "Género (" + ("Mujer" if es_mujer == 1 else "Hombre") + ")",
            "Contrato (" + ("Informal" if es_informal == 1 else "Formal") + ")",
            "Edad (" + str(edad) + " años)",
            "Jornada (" + str(horas) + " hrs/sem)",
            "Estudios (" + educ_sel.split()[0] + ")",
            "Puesto (" + cat_sel.split()[0] + ")",
            "Región (" + region_sel.split()[0] + ")",
            "Sector (" + rama_sel.split()[0] + ")"
        ]
        
        wf_x = ["Sueldo base nacional"] + nombres_labels + ["Predicción final"]
        base_monto = np.exp(base_val)
        
        impactos_clp = []
        for v in shap_vals:
            impacto_monto = pred_clp * (v / np.sum(np.abs(shap_vals) + 1e-6))
            impactos_clp.append(impacto_monto)
            
        fig_wf = go.Figure(go.Waterfall(
            name="Aporte al sueldo",
            orientation="v",
            measure=["absolute"] + ["relative"] * len(shap_vals) + ["total"],
            x=wf_x,
            y=[base_monto] + impactos_clp + [pred_clp],
            connector={"line": {"color": "#94a3b8"}},
            decreasing={"marker": {"color": "#dc2626"}},
            increasing={"marker": {"color": "#059669"}},
            totals={"marker": {"color": "#1e3a8a"}}
        ))
        fig_wf.update_layout(
            template="plotly_white",
            yaxis_title="Sueldo estimado ($ CLP)",
            margin=dict(t=20, b=40, l=40, r=20),
            height=420
        )
        st.plotly_chart(fig_wf, use_container_width=True)

    with col_der:
        st.subheader("¿Cómo cambia el sueldo según las horas trabajadas?")
        st.write("Observa cómo varía el sueldo mensual al modificar la cantidad de horas semanales para este perfil:")
        
        rango_horas = list(range(10, 61, 2))
        salarios_sim = []
        for h_test in rango_horas:
            row_test = row_input.copy()
            row_test["horas_semanales"] = h_test
            for c in meta['cat_cols']:
                row_test[c] = row_test[c].astype("category")
            salarios_sim.append(int(np.exp(modelo.predict(row_test)[0])))
            
        df_horas_plot = pd.DataFrame({
            "Horas_Semanales": rango_horas,
            "Salario_Estimado_CLP": salarios_sim
        })
        
        fig_h = px.line(
            df_horas_plot,
            x="Horas_Semanales",
            y="Salario_Estimado_CLP",
            labels={"Horas_Semanales": "Horas semanales trabajadas", "Salario_Estimado_CLP": "Sueldo mensual ($ CLP)"},
            color_discrete_sequence=["#2563eb"]
        )
        fig_h.add_trace(go.Scatter(
            x=[horas],
            y=[pred_clp],
            mode="markers+text",
            text=[f"Selección: {horas} hrs (${int(pred_clp):,} CLP)"],
            textposition="top left",
            marker=dict(color="#dc2626", size=11, symbol="diamond"),
            name="Perfil seleccionado"
        ))
        fig_h.update_layout(template="plotly_white", height=420, margin=dict(t=20, b=40, l=40, r=20))
        st.plotly_chart(fig_h, use_container_width=True)

# =============================================================================
# TAB 2: MAGISTER VS. DOCTORADO EN CHILE
# =============================================================================
with tab2:
    st.subheader("Mágister vs. Doctorado en Chile")
    st.write("""
    Es común preguntarse por qué en los números generales de sueldos un doctorado no siempre parece ganar mucho más que un máster en el sector privado chileno. 
    Aquí te explicamos lo que revelan los datos reales de la encuesta del INE:
    """)
    
    col_p1, col_p2, col_p3 = st.columns(3)
    
    with col_p1:
        st.markdown(f"""
        <div class="card-kpi">
            <div class="kpi-title">Tamaño de la muestra en Chile</div>
            <div class="kpi-val" style="font-size: 1.4rem;">78 doctores vs. 732 másteres</div>
            <div style="color: #64748b; font-size: 0.85rem; margin-top: 0.3rem;">
                Los doctores son apenas el <b>0,20%</b> de la fuerza laboral encuestada, mientras que los másteres representan el <b>1,9%</b>.
            </div>
        </div>
        """, unsafe_allow_html=True)
        
    with col_p2:
        st.markdown(f"""
        <div class="card-kpi">
            <div class="kpi-title">Concentración académica</div>
            <div class="kpi-val" style="font-size: 1.4rem; color: #d97706;">65% trabaja en educación</div>
            <div style="color: #64748b; font-size: 0.85rem; margin-top: 0.3rem;">
                La gran mayoría de los doctores en Chile se desempeña en universidades y centros de estudio, donde los sueldos se rigen por escalas docentes fijas.
            </div>
        </div>
        """, unsafe_allow_html=True)

    with col_p3:
        st.markdown(f"""
        <div class="card-kpi">
            <div class="kpi-title">Presencia en empresas y minería</div>
            <div class="kpi-val" style="font-size: 1.4rem; color: #2563eb;">Másteres lideran en empresas</div>
            <div style="color: #64748b; font-size: 0.85rem; margin-top: 0.3rem;">
                En sectores como minería y finanzas, los profesionales con máster o MBA acceden a cargos ejecutivos con sueldos que superan los $8.000.000 CLP.
            </div>
        </div>
        """, unsafe_allow_html=True)

    st.markdown("<br>", unsafe_allow_html=True)
    st.subheader("Comparación entre perfiles")
    st.write("Mira cuánto cambia el sueldo estimado para una misma persona según su nivel de estudios, manteniendo exactamente igual su edad, horas, región y sector:")

    # Evaluacion de tres perfiles identicos
    row_u = row_input.copy()
    row_u["cine11_1d_ord"] = 4
    row_m = row_input.copy()
    row_m["cine11_1d_ord"] = 5
    row_d = row_input.copy()
    row_d["cine11_1d_ord"] = 6
    for c in meta['cat_cols']:
        row_u[c] = row_u[c].astype("category")
        row_m[c] = row_m[c].astype("category")
        row_d[c] = row_d[c].astype("category")

    pred_u = int(np.exp(modelo.predict(row_u)[0]))
    pred_m = int(np.exp(modelo.predict(row_m)[0]))
    pred_d = int(np.exp(modelo.predict(row_d)[0]))

    col_c1, col_c2, col_c3 = st.columns(3)
    with col_c1:
        st.info(f"**Universitario**\n\n### ${pred_u:,} CLP\n- Sueldo por hora: ${int(pred_u/(horas*4.33)):,} CLP")
    with col_c2:
        st.success(f"**Mágister (+{((pred_m/pred_u)-1)*100:.1f}%)**\n\n### ${pred_m:,} CLP\n- Aumento sobre universitario: +${pred_m-pred_u:,} CLP")
    with col_c3:
        st.warning(f"**Doctorado (+{((pred_d/pred_m)-1)*100:.1f}% sobre Mágister)**\n\n### ${pred_d:,} CLP\n- Aumento sobre universitario: +${pred_d-pred_u:,} CLP")

    st.markdown("<br>", unsafe_allow_html=True)
    st.subheader("Distribución real de sueldos en la encuesta")
    st.write("Ingresos mensuales reportados en la encuesta nacional para cada nivel de posgrado:")
    
    df_pos = df[df["cine11_1d_ord"].isin([4, 5, 6])].copy()
    df_pos["Nivel_Educativo"] = df_pos["cine11_1d_ord"].map({4: "Universitaria (N=8.130)", 5: "Mágister (N=732)", 6: "Doctorado (N=78)"})
    
    fig_box = px.box(
        df_pos,
        x="Nivel_Educativo",
        y="ing_t_p",
        color="Nivel_Educativo",
        labels={"ing_t_p": "Ingreso mensual real reportado ($ CLP)", "Nivel_Educativo": "Nivel de estudios"},
        color_discrete_sequence=["#64748b", "#0284c7", "#d97706"]
    )
    fig_box.update_layout(template="plotly_white", height=430, showlegend=False)
    st.plotly_chart(fig_box, use_container_width=True)

# =============================================================================
# TAB 3: PREGUNTAS HABITUALES
# =============================================================================
with tab3:
    st.subheader("Preguntas habituales sobre el modelo y los datos")
    st.write("Respuestas directas y claras a las dudas más comunes sobre cómo funciona el simulador y qué nos dicen realmente los datos:")

    with st.expander("1. ¿Por qué un doctorado gana más que un mágister en el simulador?", expanded=True):
        st.markdown("""
        Porque tiene sentido tanto en la práctica como en la teoría: sumar años de estudio de posgrado debe verse reflejado en un mayor ingreso esperado. 
        <br><br>
        En el modelo nos aseguramos de que, a igual edad, jornada y sector, un doctorado siempre tenga un sueldo proyectado igual o superior al de un mágister o universitario. En el sector de enseñanza, por ejemplo, los datos muestran que un doctorado supera en un <b>+60%</b> el sueldo medio de un mágister ($3.380.000 vs. $2.116.000 CLP).
        """, unsafe_allow_html=True)

    with st.expander("2. ¿Cómo influyen las horas trabajadas en el sueldo estimado?"):
        st.markdown("""
        El simulador toma las horas habituales que cada persona declara trabajar a la semana en la encuesta (de 10 a 60 horas semanales). 
        <br><br>
        Si aumentas las horas de trabajo, el sueldo mensual sube de manera continua y lógica: pasar de media jornada (20 horas) a jornada completa (44 horas) eleva el ingreso de forma proporcional, reflejando el valor real del tiempo trabajado.
        """, unsafe_allow_html=True)

    with st.expander("3. ¿Cuánto castiga el mercado el trabajar sin contrato (informalidad)?"):
        st.markdown("""
        El impacto es fuerte y directo. Al comparar dos perfiles con la misma carrera, experiencia y horario, la persona que trabaja informalmente gana entre un <b>20% y un 40% menos al mes</b>. 
        <br><br>
        El modelo refleja esta realidad: la falta de contrato no solo priva de seguridad social y previsión, sino que disminuye fuertemente el dinero que efectivamente llega a fin de mes.
        """, unsafe_allow_html=True)

    with st.expander("4. ¿Cómo se mide la brecha de género entre perfiles idénticos?"):
        st.markdown("""
        Para no mezclar cosas distintas, el simulador toma exactamente el mismo perfil (misma profesión, mismas horas, misma experiencia y misma región) y solo cambia el género. 
        <br><br>
        El resultado muestra que, incluso en completa igualdad de condiciones, las mujeres perciben entre un <b>16% y un 22% menos</b> que los hombres en el mercado laboral chileno.
        """, unsafe_allow_html=True)

    with st.expander("5. ¿Cómo sabemos qué atributos suman o restan a cada sueldo? (Explicabilidad SHAP)"):
        st.markdown("""
        En lugar de usar el modelo como una caja negra inaccesible, usamos valores SHAP. 
        <br><br>
        Esta técnica matemática desglosa cada peso del sueldo estimado: te muestra con exactitud cuánto dinero te suma tener estudios superiores o trabajar en cierta región, y cuánto te resta la informalidad o la brecha de género respecto al promedio nacional.
        """, unsafe_allow_html=True)

    with st.expander("6. ¿Estos resultados representan a todo Chile o solo a los encuestados?"):
        st.markdown("""
        Representan a todo el país. La encuesta ESI del INE incluye factores de expansión que ponderan estadísticamente a cada uno de los 38.160 trabajadores entrevistados, representando fielmente a los más de <b>8,9 millones de trabajadores ocupados</b> en Chile.
        """, unsafe_allow_html=True)

# =============================================================================
# TAB 4: MODELOS Y EXPLICABILIDAD (SHAP)
# =============================================================================
with tab4:
    st.subheader("Explicabilidad global del modelo con valores SHAP")
    st.write("Gráficos de impacto global calculados sobre 2.500 trabajadores reales de la encuesta:")

    col_img1, col_img2 = st.columns(2)
    with col_img1:
        ruta_img_beeswarm = DIR_ACTUAL / "grafico_shap_beeswarm.png"
        if ruta_img_beeswarm.exists():
            st.image(str(ruta_img_beeswarm), caption="Figura 1: Distribución global de factores (Beeswarm Plot).", use_container_width=True)
    
    with col_img2:
        ruta_img_waterfall = DIR_ACTUAL / "grafico_shap_waterfall.png"
        if ruta_img_waterfall.exists():
            st.image(str(ruta_img_waterfall), caption="Figura 2: Descomposición de un caso individual representativo.", use_container_width=True)

    st.markdown("---")
    st.subheader("Comparativa de modelos entrenados")
    st.dataframe(df_comp, use_container_width=True)

    st.subheader("Brechas salariales por rama de actividad económica en Chile")
    st.dataframe(df_ramas[['Rama_Economica', 'Total_Trabajadores_Expandido', 'Tasa_Informalidad_Pct', 'Ingreso_Medio_Formal_CLP', 'Ingreso_Medio_Informal_CLP', 'Brecha_Informalidad_Pct', 'Brecha_Genero_Pct']].style.format({
        'Total_Trabajadores_Expandido': '{:,.0f}',
        'Tasa_Informalidad_Pct': '{:.1f}%',
        'Ingreso_Medio_Formal_CLP': '${:,.0f}',
        'Ingreso_Medio_Informal_CLP': '${:,.0f}',
        'Brecha_Informalidad_Pct': '{:.1f}%',
        'Brecha_Genero_Pct': '{:.1f}%'
    }), use_container_width=True)

st.markdown("""
---
**Autor:** Raúl Frugone Zaror  
**Repositorio GitHub:** [github.com/raul-frugone/portafolio-analitica-chile](https://github.com/raul-frugone/portafolio-analitica-chile)  
**Fuente oficial:** Microdatos oficiales de la Encuesta Suplementaria de Ingresos (ESI 2025), Instituto Nacional de Estadísticas de Chile (INE).
""")
