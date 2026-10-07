library(qcc)
library(ggplot2)


valores <- data.frame(
  n = 2:25,
  A2 = c(1.880, 1.023, 0.729, 0.577, 0.483, 0.419, 0.373, 0.337, 0.308, 0.285,
         0.266, 0.249, 0.235, 0.223, 0.212, 0.203, 0.194, 0.187, 0.180, 0.173,
         0.167, 0.162, 0.157, 0.153),
  d2 = c(1.128, 1.693, 2.059, 2.326, 2.534, 2.704, 2.847, 2.970, 3.078, 3.173,
         3.258, 3.336, 3.407, 3.472, 3.532, 3.588, 3.640, 3.689, 3.735, 3.778,
         3.819, 3.858, 3.895, 3.931),
  D3 = c(0, 0, 0, 0, 0, 0.076, 0.136, 0.184, 0.223, 0.256,
         0.284, 0.308, 0.329, 0.348, 0.364, 0.379, 0.392, 0.404, 0.414, 0.425,
         0.434, 0.443, 0.452, 0.459),
  D4 = c(3.267, 2.575, 2.282, 2.115, 2.004, 1.924, 1.864, 1.816, 1.777, 1.744,
         1.716, 1.692, 1.671, 1.652, 1.636, 1.621, 1.608, 1.596, 1.586, 1.575,
         1.566, 1.557, 1.548, 1.541)
)

Carta <- function(datos_input, carta, n){
  valores_grupo <- valores[valores$n == n, ]
  A2 <- valores_grupo[,2]
  d2 <- valores_grupo[,3]
  D3 <- valores_grupo[,4]
  D4 <- valores_grupo[,5]
  
  x_barra<- mean(datos_input)
  dif=numeric(length(datos_input)-1)
  for(i in (length(datos_input)-1)){
  dif[i]<- max(datos_input[i], datos_input[i+1])
  }
  r_barra<- mean(dif)
  
  Datos_Moviles <- function(datos, n) {
    x_barra_movil <- numeric(length(datos) - n + 1)
    r_movil <- numeric(length(datos) - n + 1)
    
    for (i in 1:(length(datos) - n + 1)) {
      subgrupo <- datos[i:(i + n - 1)]
      x_barra_movil[i] <- mean(subgrupo)
      r_movil[i] <- max(subgrupo) - min(subgrupo)
    }
    
    x_r <- data.frame(x_barra_movil, r_movil)
    return(x_r)
  }
  
  # Calcular datos móviles
  x_r <- Datos_Moviles(datos_input, n)
  x_movil <- x_r[, 1]
  r_movil <- x_r[, 2]
  
  X_barra_movil <- mean(x_movil)
  r_barra_movil <- sum(r_movil) / length(r_movil)

if (carta == "X") {
    
  LCL <- x_barra -  (A2* r_barra)
  UCL <- x_barra + (A2* r_barra)
  MEDIA <- x_barra
  
  plot(datos_input, type="b", col=5, pch=16, main="Carta X", xlab="Subgrupo", ylab="", ylim = c(LCL -1, UCL+1))
  
  # Agregar tres líneas
  abline(h=LCL, col="red", lwd=2, lty=2)  
  abline(h=UCL, col="red", lwd=2, lty=3)  
  abline(h=MEDIA, col="darkgreen", lwd=2)
    }  
if (carta == "R") {
  LCL <- D3 * r_barra
  UCL <- D4 * r_barra
  MEDIA <- r_barra
  
  plot(dif, type="b", col=5, pch=16, main="Carta R", xlab="Subgrupo", ylab="Rango", ylim = c(LCL -1, UCL+1))
  
  # Agregar tres líneas
  abline(h=LCL, col="red", lwd=2, lty=2)  
  abline(h=UCL, col="red", lwd=2, lty=3)  
  abline(h=MEDIA, col="darkgreen", lwd=2)
    }
  
  
  if(carta == "X_movil"){
    LCL <- X_barra_movil - A2*r_barra_movil
    UCL <- X_barra_movil + A2*r_barra_movil 
    MEDIA <- X_barra_movil
    
    plot(x_movil, type="b", col=5, pch=16, main="Carta X-móvil", xlab="Subgrupo", ylab="Valor", ylim = c(LCL -1, UCL+1))
    
    # Agregar tres líneas
    abline(h=LCL, col="red", lwd=2, lty=2)  
    abline(h=UCL, col="red", lwd=2, lty=3)  
    abline(h=MEDIA, col="darkgreen", lwd=2)
  }
  if(carta == "R_movil"){
    LCL <- D3 * r_barra_movil
    UCL <- D4 * r_barra_movil
    MEDIA <- r_barra_movil
    
    plot(r_movil, type="b", col=5, pch=16, main="Carta R-móvil", xlab="Subgrupo", ylab="Rango Móvil", ylim = c(LCL -1, UCL+1))
    
    # Agregar tres líneas
    abline(h=LCL, col="red", lwd=2, lty=2)  
    abline(h=UCL, col="red", lwd=2, lty=3)  
    abline(h=MEDIA, col="darkgreen", lwd=2)
  }
}

concentracion_cloro <- c(49.1336, 48.7158, 47.4405, 48.2146, 50.358, 51.1769, 
51.6364, 52.0311, 50.5666, 51.364, 49.6251, 47.2201, 
49.1065, 48.7078, 51.2428, 51.7740, 51.6988, 48.7881, 
51.7291, 50.2267, 50.2299, 50.3402, 50.2523,51.4223)
Carta(concentracion_cloro,"X", 2)
Carta(concentracion_cloro,"R", 2)
Carta(concentracion_cloro,"X_movil", 2)
Carta(concentracion_cloro,"R_movil", 2)
