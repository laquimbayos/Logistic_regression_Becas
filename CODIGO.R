# Configuración de opciones generales en R
options(digits = 7, 
        scipen = 999)

# Preparando entorno de trabajo
rm(list=ls())
set.seed(123)

# Librerias y paquetes
library(tidyverse)
library(lmtest)
library(DescTools)
library(car)
library(caret)
library(plotROC)
library(MASS)
library(ROCR)
library(margins)
library(haven)
library(sandwich)
library(readr)
library(pROC)

current_working_dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(current_working_dir)

# Importar base de datos
data <- read_delim("base.txt",
                   delim = "¬", escape_double = FALSE,
                   trim_ws = TRUE)
summary(data)

# Importar datos y transformar
data = filter(data, 
              ESTU_NACIONALIDAD == 'COLOMBIA', 
              ESTU_PAIS_RESIDE == 'COLOMBIA')

# Filtrando variables
data = data[c("ESTU_TIENEETNIA",
              "ESTU_INSE_INDIVIDUAL", 
              "PUNT_GLOBAL", 
              "ESTU_HORASSEMANATRABAJA",
              "ESTU_DEPTO_RESIDE", 
              "FAMI_ESTRATOVIVIENDA", 
              "FAMI_TIENEINTERNET")]

# Transformación de variables
data <- data %>%
  mutate(
    ESTU_TIENEETNIA = as.factor(ESTU_TIENEETNIA),
    ESTU_DEPTO_RESIDE = as.factor(ESTU_DEPTO_RESIDE),
    FAMI_ESTRATOVIVIENDA = as.factor(FAMI_ESTRATOVIVIENDA),
    FAMI_TIENEINTERNET = as.factor(FAMI_TIENEINTERNET)
  )
data = na.omit(data)
summary(data)

# Crear data del problema
data <- data %>%
  mutate(
    CANDIDATO_BECA = ifelse(ESTU_INSE_INDIVIDUAL <= 80 &
                            PUNT_GLOBAL > 359, 1, 0),
    CANDIDATO_BECA = as.factor(CANDIDATO_BECA),
    ESTU_HORASSEMANATRABAJA = ifelse(ESTU_HORASSEMANATRABAJA == '0', 0, 1),
    ESTU_HORASSEMANATRABAJA = as.factor(ESTU_HORASSEMANATRABAJA)
  )
summary(data)

# Particionar data
sample <- sample(c(TRUE, FALSE), nrow(data), replace=TRUE, prob=c(0.7,0.3))
train <- data[sample, ]
test <- data[!sample, ]

## Modelo de Regresión Lineal -------------------------------------------------
data.fitFull <- glm(CANDIDATO_BECA ~ ., family = "binomial", data = train)
summary(data.fitFull)

data.fit2 <- glm(CANDIDATO_BECA ~ PUNT_GLOBAL, family = "binomial", data = train)
summary(data.fit2)

data.fit3 <- glm(CANDIDATO_BECA ~ PUNT_GLOBAL + ESTU_INSE_INDIVIDUAL, family = "binomial", data = train)
summary(data.fit3)

data.fit4 <- glm(CANDIDATO_BECA ~ PUNT_GLOBAL + ESTU_INSE_INDIVIDUAL + FAMI_ESTRATOVIVIENDA, family = "binomial", data = train)
summary(data.fit4)

# Elegimos el modelo 3 por los resultados anteriores

# Efectos marginales
margins(data.fit3)

# Matriz de confusión
test <- test %>%
  mutate(prob_hat = predict(data.fit3, test, type = "response"))

test <- test %>%
  mutate(
    y_hat_4 = as.factor(as.numeric(prob_hat >= 0.4)),
    y_hat_5 = as.factor(as.numeric(prob_hat >= 0.5)),
    y_hat_7 = as.factor(as.numeric(prob_hat >= 0.7)),
  )

confusionMatrix(data = test %>% pull(y_hat_4),
                reference = test %>% pull(CANDIDATO_BECA), 
                positive = "1")

confusionMatrix(data = test %>% pull(y_hat_5),
                reference = test %>% pull(CANDIDATO_BECA), 
                positive = "1") ## SELECCIONAMOS ESTA

confusionMatrix(data = test %>% pull(y_hat_7),
                reference = test %>% pull(CANDIDATO_BECA), 
                positive = "1")

# Curva ROC
roc_score = test %>%
  mutate(
    y_hat_4 = as.numeric(levels(y_hat_5))[y_hat_4]
  ) 

rocPlot = roc(roc_score, CANDIDATO_BECA, y_hat_4)
plot(rocPlot ,main ="ROC curve -- Logistic Regression ", print.auc = TRUE)

# Residuals
library(broom)  
library(modelr) 
model1_data <- augment(data.fit3) %>% 
  mutate(index = 1:n())

ggplot(model1_data, aes(index, .std.resid, color = CANDIDATO_BECA)) + 
  geom_point(alpha = .5) +
  geom_ref_line(h = 3)

