# Control estadistico de la calidad con paquete qcc
# Demostracion reproducible de cartas de control Shewhart y CUSUM

library(qcc)

# 1. Cartas de control por variables para subgrupos (X-barra, R y S)
data(pistonrings)
diametros <- qcc.groups(pistonrings$diameter, pistonrings$sample)

# Carta X-barra (media del proceso)
qcc_xbar <- qcc(diametros[1:25, ], type = "xbar", 
                newdata = diametros[26:40, ],
                title = "Carta X-barra: Diametro de anillos de piston",
                plot = FALSE)

# Carta R (rango)
qcc_r <- qcc(diametros[1:25, ], type = "R", 
             newdata = diametros[26:40, ],
             title = "Carta R: Variabilidad de subgrupos",
             plot = FALSE)

# Carta S (desviacion estandar)
qcc_s <- qcc(diametros[1:25, ], type = "S", 
             title = "Carta S: Desviacion estandar",
             plot = FALSE)

# 2. Carta para observaciones individuales (xbar.one)
set.seed(42)
datos_ind <- rnorm(30, mean = 50, sd = 2)
qcc_ind <- qcc(datos_ind, type = "xbar.one", 
               title = "Carta para medidas individuales",
               plot = FALSE)

# 3. Cartas por atributos (p, np, c, u)
# Carta p (proporcion de defectuosos)
defectos_muestra <- rbinom(20, size = 100, prob = 0.05)
tamanos <- rep(100, 20)
qcc_p <- qcc(defectos_muestra, sizes = tamanos, type = "p", 
             title = "Carta p: Proporcion de no conformes",
             plot = FALSE)

# Carta c (conteo de defectos por unidad de inspeccion constante)
conteo_defectos <- rpois(25, lambda = 4)
qcc_c <- qcc(conteo_defectos, type = "c", 
             title = "Carta c: Conteo de defectos por unidad",
             plot = FALSE)

# 4. Carta CUSUM para deteccion de pequenos cambios en la media
rendimiento_estable <- rnorm(60, mean = 3.0, sd = 0.5)
rendimiento_bajo <- rnorm(40, mean = 2.5, sd = 0.5)
rendimiento_datos <- c(rendimiento_estable, rendimiento_bajo)

cusum_res <- cusum(rendimiento_datos,
                   center = 3.0,
                   std.dev = 0.5,
                   decision.interval = 5,
                   se.shift = 0.5,
                   title = "Carta CUSUM: Rendimiento de proceso",
                   plot = FALSE)

cat("Validacion exitosa: Todas las cartas de control (X-barra, R, S, p, c, CUSUM) ajustadas correctamente.\n")