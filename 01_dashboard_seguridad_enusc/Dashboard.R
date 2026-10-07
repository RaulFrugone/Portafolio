#-------------------------------------#
#-----------Cargar paquetes-----------#
#-------------------------------------#
{
  # Lista de paquetes
  paquetes <- c("readxl", "shiny", "leaflet", "dplyr", "RColorBrewer", 
                "sf", "shinydashboard","stringr", "plotly", "shinyjs", 
                "tidyr", "ggplot2", "treemapify","arules", "arulesViz", 
                "igraph", "visNetwork","forcats","rmarkdown","tinytex",
                "reticulate","FactoMineR", "factoextra", "klaR", "purrr",
                "DescTools", "DT","cluster", "ExPosition")
  
  # Función para instalar y cargar los paquetes
  cargar_paquetes <- function(paquetes) {
    for (p in paquetes) {
      if (!require(p, character.only = TRUE, quietly = TRUE)) {
        install.packages(p, dependencies = TRUE, quiet = TRUE)
        cat('instalando paquete:', p)
        suppressPackageStartupMessages(library(p, character.only = TRUE))
        cat('paquete cargado:', p, '\n')
      } else {
        suppressPackageStartupMessages(library(p, character.only = TRUE))
        cat('paquete cargado:', p, '\n')
      }
    }
  }
  cargar_paquetes(paquetes)
  
  # Limpieza
  rm(paquetes, cargar_paquetes)
  }



#--------------------------------------#
#-------------Cargar datos-------------#
#--------------------------------------#
{
 #wd <- "C:/Users/diego/OneDrive/Escritorio/clases/BI"
  # Directorio de trabajo relativo
if (!file.exists("Datos_ENUSC.xlsx") && file.exists(file.path("portafolio", "01_dashboard_seguridad_enusc", "Datos_ENUSC.xlsx"))) {
  setwd(file.path("portafolio", "01_dashboard_seguridad_enusc"))
}
  
  df <- read_excel("Datos_ENUSC.xlsx")
}

#--------------------------------------#
#--------------Categorías--------------#
#--------------------------------------#
{
  #Región
  {
    enc_region <- c(
      "1" = "Tarapacá", "2" = "Antofagasta", "3" = "Atacama", 
      "4" = "Coquimbo", "5" = "Valparaíso", "6" = "O'Higgins", 
      "7" = "Maule","8" = "Biobío", "9" = "La Araucanía", "10" = "Los Lagos", 
      "11" = "Aysén", "12" = "Magallanes", "13" = "Metropolitana", 
      "14" = "Los Ríos", "15" = "Arica y Parinacota", "16" = "Ñuble")
  }
  #Región, provincia, comuna 
  {
    enc_rpc <- c(
      "1101" = "Iquique", "1107" = "Alto Hospicio", "1401" = "Pozo Almonte",
      "2101" = "Antofagasta", "2201" = "Calama", "2301" = "Tocopilla",
      "3101" = "Copiapó", "3201" = "Chañaral", "3301" = "Vallenar", 
      "4101" = "La Serena", "4102" = "Coquimbo", "4201" = "Illapel","4203" = "Los Vilos", "4301" = "Ovalle", 
      "5101" = "Valparaíso","5103" = "Concón", "5109" = "Viña del Mar", "5301" = "Los Andes","5401" = "La Ligua", "5501" = "Quillota", "5502" = "Calera","5601" = "San Antonio", "5701" = "San Felipe", "5801" = "Quilpué","5802" = "Limache", "5804" = "Villa Alemana", 
      "6101" = "Rancagua","6105" = "Doñihue", "6106" = "Graneros", "6108" = "Machalí","6110" = "Mostazal", "6115" = "Rengo", "6117" = "San Vicente","6201" = "Pichilemu", "6301" = "San Fernando", "6303" = "Chimbarongo","6310" = "Santa Cruz", 
      "7101" = "Talca", "7102" = "Constitución","7105" = "Maule", "7201" = "Cauquenes", "7301" = "Curicó","7304" = "Molina", "7401" = "Linares", "7404" = "Parral","7406" = "San Javier", 
      "8101" = "Concepción", "8102" = "Coronel","8103" = "Chiguayante", "8106" = "Lota", "8107" = "Penco","8108" = "San Pedro de la Paz", "8110" = "Talcahuano", "8111" = "Tomé","8112" = "Hualpén", "8201" = "Lebu", "8301" = "Los Ángeles",
      "9101" = "Temuco", "9108" = "Lautaro", "9109" = "Loncoche","9111" = "Nueva Imperial", "9112" = "Padre Las Casas", "9114" = "Pitrufquén","9115" = "Pucón", "9119" = "Vilcún", "9120" = "Villarrica","9201" = "Angol", "9202" = "Collipulli", "9211" = "Victoria",
      "10101" = "Puerto Montt", "10102" = "Calbuco", "10109" = "Puerto Varas","10201" = "Castro", "10202" = "Ancud", "10208" = "Quellón","10301" = "Osorno", 
      "11101" = "Coihaique", "11201" = "Aisén",
      "12101" = "Punta Arenas", "12401" = "Natales", 
      "13101" = "Santiago","13102" = "Cerrillos", "13103" = "Cerro Navia", "13104" = "Conchalí","13105" = "El Bosque", "13106" = "Estación Central", "13107" = "Huechuraba","13108" = "Independencia", "13109" = "La Cisterna", "13110" = "La Florida","13111" = "La Granja", "13112" = "La Pintana", "13113" = "La Reina","13114" = "Las Condes", "13115" = "Lo Barnechea", "13116" = "Lo Espejo","13117" = "Lo Prado", "13118" = "Macul", "13119" = "Maipú","13120" = "Ñuñoa", "13121" = "Pedro Aguirre Cerda", "13122" = "Peñalolén","13123" = "Providencia", "13124" = "Pudahuel", "13125" = "Quilicura","13126" = "Quinta Normal", "13127" = "Recoleta", "13128" = "Renca","13129" = "San Joaquín", "13130" = "San Miguel", "13131" = "San Ramón","13132" = "Vitacura", "13201" = "Puente Alto", "13301" = "Colina","13302" = "Lampa", "13401" = "San Bernardo", "13402" = "Buin","13404" = "Paine", "13501" = "Melipilla", "13601" = "Talagante","13604" = "Padre Hurtado", "13605" = "Peñaflor", 
      "14101" = "Valdivia","14107" = "Paillaco", "14108" = "Panguipulli", "14201" = "La Unión","14204" = "Río Bueno", 
      "15101" = "Arica",
      "16101" = "Chillán","16102" = "Bulnes", "16103" = "Chillán Viejo", "16107" = "Quillón","16109" = "Yungay", "16201" = "Quirihue", "16301" = "San Carlos","16302" = "Coihueco")
  }
  #¿Cuál es el sexo de (nombre)? 
  rph_sexo <- c("1" = "Hombre","2" = "Mujer")
  
  #¿Qué edad tiene (nombre)?
  rph_edad <- c("0" = "0 a 14 años","1" = "15 a 19 años","2" = "20 a 29 años",
                "3" = "30 a 39 años","4" = "40 a 49 años","5" = "50 a 59 años",
                "6" = "60 a 69 años","7" = "70 años o más")
  
  #PAIS:Pensando en la delincuencia, usted diría que durante los últimos doce meses, la delincuencia en el PAÍS... 
  # COM:Pensando en la delincuencia, usted diría que durante los últimos doce meses, la delincuencia en su COMUNA... 
  P_AUMENTO_ <- c(
    "1" = "Aumentó",
    "2" = "Se mantuvo",
    "3" = "Disminuyó",
    "88" = "No sabe",
    "99" = "No responde")
  
  # 1:Trasladándose en su vehículo
  # 3:Trasladándose en buses o micros de transporte público
  # 7:En un restaurante, bar, pub, café, discoteque u otro lugar de recreación 
  # 8:En un terminal de buses o ferrocarriles
  # 9:En un terminal aéreo o aeropuerto 
  #10:En centros comerciales o malls
  #12:En plazas o parques de su barrio 
  #16:En el banco
  P_INSEG_LUGARES_ <- c(
    "1" = "Muy inseguro/a",
    "2" = "Inseguro/a",
    "3" = "Seguro/a",
    "4" = "Muy seguro/a",
    "85" = "No aplica",
    "88" = "No sabe",
    "99" = "No responde")
  
  # 4:Durante los últimos doce meses ¿con qué frecuencia diría usted que suceden las siguientes situaciones delictivas en su barrio? Peleas callejeras con armas blancas o de fuego 
  # 6:Durante los últimos doce meses ¿con qué frecuencia diría usted que suceden las siguientes situaciones delictivas en su barrio? Robos o asaltos en la vía pública
  # 7:Durante los últimos doce meses ¿con qué frecuencia diría usted que suceden las siguientes situaciones delictivas en su barrio? Balaceras o disparos 
  P_INCIVILIDADES_ <- c(
    "1" = "Nunca", 
    "2" = "Casi nunca", 
    "3" = "Ocasionalmente", 
    "4" = "Casi siempre", 
    "5" = "Siempre", 
    "88" = "No sabe", 
    "99" = "No responde")
  #Considerando el tipo de actividades que realiza o los lugares por los que transita habitualmente, ¿cree usted que será víctima de algún delito en los próximos doce meses?
  P_EXPOS_DELITO <- c("1" = "Sí", "2" = "No", "88" = "No sabe", "99" = "No responde")
  
  # 1:¿De qué delito cree usted que será víctima en los próximos doce meses? Robo en su vivienda 
  # 2:¿De qué delito cree usted que será víctima en los próximos doce meses? Robo o hurto de su vehículo o portonazo 
  # 5:¿De qué delito cree usted que será víctima en los próximos doce meses? Robo o asalto, como robo con violencia, cogoteo, robo por sorpresa o lanzazo 
  #10:¿De qué delito cree usted que será víctima en los próximos doce meses? Delitos cibernéticos 
  #11:¿De qué delito cree usted que será víctima en los próximos doce meses? Acoso callejero o sexual 
  P_DELITO_PRONOSTICO__ <- c("0" = "No", "1" = "Sí")
  
  # CCH:¿Cuánta confianza le genera Carabineros de Chile respecto de sus acciones en Seguridad Pública? 
  # PDI:¿Cuánta confianza le genera por la Policía de Investigaciones (PDI) respecto de sus acciones en Seguridad Pública? 
  # FMP:¿Cuánta confianza le genera por la Fiscalía o ministerio Público respecto de sus acciones en Seguridad Pública?
  EV_CONFIA_ <- c(
    "1. Mucha confianza", 
    "2. Bastante confianza", 
    "3. Poca confianza", 
    "4. Nada de confianza", 
    "88. No sabe", 
    "99. No responde"
  )
  
  # ¿Cuántas veces a usted o a algún integrante de su hogar le robaron o le intentaron robar su vehículo?
  # SCREEN_INT_RDV_N
  # ¿Cuántas veces lograron robar el vehículo? 
  # SCREEN_ROB_RDV_N
  # ¿Cuántas veces usted o alguien denunció formalmente el o los delitos?
  # RDV_DENUNCIAS_N
  
  # ¿Cuántas veces alguien robó o intentó robar algo de su VIVIENDA?
  # SCREEN_INT_RFV_N
  # ¿Cuántas veces lograron robar el vehículo? 
  # SCREEN_ROB_RFV_N
  # ¿Cuántas veces usted o alguien denunció formalmente el o los delitos?
  # RFV_DENUNCIAS_N
  
  # ¿Cuántas veces usted o algún integrante de su hogar fue asaltado o lo intentaron asaltar usando VIOLENCIA, AMENAZA O INTIMIDACIÓN?
  # SCREEN_INT_RVI_N
  # ¿Cuántas veces ¿lograron asaltarle usando VIOLENCIA, AMENAZA O INTIMIDACIÓN?  
  # SCREEN_ROB_RVI_N
  # ¿Cuántas veces usted o alguien denunció formalmente el o los delitos?
  # RVI_DENUNCIAS_N
  
  # ¿Cuántas veces usted o algún integrante de su hogar fue víctima de FRAUDE BANCARIO?
  # SCREEN_ROB_FRB_N
  # ¿Cuántas veces usted o algún usted o alguien denunció formalmente el o los delitos?
  # FRB_DENUNCIAS_N
  
}

#--------------------------------------#
#-----------------Mapa-----------------#
#--------------------------------------#
{
  geografia <- st_read("ciudades/Ciudades_2017.shp", quiet = TRUE)
  geografia <- st_transform(geografia, crs = 4326)
}


calcular_entropia <- function(x) {
  freqs <- table(x) / length(x)
  -sum(freqs * log2(freqs), na.rm = TRUE)
}


rph_edad_labels <- c(
  "0" = "0 a 14 años", "1" = "15 a 19 años", "2" = "20 a 29 años",
  "3" = "30 a 39 años", "4" = "40 a 49 años", "5" = "50 a 59 años",
  "6" = "60 a 69 años", "7" = "70 años o más"
)

#--------------------------------------#
#------------------UI------------------#
#--------------------------------------#
{
  ui <- dashboardPage(
    dashboardHeader(title = "Dashboard Seguridad Pública"),
    
    dashboardSidebar(
      tags$head(
        tags$style(HTML("
      .box-header .box-title {
      font-size: 30px !important;  /* Ajusta el tamaño según necesites */
      }
      .main-sidebar .sidebar .sidebar-menu > li > a {
          font-size: 16px;
      }
      .selectize-dropdown-content {
      font-size: 18px;
      }
        #descargar_reporte {
          background-color: #1E90FF;  
          color: white;
          width: 100%;
          border: none;
          padding: 10px;
          font-size: 16px;
        }
        #descargar_reporte:hover {
          background-color: #187bcd; /* Color al pasar el mouse */
        }
      "))
      ), 
      sidebarMenu(
        fluidRow(
          box(
            title = "Información",
            status = "primary",
            solidHeader = TRUE,
            collapsible = TRUE,
            collapsed = TRUE,
            width = 12,
            downloadButton("descargar_reporte", "Descargar Informe PDF"),
            HTML('
    <div style="color: black; font-size: 16px;">
      <p><i class="fas fa-chalkboard-teacher"></i> <b>Docente:</b></p>
      <ul style="list-style-type: disc; padding-left: 30px;">
        <li>José Zúñiga Núñez</li>
       </ul>
      <p><i class="fas fa-book"></i> <b>Asignatura: [IES-414]</b></p>
      <ul style="list-style-type: disc; padding-left: 30px;">
        <li>Business Intelligence</li>
       </ul>
      <p><i class="fas fa-users"></i> <b>Integrantes:</b></p>
      <ul style="list-style-type: disc; padding-left: 30px;">
        <li>Diego Rocha Retamal</li>
        <li>Raúl Frugone Zaror</li>
      </ul>
    </div>
  ')
          )
          
        ),
        menuItem("Resumen general", tabName = "resumen", icon = icon("home")),
        menuItem("Percepción de Inseguridad", tabName = "percepcion", icon = icon("eye")),
        menuItem("Confianza Institucional", tabName = "confianza", icon = icon("balance-scale")),
        menuItem("Victimización", tabName = "victimizacion", icon = icon("user-slash")),
        menuItem("Análisis de agrupación", tabName = "agrupación", icon = icon("users")),
        menuItem("Conclusiones", tabName = "conclusión", icon = icon("lightbulb"))
        
        
      ),
      #---------------------------------#
      #-------------filtros-------------#
      #---------------------------------#
      selectizeInput("region", h4("Selecciona Región(es):"),
                     choices = setNames(names(enc_region), enc_region),
                     selected = NULL, 
                     multiple = TRUE,
                     options = list(placeholder = 'Todas seleccionadas')),
      
      selectizeInput("comuna", h4("Selecciona Comuna(s):"),
                     choices = NULL,
                     multiple = TRUE,
                     options = list(placeholder = 'Todas seleccionadas')),
      
      selectizeInput("sexo", h4("Selecciona Sexo:"),
                     choices = c("Ambos" = "", "Hombre" = "1", "Mujer" = "2"),
                     selected = "",
                     multiple = FALSE),
      
      selectizeInput("edad", h4("Selecciona Grupo etario:"),
                     choices = setNames(names(rph_edad), rph_edad),
                     selected = NULL,   # ninguna preselección = “todas”
                     multiple = TRUE,
                     options = list(placeholder = 'Todas seleccionadas'))
    ),
    dashboardBody(
      tags$head(
        tags$style(HTML("
    .conclusion-box {
      border: 1px solid #ddd;
      border-left: 5px solid #2C3E50;
      padding: 15px;
      margin-bottom: 10px;
      background-color: #f9f9f9;
      border-radius: 4px;
    }
    .conclusion-box h4 {
      color: #333;
      margin-top: 0; /* Asegura que el título no tenga margen extra arriba */
      margin-bottom: 5px; /* Pequeño margen entre título y párrafo */
    }
    .conclusion-box p {
      margin-bottom: 5px; /* Reduce el espacio entre párrafos */
      line-height: 1.3em; /* Ajusta el interlineado. Puedes probar 1.2em o 1.1em si quieres aún menos */
    }
    .conclusion-box strong {
      font-weight: bold;
    }
  "))
      ),
      tabItems(
        tabItem(
          
          tabName = "resumen",
          
          fluidRow(
            # Columna izquierda (9 de ancho): valueBoxes arriba, gráfico abajo
            column(
              width = 9,
              fluidRow(
                valueBoxOutput("box_delitos", width = 4),
                valueBoxOutput("box_intentos", width = 4),
                valueBoxOutput("box_denuncias", width = 4)
              ),
              box(
                title = "Percepción de aumento del país, por sexo y edad",
                width = 12,
                status = "info",
                solidHeader = TRUE,
                plotlyOutput("grafico_aumento_pais", height = 600)
              )
            ),
            
            # Columna derecha (3 de ancho): mapa de alto completo
            column(
              width = 3,
              box(
                title = "Mapa comunal",
                width = 12,
                leafletOutput("mapa", height = 700)  # Ajusta altura según preferencia
              )
            )
          )
        )
        ,
        
        #--------------------------------#
        #-----------percepción-----------#
        #--------------------------------#
        
        tabItem(tabName = "percepcion",
                fluidRow(
                  valueBoxOutput("box_exposicion", width = 4),
                  valueBoxOutput("box_percepcion_pais", width = 4),
                  valueBoxOutput("box_percepcion_comuna", width = 4)
                ),
                fluidRow(
                  box(title = "Percepción de aumento de la delincuencia", width = 6, plotlyOutput("grafico_percepcion", height = 600)),
                  box(title = "Percepción de inseguridad lugares (Top 7)", width = 6, plotlyOutput("grafico_inseguridad_lugares", height = 600))
                )
        ),
        #-------------------------------#
        #-----------confianza-----------#
        #-------------------------------#
        tabItem(tabName = "confianza",
                fluidRow(
                  valueBoxOutput("cantidad_delitos"),
                  valueBoxOutput("cantidad_intentos"),
                  valueBoxOutput("cantidad_denuncias")
                ),
                fluidRow(
                  box(title = "Confianza en instituciones", width = 12, plotlyOutput("grafico_confianza_instituciones"))
                )
        ),
        #-------------------------------#
        #---------victimización---------#
        #-------------------------------#
        tabItem(tabName = "victimizacion",
                fluidRow(
                  box(
                    title = "Treemap de incivilidades",
                    width = 8,
                    solidHeader = TRUE,
                    status = "primary",
                    plotlyOutput("treemap_incivilidades", height = "700px")
                  ),
                  box(
                    title = "Tipos de incivilidades",
                    width = 4,
                    solidHeader = TRUE,
                    status = "primary",
                    plotlyOutput("barplot_incivilidades_counts", height = "700px")
                  )
                )
        ),
        #-------------------------------#
        #---------Agrupación---------#
        #-------------------------------#
        tabItem(tabName = "agrupación",
                fluidRow(
                  box(
                    title = "Análisis de correspondencia múltiple con K-modes",
                    width = 12,
                    solidHeader = TRUE,
                    status = "primary",
                    plotlyOutput("ACM2D")
                  )
                
                ,
                    box(width = 6,
                    solidHeader = TRUE,
                    status = "primary",
                    DT::dataTableOutput("tabla_entropia")
                  ),
                  box(
                    width = 6,
                    status = "primary",
                    solidHeader = TRUE,
                    plotlyOutput("mca_scree", height = "350px")
                  )
        )
        ),
        #------------------------------#
        #----------Conclusión----------#
        #------------------------------#

        tabItem(tabName = "conclusión",
                fluidRow(
                  box(
                    title = "Conclusiones y medidas a tomar",
                    width = 12,
                    solidHeader = TRUE,
                    status = "primary",
                    # CAMBIO AQUÍ: Usar htmlOutput en lugar de plotlyOutput
                    htmlOutput("conclusiones_generadas")
                  )
                )
        )
        
      ) 
      )
    )

}

#--------------------------------------#
#----------------SERVER----------------#
#--------------------------------------#
server <- function(input, output, session) {
  
  #---------------------------------#
  #-------------filtros-------------#
  #---------------------------------#
  {
  observe({
    # Determinamos las regiones seleccionadas (o todas si ninguna fue elegida)
    regiones_seleccionadas <- if (is.null(input$region) || length(input$region) == 0) {
      names(enc_region)  # Usamos todos los códigos de región
    } else {
      input$region
    }
    
    # Filtrar comunas cuyo prefijo (código de región) esté en las regiones seleccionadas
    comunas_filtradas <- names(enc_rpc)[
      substr(names(enc_rpc), 1, nchar(names(enc_rpc)) - 3) %in% regiones_seleccionadas
    ]
    
    # Obtener los nombres de las comunas correspondientes
    comunas_nombres <- enc_rpc[comunas_filtradas]
    
    # Actualizar el input de comuna con nombres visibles
    updateSelectInput(session, "comuna",
                      choices = setNames(comunas_filtradas, comunas_nombres),
                      selected = NULL)  # Todas preseleccionadas por defecto
  })
  
  datos_filtrados <- reactive({
    regiones_seleccionadas <- if (is.null(input$region) || length(input$region) == 0) {
      names(enc_region)
    } else {
      input$region
    }
    
    comunas_disponibles <- names(enc_rpc)[
      substr(names(enc_rpc), 1, nchar(names(enc_rpc)) - 3) %in% regiones_seleccionadas
    ]
    
    comunas_seleccionadas <- if (is.null(input$comuna) || length(input$comuna) == 0) {
      comunas_disponibles
    } else {
      input$comuna
    }
    
    regiones_num <- as.numeric(regiones_seleccionadas)
    comunas_num <- as.numeric(comunas_seleccionadas)
    
    df_filtrado <- df %>%
      filter(enc_region %in% regiones_num, enc_rpc %in% comunas_num)
    
    if (input$sexo != "") {
      df_filtrado <- df_filtrado %>% filter(rph_sexo == as.numeric(input$sexo))
    }
    
    if (!is.null(input$edad) && length(input$edad) > 0) {
      df_filtrado <- df_filtrado %>% filter(rph_edad %in% as.numeric(input$edad))
    }
    
    
    
    df_filtrado
  })
  
  mapa_datos_filtrados <- reactive({
    df_filtrado <- datos_filtrados()
    
    df_filtrado <- df_filtrado %>% filter(P_AUMENTO_COM %in% c(1, 2, 3))
    # Agrupar datos resumidos por comuna
    resumen <- df_filtrado %>%
      group_by(enc_rpc) %>%
      summarise(
        total = n(),
        aumento = sum(P_AUMENTO_COM == 1, na.rm = TRUE),
        porcentaje_aumento = 100 * aumento / total
      )
    
    # Asegúrate de que enc_rpc sea numérico
    geografia$enc_rpc <- as.numeric(geografia$COMUNA)
    
    # Unir geometría con datos filtrados
    mapa <- left_join(resumen,geografia, by = "enc_rpc")
    
    st_as_sf(mapa) %>% st_transform(crs = 4326)
  })
  
  df_inc_processed <- reactive({
    req(datos_filtrados()) # Asegura que datos_filtrados() esté disponible
    
    # 1) Variables de incivilidades
    inciv_vars <- c("P_INCIVILIDADES_4", "P_INCIVILIDADES_6", "P_INCIVILIDADES_7")
    # 2) Labels puros (solo niveles 1:5)
    labels_inciv <- unname(P_INCIVILIDADES_[as.character(1:5)]) # Asegúrate que P_INCIVILIDADES_ esté disponible
    # 3) Renombro tus vectores para no pisar nombres
    region_labels <- enc_region # Asegúrate que enc_region esté disponible
    comuna_labels <- enc_rpc   # Asegúrate que enc_rpc esté disponible
    
    datos_filtrados() %>%
      dplyr::select(enc_region, enc_rpc, all_of(inciv_vars)) %>%
      tidyr::pivot_longer(all_of(inciv_vars),
                          names_to  = "incivilidad",
                          values_to = "respuesta") %>%
      dplyr::filter(respuesta %in% 4:5) %>% # Solo 'casi siempre' y 'siempre'
      dplyr::mutate(
        categoria = factor(respuesta,
                           levels = 1:5,
                           labels = labels_inciv),
        region    = region_labels[as.character(enc_region)],
        comuna    = comuna_labels[as.character(enc_rpc)]
      )
  })
  
  resultados_acm <- reactiveValues(
    mca_res = NULL,
    df_acm_clean_with_cluster = NULL,
    dim_desc_res = NULL
  )
  
  tabla_resumen_acm <- reactive({
    req(resultados_acm$df_acm_clean_with_cluster)
    df <- resultados_acm$df_acm_clean_with_cluster
    variables <- setdiff(names(df), "Cluster")
    if (length(variables) == 0 || nrow(df) == 0) return(data.frame())
    
    # Etiquetas de categorías legibles
    etiquetas_P_EXPOS_DELITO <- c("1" = "Sí", "2" = "No", "88" = "No sabe", "99" = "No responde")
    etiquetas_P_AUMENTO_PAIS <- c("1" = "Aumentó", "2" = "Se mantuvo", "3" = "Disminuyó", "88" = "No sabe", "99" = "No responde")
    etiquetas_P_DELITO_PRONOSTICO <- c("0" = "No", "1" = "Sí")
    
    resumen_list <- lapply(variables, function(var) {
      if (!is.factor(df[[var]])) df[[var]] <- as.factor(df[[var]])
      tabla <- prop.table(table(df[[var]], df$Cluster), margin = 2)
      if (length(tabla) == 0) return(NULL)
      
      tabla_df <- as.data.frame.matrix(tabla)
      tabla_df <- tibble::rownames_to_column(tabla_df, var = "Categoria")
      tabla_df$Variable <- var
      
      # Aplicar etiquetas legibles a variables específicas
      if (var == "P_EXPOS_DELITO") {
        tabla_df$Categoria <- etiquetas_P_EXPOS_DELITO[tabla_df$Categoria]
      }
      if (var == "P_AUMENTO_PAIS") {
        tabla_df$Categoria <- etiquetas_P_AUMENTO_PAIS[tabla_df$Categoria]
      }
      if (var == "P_DELITO_PRONOSTICO__5") {
        tabla_df$Categoria <- etiquetas_P_DELITO_PRONOSTICO[tabla_df$Categoria]
      }
      
      return(tabla_df)
    })
    
    resumen_total <- dplyr::bind_rows(resumen_list)
    if (nrow(resumen_total) == 0) return(data.frame())
    
    # Renombrar columnas de clusters
    resumen_wide <- resumen_total %>%
      dplyr::select(Variable, Categoria, everything()) %>%
      dplyr::rename_with(~ paste0("Cluster_", .x), -c(Variable, Categoria)) %>%
      dplyr::mutate(across(starts_with("Cluster_"), ~ round(.x, 3)))
    
    # Eliminar filas con 0 en ambos clusters
    resumen_wide <- resumen_wide %>%
      dplyr::filter(!(Cluster_1 == 0 & Cluster_2 == 0))
    
    # Ordenar por la mayor proporción entre los dos clusters
    resumen_wide <- resumen_wide %>%
      dplyr::rowwise() %>%
      dplyr::mutate(Max_Proporcion = max(c_across(starts_with("Cluster_")))) %>%
      dplyr::ungroup() %>%
      dplyr::arrange(desc(Max_Proporcion)) %>%
      dplyr::select(-Max_Proporcion)
    
    return(as.data.frame(resumen_wide))
  })
  
  
  }
  
  
  #---------------------------------#
  #-------------Resumen-------------#
  #---------------------------------#
  {
    
    # Tasa de delitos
    output$box_delitos <- renderValueBox({
      df <- datos_filtrados() %>%
        filter(SCREEN_ROB_RDV_N > 0 | SCREEN_ROB_RFV_N > 0 | SCREEN_ROB_RVI_N > 0 | SCREEN_ROB_FRB_N > 0)
      total_respuestas <- nrow(datos_filtrados())
      
      if (total_respuestas == 0) {
        return(valueBox("Sin datos", h4("Tasa de delitos reportados"), icon = icon("exclamation-triangle"), color = "red"))
      }
      
      cantidad_delitos <- sum(df$SCREEN_ROB_RDV_N, df$SCREEN_ROB_RFV_N, df$SCREEN_ROB_RVI_N, df$SCREEN_ROB_FRB_N, na.rm = TRUE)
      tasa <- round(100 * cantidad_delitos / total_respuestas, 1)
      
      valueBox(paste0(tasa, "%"), h4("Tasa de delitos reportados"), icon = icon("exclamation-triangle"), color = "red")
    })
    
    # Tasa de intentos de robo
    output$box_intentos <- renderValueBox({
      df <- datos_filtrados() %>%
        filter(
          (SCREEN_INT_RDV_N > 0 & is.na(SCREEN_ROB_RDV_N)) | 
            (SCREEN_INT_RFV_N > 0 & is.na(SCREEN_ROB_RFV_N)) | 
            (SCREEN_INT_RVI_N > 0 & is.na(SCREEN_ROB_RVI_N))
        )
      total_respuestas <- nrow(datos_filtrados())
      
      if (total_respuestas == 0) {
        return(valueBox("Sin datos", h4("Tasa de intentos de robo"), icon = icon("hand-holding"), color = "orange"))
      }
      
      cantidad_intentos <- sum(df$SCREEN_INT_RDV_N, df$SCREEN_INT_RFV_N, df$SCREEN_INT_RVI_N, na.rm = TRUE)
      tasa <- round(100 * cantidad_intentos / total_respuestas, 1)
      
      valueBox(paste0(tasa, "%"), h4("Tasa de intentos de robo"), icon = icon("hand-holding"), color = "orange")
    })
    
    # Tasa de denuncias
    output$box_denuncias <- renderValueBox({
      df <- datos_filtrados()
      
      total_delitos <- sum(df$SCREEN_ROB_RDV_N, df$SCREEN_ROB_RFV_N, df$SCREEN_ROB_RVI_N, df$SCREEN_ROB_FRB_N, na.rm = TRUE)
      total_denuncias <- sum(df$RDV_DENUNCIAS_N, df$RFV_DENUNCIAS_N, df$RVI_DENUNCIAS_N, df$FRB_DENUNCIAS_N, na.rm = TRUE)
      
      if (total_delitos == 0) {
        return(valueBox("Sin datos", h4("Tasa de denuncias"), icon = icon("balance-scale"), color = "aqua"))
      }
      
      tasa <- round(100 * total_denuncias / total_delitos, 1)
      
      valueBox(paste0(tasa, "%"), h4("Tasa de denuncias"), icon = icon("balance-scale"), color = "aqua")
    })
    
    
    # combinado
    output$grafico_aumento_pais <- renderPlotly({
      df <- datos_filtrados()
      
      df <- df %>%
        filter(P_AUMENTO_PAIS %in% c(1, 2, 3)) %>%
        mutate(
          sexo = factor(dplyr::recode(as.character(rph_sexo),
                                      "1" = "Hombre", "2" = "Mujer")),
          edad = factor(dplyr::recode(as.character(rph_edad),
                                      "0" = "0 a 14 años", "1" = "15 a 19 años", "2" = "20 a 29 años",
                                      "3" = "30 a 39 años", "4" = "40 a 49 años", "5" = "50 a 59 años",
                                      "6" = "60 a 69 años", "7" = "70 años o más")),
          respuesta = factor(dplyr::recode(as.character(P_AUMENTO_PAIS),
                                           "1" = "Ha aumentado",
                                           "2" = "Se mantiene igual",
                                           "3" = "Ha disminuido"),
                             levels = c("Ha aumentado", "Se mantiene igual", "Ha disminuido")),
          grupo = interaction(sexo, edad, sep = " - ")
        )
      
      resumen <- df %>%
        group_by(grupo, respuesta) %>%
        summarise(n = n(), .groups = "drop") %>%
        group_by(grupo) %>%
        mutate(prop = n / sum(n)) %>%
        ungroup()
      
      plot_ly(
        data = resumen,
        x = ~grupo,
        y = ~prop,
        color = ~respuesta,
        type = "bar",
        colors = c("Ha aumentado" = "#f6511d",
                   "Se mantiene igual" = "#ffb400",
                   "Ha disminuido" = "#00a6ed"),
        hoverinfo = "text",
        hovertext = ~paste0(
          "Grupo: ", grupo, "<br>",
          "Respuesta: ", respuesta, "<br>",
          "Cantidad: ", n, "<br>",
          "Porcentaje: ", scales::percent(prop, accuracy = 0.1)
        )
      ) %>%
        layout(
          barmode = "stack",
          xaxis = list(title = "Edad y sexo", tickangle = 45,tickfont = list(size = 16)),
          yaxis = list(title = "Proporción", tickformat = ".0%"),
          legend = list(title = list(text = "Respuesta"))
        )
    })
    
    
    
    #mapa
    output$mapa <- renderLeaflet({
      datos <- mapa_datos_filtrados()
      
      validate(
        need(nrow(datos) > 0, "No hay comunas disponibles para mostrar en el mapa.")
      )
      
      # Paleta personalizada: verde (bajo) a rojo (alto)
      pal <- colorNumeric(
        palette = colorRampPalette(c("blue", "yellow", "red"))(100),
        domain = c(0, 100), # Fijar la escala del 0 al 100%
        na.color = "transparent"
      )
      
      leaflet(datos) %>%
        addProviderTiles("CartoDB.Positron") %>%
        addPolygons(
          fillColor = ~pal(porcentaje_aumento),
          fillOpacity = 0.7,
          color = "#444444",
          weight = 1,
          popup = ~paste0("<strong>", NOM_COMUNA, "</strong><br/>",
                          "Aumento percepción: ", round(porcentaje_aumento, 1), "%")
        ) %>%
        addLegend("bottomright", pal = pal, values = c(0, 100),
                  title = "Aumento percepción", opacity = 0.7)
    })
  }
  
  #--------------------------------#
  #-----------Percepción-----------#
  #--------------------------------#
  {
    
    output$box_exposicion <- renderValueBox({
      df <- datos_filtrados()
      df <- df %>% filter(P_EXPOS_DELITO %in% c(1, 2, 3))
      
      total_respuestas <- nrow(df)
      muy_expuestos <- sum(df$P_EXPOS_DELITO == 1, na.rm = TRUE)
      
      if (total_respuestas == 0) {
        return(valueBox("Sin datos", h4("Exposición percibida"), icon = icon("exclamation-triangle"), color = "yellow"))
      }
      
      porcentaje <- round(100 * muy_expuestos / total_respuestas, 1)
      valueBox(
        paste0(porcentaje, "%"),
        h4("Porcentaje que se considera 'Muy expuesto/a'"),
        icon = icon("exclamation-triangle"),
        color = "red"
      )
    })
    
    output$box_percepcion_pais <- renderValueBox({
      df <- datos_filtrados()
      df <- df %>% filter(P_AUMENTO_PAIS %in% c(1, 2, 3))
      
      total_respuestas <- nrow(df)
      aumento <- sum(df$P_AUMENTO_PAIS == 1, na.rm = TRUE)
      
      if (total_respuestas == 0) {
        return(valueBox("Sin datos", h4("Percepción aumento país"), icon = icon("chart-line"), color = "yellow"))
      }
      
      porcentaje <- round(100 * aumento / total_respuestas, 1)
      valueBox(
        paste0(porcentaje, "%"),
        h4("Delincuencia en el país ha aumentado"),
        icon = icon("chart-line"),
        color = "orange"
      )
    })
    
    output$box_percepcion_comuna <- renderValueBox({
      df <- datos_filtrados()
      df <- df %>% filter(P_AUMENTO_COM %in% c(1, 2, 3))
      
      total_respuestas <- nrow(df)
      aumento <- sum(df$P_AUMENTO_COM == 1, na.rm = TRUE)
      
      if (total_respuestas == 0) {
        return(valueBox("Sin datos", h4("Percepción aumento comuna"), icon = icon("map-marker-alt"), color = "yellow"))
      }
      
      porcentaje <- round(100 * aumento / total_respuestas, 1)
      valueBox(
        paste0(porcentaje, "%"),
        h4("Delincuencia en la comuna ha aumentado"),
        icon = icon("map-marker-alt"),
        color = "blue"
      )
    })
    
    output$grafico_percepcion <- renderPlotly({
      df <- datos_filtrados()
      
      # Solo mantener respuestas válidas
      df <- df %>% filter(P_AUMENTO_COM %in% c(1, 2, 3))
      
      regiones_sel <- input$region
      comunas_sel <- input$comuna
      
      usar_comunas <- (
        (!is.null(comunas_sel) && length(comunas_sel) <= 10) ||
          (is.null(comunas_sel) && !is.null(regiones_sel) && length(regiones_sel) <= 3)
      )
      
      if (usar_comunas) {
        datos_barra <- df %>%
          mutate(COMUNA = as.character(enc_rpc),
                 respuesta = factor(P_AUMENTO_COM, levels = c(1, 2, 3),
                                    labels = c("Ha aumentado", "Se mantiene igual", "Ha disminuido"))) %>%
          count(COMUNA, respuesta) %>%
          left_join(
            geografia %>%
              mutate(COMUNA = as.character(COMUNA)) %>%
              dplyr::select(COMUNA, nombre = NOM_COMUNA) %>% distinct(),
            by = "COMUNA",
            relationship = "many-to-many"
          ) %>%
          group_by(nombre, respuesta) %>%
          summarise(n = sum(n), .groups = "drop")
        
        
      } else {
        # Define el vector fuera del renderPlotly
        nombre_regiones <- c(
          "1" = "Tarapacá", "2" = "Antofagasta", "3" = "Atacama", 
          "4" = "Coquimbo", "5" = "Valparaíso", "6" = "O'Higgins", 
          "7" = "Maule", "8" = "Biobío", "9" = "La Araucanía", 
          "10" = "Los Lagos", "11" = "Aysén", "12" = "Magallanes", 
          "13" = "Metropolitana", "14" = "Los Ríos", 
          "15" = "Arica y Parinacota", "16" = "Ñuble"
        )

        datos_barra <- df %>%
          mutate(
            REGION = as.character(enc_region),
            nombre = dplyr::recode(REGION, !!!nombre_regiones),
            respuesta = factor(P_AUMENTO_COM, levels = c(1, 2, 3),
                               labels = c("Ha aumentado", "Se mantiene igual", "Ha disminuido"))
          ) %>%
          count(nombre, respuesta) %>%
          group_by(nombre, respuesta) %>%
          summarise(n = sum(n), .groups = "drop")
        
      }
      
      # Ordenar por cantidad de respuestas "Ha aumentado"
      orden_nombres <- datos_barra %>%
        filter(respuesta == "Ha aumentado") %>%
        arrange(desc(n)) %>%
        pull(nombre)
      
      # Calcular porcentaje dentro de cada grupo (comuna o región)
      datos_barra <- datos_barra %>%
        group_by(nombre) %>%
        mutate(porcentaje = round(100 * n / sum(n), 1)) %>%
        ungroup()
      
      
      # Generar gráfico
      plot_ly(
        datos_barra,
        x = ~nombre,
        y = ~porcentaje,
        color = ~respuesta,
        colors = c("Ha aumentado" = "#f6511d",
                   "Se mantiene igual" = "#ffb400",
                   "Ha disminuido" = "#00a6ed"),
        type = "bar",
        hovertext = ~paste0("Región/comuna", nombre ,"<br>" ,
                            "Respuesta: ", respuesta, "<br>",
                            "Porcentaje: ", porcentaje, "%"),
        hoverinfo = "text"
        
        
      ) %>%
        layout(
          barmode = "stack",
          xaxis = list(title = "", tickangle = 45,tickfont = list(size = 16)),
          yaxis = list(title = "Porcentaje (%)", range = c(0,100)),
          legend = list(title = list(text = "Respuesta")),
          margin = list(b = 100)
        )
      
    })
    
    output$grafico_inseguridad_lugares <- renderPlotly({
      df <- datos_filtrados()
      
      lugares_vars <- c("P_INSEG_LUGARES_1", "P_INSEG_LUGARES_3", "P_INSEG_LUGARES_7",
                        "P_INSEG_LUGARES_8", "P_INSEG_LUGARES_10",
                        "P_INSEG_LUGARES_12", "P_INSEG_LUGARES_16")
      
      lugares_nombres <- c(
        "P_INSEG_LUGARES_1"  = "Vehículo",
        "P_INSEG_LUGARES_3"  = "Transporte público",
        "P_INSEG_LUGARES_7"  = "Restaurante/bar",
        "P_INSEG_LUGARES_8"  = "Terminal buses",
        "P_INSEG_LUGARES_10" = "Centro comercial",
        "P_INSEG_LUGARES_12" = "Parque/plaza",
        "P_INSEG_LUGARES_16" = "Banco"
      )
      
      inseg_labels <- c(
        "1" = "Muy inseguro/a",
        "2" = "Inseguro/a",
        "3" = "Seguro/a",
        "4" = "Muy seguro/a",
        "85" = "No aplica",
        "88" = "No sabe",
        "99" = "No responde"
      )
      
      respuestas_validas <- c("1", "2", "3", "4")
      
      df_long <- df %>%
        dplyr::select(all_of(lugares_vars)) %>%
        pivot_longer(cols = everything(), names_to = "lugar", values_to = "respuesta") %>%
        filter(respuesta %in% respuestas_validas) %>%
        
        mutate(
          lugar = dplyr::recode(lugar, !!!lugares_nombres),
          respuesta = factor(dplyr::recode(as.character(respuesta), !!!inseg_labels),
                             levels = c("Muy inseguro/a", "Inseguro/a", "Seguro/a", "Muy seguro/a"))
          
        ) %>%
        group_by(lugar, respuesta) %>%
        summarise(n = n(), .groups = "drop") %>%
        group_by(lugar) %>%
        mutate(porcentaje = 100 * n / sum(n)) %>%
        ungroup()
      
      # Totales por lugar
      totales_lugar <- df_long %>%
        group_by(lugar) %>%
        summarise(total = sum(n), .groups = "drop") %>%
        mutate(lugar_factor = fct_rev(factor(lugar, levels = unique(lugar))))
      
      
      # Gráfico
      grafico <- plot_ly(
        df_long,
        x = ~porcentaje,
        y = ~fct_rev(factor(lugar, levels = unique(df_long$lugar))),
        color = ~respuesta,
        type = "bar",
        orientation = "h",
        hoverinfo = "text",
        hovertext = ~paste0(respuesta, ": ", round(porcentaje, 1), "% (", n, " personas)"),
        colors = rev(RColorBrewer::brewer.pal(4, "RdYlBu"))
      ) %>%
        layout(
          barmode = "stack",
          xaxis = list(title = "Porcentaje",  tickfont = list(size = 10)),
          yaxis = list(title = "",  tickfont = list(size = 16)),
          legend = list(title = list(text = "Percepción")),
          margin = list(l = 120)
        )
      
      
      grafico
    })
    
    
  }
  
  #---------------------------------#
  #-----Confianza institucional-----#
  #---------------------------------#
  {
    # cantidad delitos
    output$cantidad_delitos <- renderValueBox({
      df <- datos_filtrados() %>%
        filter(SCREEN_ROB_RDV_N > 0 | SCREEN_ROB_RFV_N > 0 | SCREEN_ROB_RVI_N > 0 | SCREEN_ROB_FRB_N > 0)
      total_respuestas <- nrow(datos_filtrados())
      
      if (total_respuestas == 0) {
        return("Sin datos")
      }
      
      cantidad_delitos <- sum(df$SCREEN_ROB_RDV_N, df$SCREEN_ROB_RFV_N, df$SCREEN_ROB_RVI_N, df$SCREEN_ROB_FRB_N, na.rm = TRUE)
      valueBox(cantidad_delitos, h4("Delitos cometidos"), icon = icon("exclamation-triangle"), color = "red")
    })
    
    # Tasa intento delito
    output$cantidad_intentos <- renderValueBox({
      df <- datos_filtrados() %>%
        filter(
          (SCREEN_INT_RDV_N > 0 & is.na(SCREEN_ROB_RDV_N)) | 
            (SCREEN_INT_RFV_N > 0 & is.na(SCREEN_ROB_RFV_N)) | 
            (SCREEN_INT_RVI_N > 0 & is.na(SCREEN_ROB_RVI_N))
        )
      total_respuestas <- nrow(datos_filtrados())
      
      if (total_respuestas == 0) {
        return("Sin datos")
      }
      
      cantidad_intentos <- sum(df$SCREEN_INT_RDV_N, df$SCREEN_INT_RFV_N, df$SCREEN_INT_RVI_N, na.rm = TRUE)
      valueBox(cantidad_intentos, h4("Intentos de delitos"), icon = icon("hand-holding"), color = "orange")
    })
    
    # cantidad denuncias
    output$cantidad_denuncias <- renderValueBox({
      df <- datos_filtrados()
      
      total_delitos <- sum(df$SCREEN_ROB_RDV_N, df$SCREEN_ROB_RFV_N, df$SCREEN_ROB_RVI_N, df$SCREEN_ROB_FRB_N, na.rm = TRUE)
      total_denuncias <- sum(df$RDV_DENUNCIAS_N, df$RFV_DENUNCIAS_N, df$RVI_DENUNCIAS_N, df$FRB_DENUNCIAS_N, na.rm = TRUE)
      
      if (total_delitos == 0) {
        return("Sin datos")
      }
      valueBox(total_denuncias, h4("Denuncias formales"), icon = icon("balance-scale"), color = "aqua")
    })
    
    
    output$grafico_confianza_instituciones <- renderPlotly({
      datos_confianza <- datos_filtrados() %>%
        mutate(
          total_delitos = rowSums(across(c(SCREEN_ROB_RDV_N, SCREEN_ROB_RFV_N, SCREEN_ROB_RVI_N, SCREEN_ROB_FRB_N)), na.rm = TRUE),
          víctima = ifelse(total_delitos > 0, 1, 0),
          víctima = factor(víctima, labels = c("No víctima", "Víctima"))
        ) %>%
        dplyr::select(víctima, EV_CONFIA_CCH, EV_CONFIA_PDI, EV_CONFIA_FMP) %>%
        pivot_longer(cols = c(EV_CONFIA_CCH, EV_CONFIA_PDI, EV_CONFIA_FMP),
                     names_to = "Institucion",
                     values_to = "Confianza") %>%
        filter(Confianza %in% 1:4) %>%
        mutate(
          Institucion = dplyr::recode(Institucion,
                                      "EV_CONFIA_CCH" = "Carabineros",
                                      "EV_CONFIA_PDI" = "PDI",
                                      "EV_CONFIA_FMP" = "Fiscalía"),
          Confianza = factor(Confianza,
                             levels = 1:4,
                             labels = c("Mucha", "Bastante", "Poca", "Ninguna")),
          Grupo = paste(Institucion, "-", víctima)  # Combinación para el eje X
        ) %>%
        count(Grupo, Confianza) %>%
        group_by(Grupo) %>%
        mutate(porcentaje = n / sum(n) ) %>%
        ungroup()
      
      plot_ly(
        datos_confianza,
        x = ~Grupo,
        y = ~porcentaje,
        color = ~Confianza,
        colors = c("Mucha" = "#337ca0",
                   "Bastante" = "#3ec300",
                   "Poca" = "#fffc31",
                   "Ninguna" = "#ff1d15"),
        type = "bar",
        hoverinfo = "text",
        hovertext = ~paste0("Nivel: ", Confianza, "<br>",
                            "Porcentaje: ", round(porcentaje*100,0), "%")
      ) %>%
        layout(
          barmode = "stack",
          title = list(
            text = "",
            font = list(size = 20)  # Tamaño del título
          ),
          xaxis = list(
            title = "Institución y condición de víctima",
            tickangle = 45,
            titlefont = list(size = 16),      # Título eje X
            tickfont = list(size = 14)        # Etiquetas eje X
          ),
          yaxis = list(
            title = "Porcentaje",
            tickformat = ".0%",
            range = c(0, 1),
            titlefont = list(size = 16),      # Título eje Y
            tickfont = list(size = 14)        # Etiquetas eje Y
          ),
          legend = list(
            title = list(text = "Confianza", font = list(size = 16)),
            font = list(size = 14)            # Texto dentro de la leyenda
          ),
          margin = list(b = 100)
        )
      
    })
    
    
  }
  
  #---------------------------------#
  #----------Victimización----------#
  #---------------------------------#
  {  
  output$treemap_incivilidades <- renderPlotly({
    # 1) Variables de incivilidades
    inciv_vars <- c("P_INCIVILIDADES_4",
                    "P_INCIVILIDADES_6",
                    "P_INCIVILIDADES_7")
    
    # 2) Labels puros (solo niveles 1:5)
    labels_inciv <- unname(P_INCIVILIDADES_[as.character(1:5)])
    
    # 3) Renombro tus vectores para no pisar nombres
    region_labels <- enc_region
    comuna_labels <- enc_rpc
    
    # 4) Pivot largo y mapeo
    df_inc <- datos_filtrados() %>% # Usa tu reactive datos_filtrados()
      dplyr::select(enc_region, enc_rpc, all_of(inciv_vars)) %>%
      pivot_longer(all_of(inciv_vars),
                   names_to  = "incivilidad",
                   values_to = "respuesta") %>%
      filter(respuesta %in% 4:5) %>%
      mutate(
        categoria = factor(respuesta,
                           levels = 1:5,
                           labels = labels_inciv),
        region    = region_labels[as.character(enc_region)],
        comuna    = comuna_labels[as.character(enc_rpc)]
      )
    
    # Manejo de caso sin datos
    if (nrow(df_inc) == 0) {
      return(plotly_empty() %>%
               layout(title = "No hay datos para mostrar el Treemap con los filtros seleccionados."))
    }
    
    # La lógica para decidir si usar comunas o regiones como nivel superior
    # Se basa en si el filtro 'region' está activo.
    usar_comunas_en_plot <- !is.null(input$region) && length(input$region) > 0
    
    # 5) Preparar los dataframes df_padre y df_hijos según si usamos comunas o regiones
    if (usar_comunas_en_plot) {
      # Si hay una región seleccionada, el nivel superior del treemap serán las comunas
      df_padre <- df_inc %>%
        group_by(comuna) %>% # Agrupar por comuna
        summarise(n = n(), .groups = "drop") %>%
        transmute(
          id     = as.character(comuna),
          label  = as.character(comuna),
          parent = "", # Los padres de las comunas son la raíz (vacío)
          value  = n
        )
      
      df_hijos <- df_inc %>%
        group_by(comuna, categoria) %>% # Incivilidades dentro de cada comuna
        summarise(n = n(), .groups = "drop") %>%
        transmute(
          id     = paste0(as.character(comuna), "-", as.character(categoria)), # ID único
          label  = as.character(categoria), # Texto visible
          parent = as.character(comuna), # El padre es la comuna
          value  = n
        )
      graph_title <- if (length(input$region) == 1) {
        paste0("Percepción de Incivilidades en Comunas de ", region_labels[as.character(input$region)])
      } else {
        "Percepción de Incivilidades en Comunas Seleccionadas"
      }
      
    } else {
      # Si no hay región seleccionada, el nivel superior del treemap serán las regiones
      df_padre <- df_inc %>%
        group_by(region) %>% # Agrupar por región
        summarise(n = n(), .groups = "drop") %>%
        transmute(
          id     = as.character(region),
          label  = as.character(region),
          parent = "", # Los padres de las regiones son la raíz (vacío)
          value  = n
        )
      
      df_hijos <- df_inc %>%
        group_by(region, categoria) %>% # Incivilidades dentro de cada región
        summarise(n = n(), .groups = "drop") %>%
        transmute(
          id     = paste0(as.character(region), "-", as.character(categoria)),
          label  = as.character(categoria),
          parent = as.character(region), # El padre es la región
          value  = n
        )
      graph_title <- "Percepción de incivilidades por región"
    }
    
    # Combinar todos los nodos
    nodos <- bind_rows(df_padre, df_hijos)
    
    # **Nueva verificación adicional:** Si después de la preparación no quedan nodos
    if (nrow(nodos) == 0) {
      return(plotly_empty() %>%
               layout(title = "No se encontraron percepciones de incivilidades para graficar."))
    }
    
    # Treemap con `ids`, `labels`, `parents`
    plot_ly(
      type         = "treemap",
      ids          = nodos$id,
      labels       = nodos$label,
      parents      = nodos$parent,
      values       = nodos$value,
      branchvalues = "total", # Calcula el tamaño de los padres sumando los hijos
      textinfo     = "label+value", # Muestra el nombre y el valor de la celda
      textfont     = list(size = 18)
    ) %>%
      layout(
        margin = list(t = 40, l = 10, r = 10, b = 10),
        uniformtext = list(minsize = 10, mode = "hide"), # Ajusta minsize
        title = list(text = graph_title, x = 0.5) # Título dinámico y centrado
      )
  })
  
  
  output$barplot_incivilidades_counts <- renderPlotly({
    df_inc <- df_inc_processed() # Usamos la misma expresión reactiva
    
    if (nrow(df_inc) == 0) {
      return(plotly_empty() %>%
               layout(title = "No hay datos para el Barplot"))
    }
    incivilidad_descripciones <- c(
      "P_INCIVILIDADES_4" = "Peleas callejeras con \n armas blancas o de fuego",
      "P_INCIVILIDADES_6" = "Robos o asaltos en \n la vía pública",
      "P_INCIVILIDADES_7" = "Balaceras o disparos"
    )
    # Agregamos los datos para el gráfico de barras: contar por cada tipo de INCIVILIDAD (pregunta)
    barplot_data <- df_inc %>%
      # Usamos la columna 'incivilidad' que contiene P_INCIVILIDADES_4, _6, _7
      group_by(incivilidad) %>%
      summarise(count = n(), .groups = "drop") %>%
      # Opcional: añadir la descripción completa de la pregunta
      mutate(incivilidad_desc = incivilidad_descripciones[incivilidad]) %>%
      arrange(desc(count)) # Ordenamos por cantidad descendente
    
    # Crear el gráfico de barras
    p_bar <- plot_ly(
      data = barplot_data,
      x = ~incivilidad_desc, # Usamos la descripción completa en el eje X
      y = ~count,
      type = "bar",
      marker = list(color = "steelblue") # Puedes cambiar el color
    ) %>%
      layout(
        title = "Percepción de cantidad Incivilidades",
        xaxis = list(title = "Tipo de Incivilidad", categoryorder = "array", categoryarray = ~incivilidad_desc, tickangle = -45), # Rotamos etiquetas
        yaxis = list(title = "Cantidad de Reportes"),
        margin = list(l = 50, r = 20, b = 150, t = 50) # Ajustar margen inferior si las etiquetas rotadas son muy largas
      )
    
    return(p_bar)
  })
  
  }
  
  #---------------------------------#
  #---------- Agrupación -----------#
  #---------------------------------#
  
  datos_para_mca <- reactive({
    datos_filtrados() %>%
      mutate(
        # Victima (igual que antes)
        total_delitos = rowSums(across(c(
          SCREEN_ROB_RDV_N, SCREEN_ROB_RFV_N,
          SCREEN_ROB_RVI_N, SCREEN_ROB_FRB_N
        )), na.rm = TRUE),
        victima = factor(
          ifelse(total_delitos > 0, 1, 0),
          labels = c("No víctima", "Víctima")
        ),
        
        # 1) Incivilidades: si ALGUNA de estas columnas (existentes) ∈ {3,4,5}
        Incivilidades = as.integer(
          if_any(
            any_of(c("P_INCIVILIDADES_4", "P_INCIVILIDADES_6", "P_INCIVILIDADES_7")),
            ~ .x %in% c(3,4,5)
          )
        ),
        
        # 2) INSEGURIDAD_LUGARES: si ALGUNA de estas columnas (existentes) ∈ {1,2}
        INSEGURIDAD_LUGARES = as.integer(
          if_any(
            any_of(c(
              "P_INSEG_LUGARES_1",  "P_INSEG_LUGARES_3",
              "P_INSEG_LUGARES_7",  "P_INSEG_LUGARES_8",
              "P_INSEG_LUGARES_9",  "P_INSEG_LUGARES_10",
              "P_INSEG_LUGARES_12", "P_INSEG_LUGARES_16"
            )),
            ~ .x %in% 1:2
          )
        ),
        
        # 3) DESCONFIANZA_INSTITUCIONAL: si ALGUNA de estas ∈ {3,4}
        DESCONFIANZA_INSTITUCIONAL = as.integer(
          if_any(
            any_of(c("EV_CONFIA_CCH", "EV_CONFIA_PDI", "EV_CONFIA_FMP")),
            ~ .x %in% 3:4
          )
        )
      ) %>%
      # conviertes a factor sólo las que vas a usar en la MCA
      mutate(across(
        c(Incivilidades, INSEGURIDAD_LUGARES,
          DESCONFIANZA_INSTITUCIONAL,
          P_EXPOS_DELITO, victima, rph_edad),
        factor
      ))
  })
  
  {
    output$ACM2D <- renderPlotly({
      
      # 1) Traigo tu tabla filtrada
      datos0 <- datos_filtrados()
      
      # 2) Relleno con 0 cualquier columna que falte,
      #    para que mutate pueda crear todas las variables
      orig_vars <- c(
        "P_INCIVILIDADES_4","P_INCIVILIDADES_6","P_INCIVILIDADES_7",
        "P_INSEG_LUGARES_1","P_INSEG_LUGARES_3","P_INSEG_LUGARES_7",
        "P_INSEG_LUGARES_8","P_INSEG_LUGARES_9","P_INSEG_LUGARES_10",
        "P_INSEG_LUGARES_12","P_INSEG_LUGARES_16",
        "EV_CONFIA_CCH","EV_CONFIA_PDI","EV_CONFIA_FMP",
        "P_EXPOS_DELITO",
        "SCREEN_ROB_RDV_N","SCREEN_ROB_RFV_N","SCREEN_ROB_RVI_N","SCREEN_ROB_FRB_N"
      )
      faltan <- setdiff(orig_vars, names(datos0))
      for(v in faltan) datos0[[v]] <- 0
      
      # 3) Creo las 5 variables en un tibble intermedio
      prep <- datos0 %>%
        dplyr::mutate(
          total_delitos = rowSums(across(c(
            SCREEN_ROB_RDV_N, SCREEN_ROB_RFV_N,
            SCREEN_ROB_RVI_N, SCREEN_ROB_FRB_N
          )), na.rm = TRUE),
          victima = factor(ifelse(total_delitos>0,"Víctima","No víctima"),
                           levels=c("No víctima","Víctima")),
          Incivilidades = factor(
            as.integer(if_any(
              any_of(c("P_INCIVILIDADES_4","P_INCIVILIDADES_6","P_INCIVILIDADES_7")),
              ~ .x %in% c(3,4,5)
            )), levels=0:1, labels=c("No","Sí")
          ),
          INSEGURIDAD_LUGARES = factor(
            as.integer(if_any(
              any_of(c(
                "P_INSEG_LUGARES_1","P_INSEG_LUGARES_3","P_INSEG_LUGARES_7",
                "P_INSEG_LUGARES_8","P_INSEG_LUGARES_9","P_INSEG_LUGARES_10",
                "P_INSEG_LUGARES_12","P_INSEG_LUGARES_16"
              )), ~ .x %in% 1:2
            )), levels=0:1, labels=c("No","Sí")
          ),
          DESCONFIANZA_INSTITUCIONAL = factor(
            as.integer(if_any(
              any_of(c("EV_CONFIA_CCH","EV_CONFIA_PDI","EV_CONFIA_FMP")),
              ~ .x %in% 3:4
            )), levels=0:1, labels=c("No","Sí")
          ),
          P_EXPOS_DELITO = factor(P_EXPOS_DELITO)
        )
      
      # 4) Ahora construyo un data.frame EXACTO con solo esas 5 columnas
      df_acm <- data.frame(
        Incivilidades            = prep$Incivilidades,
        INSEGURIDAD_LUGARES       = prep$INSEGURIDAD_LUGARES,
        DESCONFIANZA_INSTITUCIONAL= prep$DESCONFIANZA_INSTITUCIONAL,
        P_EXPOS_DELITO            = prep$P_EXPOS_DELITO,
        stringsAsFactors = TRUE
      )
      # Quito filas incompletas
      df_acm <- df_acm[complete.cases(df_acm), , drop = FALSE]
      
      if(nrow(df_acm) < 3) {
        showNotification("❌ No hay suficientes datos limpios para ACM", type="error")
        return(NULL)
      }
      
      # 5) k-modes directamente
      set.seed(77362)
      km <- klaR::kmodes(df_acm, modes = 2, iter.max = 10)
      df_acm$Cluster <- factor(km$cluster, labels = c("Grupo 1","Grupo 2"))
      
      # 6) Muestreo de hasta 1000
      subs <- if(nrow(df_acm) > 1000) sample(nrow(df_acm), 1000) else seq_len(nrow(df_acm))
      
      # 7) MCA sobre esas 5 variables (ahora siempre están en df_acm 1:5)
      mca_res <- FactoMineR::MCA(df_acm[subs, 1:5], graph = FALSE, ncp = 3)
      var1 <- round(mca_res$eig[1,2], 1)
      var2 <- round(mca_res$eig[2,2], 1)
      
      p_mca <- factoextra::fviz_mca_ind(
        mca_res, geom="point",
        habillage = df_acm$Cluster[subs],
        palette = "jco", repel = TRUE, addEllipses = FALSE
      ) +
        ggplot2::labs(
          x = paste0("Dim 1 (", var1, "%)"),
          y = paste0("Dim 2 (", var2, "%)")
        ) +
        ggplot2::theme_minimal() +
        ggplot2::theme(plot.margin = ggplot2::margin(0,0,0,0))
      
      g_mca <- plotly::ggplotly(p_mca) %>%
        plotly::layout(
          margin     = list(l=50, r=50, b=0, t=0),
          xaxis      = list(showgrid=TRUE),
          yaxis      = list(showgrid=TRUE),
          showlegend = FALSE
        )
      
      # 8) Silhouette con Gower
      diss <- cluster::daisy(df_acm[subs, 1:5], metric="gower")
      sil  <- cluster::silhouette(as.numeric(km$cluster[subs]), diss)
      avgw <- round(mean(sil[, "sil_width"]), 3)
      
      p_sil <- factoextra::fviz_silhouette(sil) +
        ggplot2::geom_vline(xintercept = avgw, linetype="dashed") +
        ggplot2::theme_minimal() +
        ggplot2::theme(
          plot.title   = element_blank(),
          axis.title.x = element_blank(),
          axis.text.x  = element_blank(),
          axis.ticks.x = element_blank(),
          plot.margin  = ggplot2::margin(0,0,0,0)
        )
      g_sil <- plotly::ggplotly(p_sil) %>%
        plotly::layout(
          title  = list(text=""),
          xaxis  = list(visible=FALSE),
          margin = list(l=0, r=20, b=0, t=0)
        )
      
      # 9) Ensamblo y guardo
      resultados_acm$df_acm_clean_with_cluster <- df_acm
      resultados_acm$df_acm_subs <- subs
      resultados_acm$df_acm_mca_res <-mca_res
      resultados_acm$df_acm_mca_res_e1 <-var1
      resultados_acm$df_acm_mca_res_e2 <-var2
      
      resultados_acm$df_acm_sil_diss <- diss
      resultados_acm$df_acm_sil_sil <- sil
      resultados_acm$df_acm_sil_avgw <- avgw
      
      plotly::subplot(
        g_mca, g_sil,
        nrows   = 1,
        widths  = c(0.5, 0.5),
        margin  = 0.02,
        shareY  = FALSE
      )
    })
    
    
    #---------------------------------#
    #---------- Scree plot -----------#
    #---------------------------------#
    
    # 2) Renderiza el scree plot de la MCA
    output$mca_scree <- renderPlotly({
      df <- datos_para_mca()
      req(nrow(df) > 0)
      
      vars <- c(
        "Incivilidades",
        "INSEGURIDAD_LUGARES",
        "DESCONFIANZA_INSTITUCIONAL",
        "P_EXPOS_DELITO"
      )
      
      # Selección “a prueba de fallos”:
      cols_ok <- intersect(vars, colnames(df))
      validate(need(length(cols_ok) >= 2,
                    paste0("Faltan vars: ",
                           paste(setdiff(vars, cols_ok), collapse = ", "))))
      
      df_sel <- df[, cols_ok, drop = FALSE]
      mca_res <- FactoMineR::MCA(df_sel, graph = FALSE)
      eig_df <- as.data.frame(mca_res$eig)
      colnames(eig_df)[2] <- "perc_var"
      eig_df$Dimension <- seq_len(nrow(eig_df))
      
      p <- ggplot2::ggplot(eig_df, aes(x = factor(Dimension), y = perc_var)) +
        ggplot2::geom_col(fill = "#2c7fb8", width = 0.6) +
        ggplot2::geom_text(aes(label = sprintf("%.1f%%", perc_var)),
                           vjust = -0.5, size = 3.5, color = "#084594") +
        ggplot2::labs(
          title    = "Scree Plot de la MCA",
          subtitle = "Porcentaje de inercia explicada por cada dimensión",
          x        = "Dimensión",
          y        = "Varianza explicada (%)"
        ) +
        ggplot2::theme_minimal(base_size = 14) +
        ggplot2::theme(
          plot.title      = element_text(face = "bold", size = 18),
          plot.subtitle   = element_text(size = 12, margin = margin(b = 10)),
          axis.title      = element_text(face = "bold"),
          axis.text.x     = element_text(angle = 0, vjust = 0.5),
          panel.grid.major = element_line(color = "gray85"),
          panel.grid.minor = element_blank()
        )
      resultados_acm$df_scree <- eig_df
      plotly::ggplotly(p) %>%
        plotly::layout(
          margin = list(l = 50, r = 20, b = 50, t = 80)
        )
    })
    
    #---------------------------------#
    #------- Entropía / DT -----------#
    #---------------------------------#
    tabla_resumen_acm <- reactive({
      df <- resultados_acm$df_acm_clean_with_cluster
      req(df)
      
      vars <- c(
        "Incivilidades",
        "INSEGURIDAD_LUGARES",
        "DESCONFIANZA_INSTITUCIONAL",
        "P_EXPOS_DELITO"
      )
      df_long <- df %>%
        dplyr::select(all_of(vars), Cluster) %>%
        tidyr::pivot_longer(
          cols      = all_of(vars),
          names_to  = "Variable",
          values_to = "Respuesta"
        )
      counts <- df_long %>%
        dplyr::count(Variable, Respuesta, Cluster, name = "n")
      totals <- df_long %>%
        dplyr::count(Variable, Cluster, name = "total")
      pct <- counts %>%
        dplyr::left_join(totals, by = c("Variable","Cluster")) %>%
        dplyr::mutate(pct = round(n / total * 100, 1)) %>%
        dplyr::select(Variable, Respuesta, Cluster, pct)
      wide <- pct %>%
        tidyr::pivot_wider(
          names_from  = Cluster,
          values_from = pct,
          values_fill = 0
        ) %>%
        dplyr::rename(
          `% Grupo 1` = `Grupo 1`,
          `% Grupo 2` = `Grupo 2`
        ) %>%
        dplyr::arrange(Variable, Respuesta)
      wide
    })
    output$tabla_entropia <- DT::renderDataTable({
      DT::datatable(
        tabla_resumen_acm(),
        rownames = FALSE,
        class    = "compact stripe",
        options  = list(
          pageLength = 10,
          dom        = "tip",
          autoWidth  = TRUE
        )
      )
    })
  }

  
      
  #---------------------------------#
  #-----------Conclusión------------#
  #---------------------------------#

  output$conclusiones_generadas <- renderUI({
    df_filtered <- datos_filtrados()
    
    if (is.null(df_filtered) || nrow(df_filtered) == 0) {
      return(h4("No hay datos disponibles para generar conclusiones con los filtros actuales."))
    }
    
    all_conclusions_html_parts <- c()
    
    # 1. Conclusión: Regiones con mayor percepción de aumento de inseguridad
    {
      perc_aumento_region <- df_filtered %>%
        filter(P_AUMENTO_COM %in% c(1, 2, 3)) %>%
        group_by(enc_region) %>%
        summarise(
          total = n(),
          aumento_count = sum(P_AUMENTO_COM == 1, na.rm = TRUE),
          perc_aumento = (aumento_count / total) * 100
        ) %>%
        arrange(desc(perc_aumento)) %>%
        head(3)
      
      if (nrow(perc_aumento_region) > 0) {
        regions_text <- paste0(
          "Las regiones de Chile que más perciben que la inseguridad en su comuna aumentó fueron ",
          paste(sapply(perc_aumento_region$enc_region, function(x) enc_region[as.character(x)]), collapse = ", "),
          " con una percepción de aumento del ",
          paste(round(perc_aumento_region$perc_aumento, 2), "%", collapse = ", "),
          " respectivamente."
        )
        
        region_conclusion_html <- paste0(
          '<div class="conclusion-box">',
          '<h4> <i class="fas fa-location-dot fa-lg" role="presentation" aria-label="location-dot icon"></i> <strong>Percepción Regional de Inseguridad</strong> </h4>',
          '<p>', regions_text, '</p>',
          '<p><strong>Recomendación:</strong> Se sugiere focalizar recursos y programas de seguridad preventiva en estas regiones, impulsando la coordinación entre autoridades locales y la comunidad.</p>',
          '</div>'
        )
        all_conclusions_html_parts <- c(all_conclusions_html_parts, region_conclusion_html)
      }
    }
    
    # 2. Conclusión: Comunas con mayor inseguridad en la región más afectada
    {
      if (exists("perc_aumento_region") && nrow(perc_aumento_region) > 0) {
        top_region_code <- perc_aumento_region$enc_region[1]
        top_region_name <- enc_region[as.character(top_region_code)]
        
        perc_aumento_comuna_top_region <- df_filtered %>%
          filter(enc_region == top_region_code, P_AUMENTO_COM %in% c(1, 2, 3)) %>%
          group_by(enc_rpc) %>%
          summarise(
            total = n(),
            aumento_count = sum(P_AUMENTO_COM == 1, na.rm = TRUE),
            perc_aumento = (aumento_count / total) * 100
          ) %>%
          arrange(desc(perc_aumento)) %>%
          head(3)
        
        if (nrow(perc_aumento_comuna_top_region) > 0) {
          communes_text <- paste0(
            "Las comunas con mayor percepción de inseguridad dentro de ", top_region_name, " fueron ",
            paste(sapply(perc_aumento_comuna_top_region$enc_rpc, function(x) enc_rpc[as.character(x)]), collapse = ", "),
            "."
          )
          commune_conclusion_html <- paste0(
            '<div class="conclusion-box">',
            '<h4> <i class="fas fa-city fa-lg" role="presentation" aria-label="city icon"></i> <strong>Puntos Calientes de Inseguridad Comunal</strong> </h4>',
            '<p>', communes_text, '</p>',
            '<p><strong>Recomendación:</strong> Para estas comunas, se recomienda un mayor despliegue de personal policial, a través de rondas nocturnas y en sectores más frecuentados, y el fortalecimiento de la vigilancia comunitaria.</p>',
            '</div>'
          )
          all_conclusions_html_parts <- c(all_conclusions_html_parts, commune_conclusion_html)
        }
      }
    }
    
    # 3. Conclusión: Lugares y situaciones de mayor inseguridad percibida
    {
      inseg_places_vars <- c("P_INSEG_LUGARES_1", "P_INSEG_LUGARES_3", "P_INSEG_LUGARES_7",
                             "P_INSEG_LUGARES_8", "P_INSEG_LUGARES_10",
                             "P_INSEG_LUGARES_12", "P_INSEG_LUGARES_16")
      
      inseg_df <- df_filtered %>%
        dplyr::select(all_of(inseg_places_vars)) %>%
        tidyr::pivot_longer(cols = everything(), names_to = "variable", values_to = "value") %>%
        filter(value %in% c(1, 2)) # 'Muy inseguro/a' o 'Inseguro/a'
      
      if (nrow(inseg_df) > 0) {
        top_inseg_places <- inseg_df %>%
          group_by(variable) %>%
          summarise(insecurity_count = n()) %>%
          arrange(desc(insecurity_count)) %>%
          head(3)
        
        place_labels_map <- c(
          "P_INSEG_LUGARES_1" = "Trasladándose en vehículo",
          "P_INSEG_LUGARES_3" = "En transporte público",
          "P_INSEG_LUGARES_7" = "En un restaurante, bar, pub, café, discoteque u otro lugar de recreación",
          "P_INSEG_LUGARES_8" = "En un terminal de buses o ferrocarriles",
          "P_INSEG_LUGARES_10" = "En centros comerciales o malls",
          "P_INSEG_LUGARES_12" = "En plazas o parques de su barrio",
          "P_INSEG_LUGARES_16" = "En el banco"
        )
        
        top_places_names <- sapply(top_inseg_places$variable, function(x) place_labels_map[x])
        
        places_text <- paste0(
          "La muestra reporta que los lugares y situaciones en los que se sienten más inseguros son: ",
          paste(top_places_names, collapse = ", "),
          "."
        )
        
        places_conclusion_html <- paste0(
          '<div class="conclusion-box">',
          '<h4> <i class="far fa-face-frown fa-lg" role="presentation" aria-label="face-frown icon"></i> <strong>Zonas de Alta Inseguridad Percibida</strong> </h4>',
          '<p>', places_text, '</p>',
          '<p><strong>Recomendación:</strong> Se recomienda mantener un mayor control de estas zonas específicas, incluyendo aumento de patrullajes, mejoras en la iluminación y cámaras de seguridad.</p>',
          '</div>'
        )
        all_conclusions_html_parts <- c(all_conclusions_html_parts, places_conclusion_html)
      }
    }
    
    # 4. Conclusión: Confianza en instituciones, victimización y denuncias
    {
      # Calcular cantidades de delitos y denuncias para la tasa
      total_delitos_reported <- sum(df_filtered$SCREEN_ROB_RDV_N, df_filtered$SCREEN_ROB_RFV_N, df_filtered$SCREEN_ROB_RVI_N, df_filtered$SCREEN_ROB_FRB_N, na.rm = TRUE)
      # total_intentos_reported <- sum(df_filtered$SCREEN_INT_RDV_N, df_filtered$SCREEN_INT_RFV_N, df_filtered$SCREEN_INT_RVI_N, na.rm = TRUE) # Ya no se usa directamente en el texto
      
      total_denuncias_reported <- sum(df_filtered$RDV_DENUNCIAS_N, df_filtered$RFV_DENUNCIAS_N, df_filtered$RVI_DENUNCIAS_N, df_filtered$FRB_DENUNCIAS_N, na.rm = TRUE)
      
      denunciation_rate <- if (total_delitos_reported > 0) (total_denuncias_reported / total_delitos_reported) * 100 else 0
      
      # Preparar datos para el análisis de confianza, similar al gráfico
      datos_confianza_plot <- df_filtered %>%
        mutate(
          total_delitos_victim = rowSums(across(c(SCREEN_ROB_RDV_N, SCREEN_ROB_RFV_N, SCREEN_ROB_RVI_N, SCREEN_ROB_FRB_N)), na.rm = TRUE),
          víctima = ifelse(total_delitos_victim > 0, 1, 0),
          víctima_label = factor(víctima, labels = c("No víctima", "Víctima"))
        ) %>%
        dplyr::select(víctima_label, EV_CONFIA_CCH, EV_CONFIA_PDI, EV_CONFIA_FMP) %>%
        pivot_longer(cols = c(EV_CONFIA_CCH, EV_CONFIA_PDI, EV_CONFIA_FMP),
                     names_to = "Institucion_Code",
                     values_to = "Confianza_Code") %>%
        filter(Confianza_Code %in% 1:4) %>% # Filtrar 88/99
        mutate(
          Institucion_Label = dplyr::recode(Institucion_Code,
                                            "EV_CONFIA_CCH" = "Carabineros",
                                            "EV_CONFIA_PDI" = "PDI",
                                            "EV_CONFIA_FMP" = "Fiscalía")
        )
      
      # Calcular porcentajes de personas que CONFÍAN (valores 1 o 2) por institución y estado de víctima
      confidence_summary <- datos_confianza_plot %>%
        group_by(Institucion_Label, víctima_label) %>%
        summarise(
          total_resp = n(),
          conf_count = sum(Confianza_Code %in% c(1, 2), na.rm = TRUE), # "Mucha" o "Bastante"
          perc_conf = (conf_count / total_resp) * 100,
          .groups = 'drop'
        )
      
      # Extraer porcentajes para el texto
      perc_conf_cch_general <- confidence_summary %>% filter(Institucion_Label == "Carabineros", víctima_label == "No víctima") %>% pull(perc_conf)
      perc_conf_cch_victima <- confidence_summary %>% filter(Institucion_Label == "Carabineros", víctima_label == "Víctima") %>% pull(perc_conf)
      
      perc_conf_pdi_general <- confidence_summary %>% filter(Institucion_Label == "PDI", víctima_label == "No víctima") %>% pull(perc_conf)
      perc_conf_pdi_victima <- confidence_summary %>% filter(Institucion_Label == "PDI", víctima_label == "Víctima") %>% pull(perc_conf)
      
      perc_conf_fmp_general <- confidence_summary %>% filter(Institucion_Label == "Fiscalía", víctima_label == "No víctima") %>% pull(perc_conf)
      perc_conf_fmp_victima <- confidence_summary %>% filter(Institucion_Label == "Fiscalía", víctima_label == "Víctima") %>% pull(perc_conf)
      
      
      # Construir el texto de la conclusión
      confidence_comparison_text <- "En cuanto a la confianza institucional, se observa un patrón claro: las personas que han sido víctimas de un delito tienden a tener un menor nivel de confianza en las instituciones encargadas de la seguridad."
      
      if (length(perc_conf_cch_general) > 0 && length(perc_conf_cch_victima) > 0) {
        confidence_comparison_text <- paste0(
          confidence_comparison_text, " Por ejemplo, el porcentaje de confianza (Mucha o Bastante) en <strong>Carabineros</strong> es del <strong>",
          round(perc_conf_cch_general, 2), "%</strong> para no víctimas vs. <strong>",
          round(perc_conf_cch_victima, 2), "%</strong> para víctimas. "
        )
      }
      
      if (length(perc_conf_pdi_general) > 0 && length(perc_conf_pdi_victima) > 0) {
        confidence_comparison_text <- paste0(
          confidence_comparison_text, "Similarmente, para la <strong>PDI</strong>, la confianza es del <strong>",
          round(perc_conf_pdi_general, 2), "%</strong> para no víctimas y <strong>",
          round(perc_conf_pdi_victima, 2), "%</strong> para víctimas. "
        )
      }
      
      if (length(perc_conf_fmp_general) > 0 && length(perc_conf_fmp_victima) > 0) {
        confidence_comparison_text <- paste0(
          confidence_comparison_text, "En la <strong>Fiscalía</strong>, los porcentajes son <strong>",
          round(perc_conf_fmp_general, 2), "%</strong> (no víctimas) vs. <strong>",
          round(perc_conf_fmp_victima, 2), "%</strong> (víctimas)."
        )
      }
      
      # El párrafo de la tasa de denuncia se integra al final de la comparación de confianza
      denunciation_text <- paste0("Esta diferencia en la confianza se ve reforzada por una baja tasa de denuncias de los delitos reportados (aproximadamente el <strong>", round(denunciation_rate, 2), "%</strong> de los delitos reportados son denunciados formalmente), lo que sugiere una falta de creencia en la efectividad del sistema para abordar sus experiencias.")
      
      
      confidence_conclusion_html <- paste0(
        '<div class="conclusion-box">',
        '<h4> <i class="fas fa-handshake-simple-slash fa-lg" role="presentation" aria-label="handshake-simple-slash icon"></i> <strong>Confianza Institucional y Reporte de Delitos</strong> </h4>',
        '<p>', confidence_comparison_text, '</p>',
        '<p>', denunciation_text, '</p>', # Párrafo de denuncias ahora más integrado
        '<p><strong>Recomendación:</strong> Se recomienda diseñar estrategias para aumentar la confianza de la población en las instituciones encargadas de la seguridad y la justicia, con un enfoque particular en las víctimas de delitos. Esto podría incluir campañas de cercanía, mejora en la calidad de la atención a las víctimas, y optimización de los procesos de denuncia para hacerlos más accesibles y transparentes, lo cual podría a su vez incrementar la tasa de denuncias.</p>',
        '</div>'
      )
      all_conclusions_html_parts <- c(all_conclusions_html_parts, confidence_conclusion_html)
    }
    
    # 5. Conclusión: Análisis de Agrupamiento (Clustering)
    {
      if (!is.null(resultados_acm$df_acm_clean_with_cluster) &&
          nrow(resultados_acm$df_acm_clean_with_cluster) > 0) {
        
        num_clusters <- length(unique(resultados_acm$df_acm_clean_with_cluster$Cluster))
        
        if (num_clusters > 1) {
          cluster_summary_text <- paste0(
            "El análisis de agrupamiento (clustering) ha revelado la existencia de ", num_clusters, " perfiles distintos de la población en cuanto a sus percepciones y experiencias relacionadas con la seguridad. ",
            "Cada grupo exhibe características particulares en variables clave como la percepción de aumento de la delincuencia, la exposición al delito o la confianza en las instituciones, como se detalla en la tabla de entropía y el gráfico ACM. ",
            "Por ejemplo, algunos clusters podrían estar más expuestos a ciertos tipos de delitos o sentir mayor inseguridad en lugares específicos."
          )
          clustering_conclusion_html <- paste0(
            '<div class="conclusion-box">',
            '<h4> <i class="fas fa-users fa-lg" role="presentation" aria-label="users icon"></i> <strong>Perfiles de la Población y Seguridad</strong> </h4>',
            '<p>', cluster_summary_text, '</p>',
            '<p><strong>Recomendación:</strong> Se sugiere diseñar políticas de seguridad pública segmentadas y focalizadas, adaptadas a las necesidades y características de cada perfil de ciudadano identificado. Esto permitirá una asignación más eficiente de recursos y una mayor efectividad en las intervenciones.</p>',
            '</div>'
          )
          all_conclusions_html_parts <- c(all_conclusions_html_parts, clustering_conclusion_html)
        } else {
          clustering_conclusion_html <- paste0(
            '<div class="conclusion-box">',
            '<h4> <i class="fas fa-users fa-lg" role="presentation" aria-label="users icon"></i> <strong>Análisis de Agrupamiento</strong> </h4>',
            '<p>El análisis de agrupamiento no identificó perfiles de población distintivos con los datos actuales, o todos los datos forman un único grupo predominante. Esto puede indicar una homogeneidad en las percepciones/experiencias o la necesidad de ajustar los parámetros del algoritmo de clustering.</p>',
            '</div>'
          )
          all_conclusions_html_parts <- c(all_conclusions_html_parts, clustering_conclusion_html)
        }
      } else {
        clustering_conclusion_html <- paste0(
          '<div class="conclusion-box">',
          '<h4> <i class="fas fa-users fa-lg" role="presentation" aria-label="users icon"></i> <strong>Análisis de Agrupamiento</strong> </h4>',
          '<p>El análisis de agrupamiento no ha generado resultados. Asegúrate de que los datos y el proceso de clustering estén funcionando correctamente.</p>',
          '</div>'
        )
        all_conclusions_html_parts <- c(all_conclusions_html_parts, clustering_conclusion_html)
      }
    }
    
    final_html_string <- paste(all_conclusions_html_parts, collapse = " ")
    HTML(final_html_string)
  })
    
    #--------------------------------------#
    #----------------REPORTE---------------#
    #--------------------------------------#
  {
    
    output$descargar_reporte <- downloadHandler(
      filename = function() {
        paste0("informe-seguridad-", Sys.Date(), ".pdf")
      },
      content = function(file) {
        # *** Importante: Asegurarse de que los resultados del ACM estén disponibles ***
        # Si df_acm_clean_with_cluster es NULL o no tiene suficientes filas,
        # la ejecución de 'content' se detendrá aquí.
        # (El threshold de 3 filas es porque tu Rmd lo requiere para los gráficos/tablas)
        
        # Una forma más explícita de manejarlo con feedback al usuario:
        if (is.null(resultados_acm$df_acm_clean_with_cluster) || nrow(resultados_acm$df_acm_clean_with_cluster) < 3) {
          showNotification(
            "❌ Los cálculos de agrupación (ACM y Clusters) no están listos o no hay suficientes datos. Por favor, asegúrate de haber visitado la sección 'Agrupación' y de que haya suficientes datos filtrados.",
            type = "error",
            duration = 8 # Muestra la notificación por más tiempo
          )
          # Puedes opcionalmente devolver NULL aquí para detener la descarga si es necesario.
          # Sin embargo, Shiny ya maneja que si no hay un archivo generado, no descarga nada.
          return(NULL) 
        }
        
        # Continúa solo si los datos están disponibles
        tempReport <- file.path(tempdir(), "reporte.Rmd")
        file.copy("reporte.Rmd", tempReport, overwrite = TRUE)
        
        params <- list(
          data = datos_filtrados(),
          map_data = mapa_datos_filtrados(),
          enc_region = enc_region,
          enc_rpc = enc_rpc,
          rph_sexo = rph_sexo,
          rph_edad = rph_edad,
          P_AUMENTO_ = P_AUMENTO_,
          P_INSEG_LUGARES_ = P_INSEG_LUGARES_,
          P_INCIVILIDADES_ = P_INCIVILIDADES_,
          P_EXPOS_DELITO = P_EXPOS_DELITO,
          P_DELITO_PRONOSTICO__ = P_DELITO_PRONOSTICO__,
          EV_CONFIA_ = EV_CONFIA_,
          region_seleccionada_input = input$region,
          comuna_seleccionada_input = input$comuna,
          sexo_seleccionado_input = input$sexo,
          edad_seleccionada_input = input$edad,
          # Aquí es donde pasas la "instantánea" del reactiveValue.
          # Es crucial que resultados_acm$df_acm_clean_with_cluster ya tenga datos.
          resultados_acm_param = shiny::reactiveValuesToList(resultados_acm),
          df_inc_processed_param = df_inc_processed()
        )
        
        rmarkdown::render(tempReport,
                          output_file = file,
                          params = params,
                          envir = new.env(parent = globalenv()))
      }
    )
    
    
    
  }
    
  }

  


#--------------------------------------#
#--------------APLICACIÓN--------------#
#--------------------------------------#
shinyApp(ui = ui, server = server)

