@echo off
chcp 65001 >nul
title Proyecto 4: Simulador Salarial, Machine Learning y Explicabilidad SHAP
cd /d "%~dp0"

:MENU
cls
echo ==============================================================================
echo PROYECTO 4: EL COSTO OCULTO: INGRESOS, BRECHA DE GENERO Y SHAP (XAI)
echo Autor del proyecto e investigacion: Raul Frugone Zaror
echo Ecosistema: Python (pandas, lightgbm, shap, optuna, streamlit, plotly)
echo ==============================================================================
echo.
echo Seleccione una opcion para continuar:
echo   [1] Ejecutar pipeline completo en Python (Ingesta, ML, SHAP y auditoria)
echo   [2] Lanzar Simulador Salarial interactivo en Streamlit
echo   [3] Ejecutar Auditoria Tecnica Profesional (QA 100%%)
echo   [4] Ejecutar pipeline integral y luego lanzar la aplicacion Streamlit
echo   [5] Salir
echo.
set /p OPCION="Ingrese el numero de la opcion deseada (1-5): "

if "%OPCION%"=="1" goto PIPELINE
if "%OPCION%"=="2" goto STREAMLIT
if "%OPCION%"=="3" goto AUDITORIA
if "%OPCION%"=="4" goto AMBOS
if "%OPCION%"=="5" goto SALIR

echo.
echo [AVISO] Opcion no valida. Presione una tecla para reintentar...
pause >nul
goto MENU

:PIPELINE
echo.
echo ==============================================================================
echo [1/1] Ejecutando pipeline integral (ejecutar_pipeline_proyecto4.py)...
echo ==============================================================================
python ejecutar_pipeline_proyecto4.py
echo.
pause
goto MENU

:STREAMLIT
echo.
echo ==============================================================================
echo Lanzando aplicacion interactiva de Streamlit (app_simulador_salarios.py)...
echo Se abrira automaticamente en su navegador web predeterminado.
echo Para detener el servidor presione Ctrl+C en esta consola.
echo ==============================================================================
python -m streamlit run app_simulador_salarios.py
echo.
pause
goto MENU

:AUDITORIA
echo.
echo ==============================================================================
echo Ejecutando Auditoria Tecnica Profesional (auditoria_profesional_proyecto4.py)...
echo ==============================================================================
python auditoria_profesional_proyecto4.py
echo.
pause
goto MENU

:AMBOS
echo.
echo ==============================================================================
echo [1/2] Ejecutando pipeline integral de preparacion, ML, SHAP y auditoria...
echo ==============================================================================
python ejecutar_pipeline_proyecto4.py
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Ocurrio un fallo durante la ejecucion del pipeline.
    pause
    goto MENU
)
echo.
echo ==============================================================================
echo [2/2] Lanzando aplicacion interactiva de Streamlit...
echo ==============================================================================
python -m streamlit run app_simulador_salarios.py
echo.
pause
goto MENU

:SALIR
exit /b 0
