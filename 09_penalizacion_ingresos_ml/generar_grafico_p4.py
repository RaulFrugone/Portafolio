"""
Generacion de grafico de alto impacto para divulgacion en LinkedIn (Proyecto 4)
Autor: Raul Frugone Zaror
Tema: Penalizacion salarial por informalidad y brecha de genero en Chile (ESI 2025 & Machine Learning)
"""

import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

plt.rcParams['font.sans-serif'] = 'DejaVu Sans'
plt.rcParams['axes.edgecolor'] = '#cbd5e1'
plt.rcParams['axes.linewidth'] = 0.8

dir_codigos = r"C:\Users\raul_\OneDrive\Escritorio\Proyectos para portafolio y linkedin\Codigos\04_penalizacion_ingresos_ml"
dir_informes = r"C:\Users\raul_\OneDrive\Escritorio\Proyectos para portafolio y linkedin\Documentacion\Informes\04_penalizacion_ingresos_ml"
ruta_csv = os.path.join(dir_codigos, "microdatos_esi_ocupados_preparados.csv")
ruta_excel = os.path.join(dir_codigos, "metrics_penalizacion_ingresos.xlsx")

df = pd.read_csv(ruta_csv)
df_imp = pd.read_excel(ruta_excel, sheet_name="Importancia_Variables_ML")

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7.5), gridspec_kw={'width_ratios': [1.25, 1]})
fig.patch.set_facecolor('#f8fafc')
ax1.set_facecolor('#ffffff')
ax2.set_facecolor('#ffffff')

# Subplot 1: Curvas de ingresos por ciclo de vida
df_filtrado = df[(df['edad'] >= 18) & (df['edad'] <= 65) & (df['ing_t_p'] > 0)].copy()

def calcular_trayectoria(sub):
    return sub.groupby('edad').apply(lambda g: np.average(g['ing_t_p'], weights=g['fact_cal_esi']))

curva_fh = calcular_trayectoria(df_filtrado[(df_filtrado['es_informal'] == 0) & (df_filtrado['es_mujer'] == 0)])
curva_fm = calcular_trayectoria(df_filtrado[(df_filtrado['es_informal'] == 0) & (df_filtrado['es_mujer'] == 1)])
curva_ih = calcular_trayectoria(df_filtrado[(df_filtrado['es_informal'] == 1) & (df_filtrado['es_mujer'] == 0)])
curva_im = calcular_trayectoria(df_filtrado[(df_filtrado['es_informal'] == 1) & (df_filtrado['es_mujer'] == 1)])

# Suavizado polinomial para estetica limpia
edades = np.linspace(20, 65, 100)
p_fh = np.poly1d(np.polyfit(curva_fh.index, curva_fh.values, 2))(edades)
p_fm = np.poly1d(np.polyfit(curva_fm.index, curva_fm.values, 2))(edades)
p_ih = np.poly1d(np.polyfit(curva_ih.index, curva_ih.values, 2))(edades)
p_im = np.poly1d(np.polyfit(curva_im.index, curva_im.values, 2))(edades)

ax1.plot(edades, p_fh / 1000, color='#1e3a8a', linewidth=3, label='Formal - Hombre')
ax1.plot(edades, p_fm / 1000, color='#0284c7', linewidth=3, linestyle='--', label='Formal - Mujer')
ax1.plot(edades, p_ih / 1000, color='#d97706', linewidth=2.5, label='Informal - Hombre')
ax1.plot(edades, p_im / 1000, color='#dc2626', linewidth=2.5, linestyle='--', label='Informal - Mujer')

ax1.set_xlabel('Edad del trabajador (años de experiencia laboral)', fontsize=11, color='#334155', labelpad=10)
ax1.set_ylabel('Ingreso mensual medio estimado (Miles de $ CLP)', fontsize=11, color='#334155', labelpad=10)
ax1.set_title('El costo oculto de la informalidad y la brecha de género\n(Trayectoria salarial por ciclo de vida)', 
              fontsize=13, fontweight='bold', color='#0f172a', pad=15)
ax1.grid(True, linestyle='--', alpha=0.5, color='#e2e8f0')
ax1.legend(loc='upper left', frameon=True, facecolor='#f8fafc', edgecolor='#cbd5e1', fontsize=10)
ax1.set_ylim(200, 1500)

# Anotacion estancamiento
ax1.annotate('Estancamiento salarial temprano\nen informalidad (~35 años)', 
             xy=(35, p_ih[15]/1000), 
             xytext=(26, 750),
             arrowprops=dict(facecolor='#d97706', shrink=0.08, width=1.5, headwidth=6),
             fontsize=9.5, fontweight='bold', color='#b45309')

# Subplot 2: Importancia de caracteristicas en LightGBM
map_nombres = {
    'es_informal': 'Informalidad laboral',
    'horas_semanales': 'Horas trabajadas/sem.',
    'cine11_1d': 'Nivel educativo (CINE)',
    'cine11_1d_ord': 'Nivel educativo (CINE)',
    'categoria_ocupacion': 'Categoría ocupacional',
    'r_p_rev4cl_caenes': 'Rama económica',
    'edad': 'Edad (experiencia)',
    'es_mujer': 'Género (Mujer vs Hombre)',
    'region': 'Región de residencia'
}
df_imp['Nombre'] = df_imp['Caracteristica'].map(map_nombres).fillna(df_imp['Caracteristica'])
df_imp_sort = df_imp.sort_values('Porcentaje_Ganancia', ascending=True)

y_pos = range(len(df_imp_sort))
bars = ax2.barh(y_pos, df_imp_sort['Porcentaje_Ganancia'], color='#4338ca', height=0.62, edgecolor='#312e81', alpha=0.9)
ax2.set_yticks(y_pos)
ax2.set_yticklabels(df_imp_sort['Nombre'], fontsize=10.5, color='#1e293b')
ax2.set_xlabel('Ganancia relativa en predicción salarial (% importancia LightGBM)', fontsize=11, color='#334155', labelpad=10)
ax2.set_title('Predictores determinantes del ingreso en Chile\n(Modelo supervisado LightGBM R² = 0.633)', 
              fontsize=13, fontweight='bold', color='#0f172a', pad=15)
ax2.grid(axis='x', linestyle='--', alpha=0.5, color='#e2e8f0')

for bar in bars:
    w = bar.get_width()
    ax2.text(w + 0.6, bar.get_y() + bar.get_height()/2, 
             f"{w:.1f}%", 
             va='center', ha='left', fontsize=10, color='#0f172a', fontweight='bold')

ax2.set_xlim(0, max(df_imp_sort['Porcentaje_Ganancia']) * 1.25)

fig.suptitle('Penalización salarial y brechas estructurales en Chile (INE ESI 2025 & Machine Learning)', 
             fontsize=15.5, fontweight='bold', color='#0f172a', y=0.98)

fig.text(0.5, 0.02, 
         'Investigación y desarrollo analítico: Raúl Frugone Zaror  |  Fuente: Microdatos Encuesta Suplementaria de Ingresos 2025 (INE Chile)', 
         ha='center', fontsize=9.5, color='#64748b', style='italic')

plt.tight_layout(rect=[0.02, 0.05, 0.98, 0.94])

salida_codigos = os.path.join(dir_codigos, "grafico_brecha_salarial_ml.png")
salida_informes = os.path.join(dir_informes, "grafico_brecha_salarial_ml.png")

plt.savefig(salida_codigos, dpi=300, bbox_inches='tight')
plt.savefig(salida_informes, dpi=300, bbox_inches='tight')
plt.close()

print(f"Grafico 4 generado exitosamente en:")
print(f"- {salida_codigos}")
print(f"- {salida_informes}")
