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
              "FAMI_TIENEINTERNET",
              "COLE_NATURALEZA", 
              "ESTU_NSE_ESTABLECIMIENTO")]

summary(data)

data <- data %>% 
  mutate(
    ESTU_TIENEETNIA = as.factor(ESTU_TIENEETNIA),
    ESTU_HORASSEMANATRABAJA = as.factor(ESTU_HORASSEMANATRABAJA),
    ESTU_DEPTO_RESIDE = as.factor(ESTU_DEPTO_RESIDE),
    FAMI_ESTRATOVIVIENDA = as.factor(FAMI_ESTRATOVIVIENDA),
    FAMI_TIENEINTERNET = as.factor(FAMI_TIENEINTERNET),
    COLE_NATURALEZA = as.factor(COLE_NATURALEZA),
    ESTU_NSE_ESTABLECIMIENTO = as.factor(ESTU_NSE_ESTABLECIMIENTO)
  )

data = na.omit(data)

# Creando nuestra variable de interes
data <- data %>%
  mutate(
    CANDIDATO_BECA = ifelse(ESTU_INSE_INDIVIDUAL <= 80 &
                              PUNT_GLOBAL > 359, 1, 0),
    ESTU_HORASSEMANATRABAJA = ifelse(ESTU_HORASSEMANATRABAJA == '0', 0, 1),
    ESTU_HORASSEMANATRABAJA = as.factor(ESTU_HORASSEMANATRABAJA)
  )
summary(data)

ames_train_x <- model.matrix(CANDIDATO_BECA ~ . - CANDIDATO_BECA, data)[, -1]
ames_train_y <- data$CANDIDATO_BECA

ames_test_x <- model.matrix(CANDIDATO_BECA ~ . - CANDIDATO_BECA, data)[, -1]
ames_test_y <- data$CANDIDATO_BECA

# LASSO ---------------------------------------
library(glmnet)
ames_lasso <- glmnet(
  x = ames_train_x,
  y = ames_train_y,
  alpha = 1
)

plot(ames_lasso, xvar = "lambda")


ames_lasso <- cv.glmnet(
  x = ames_train_x,
  y = ames_train_y,
  alpha = 1
)
# plot results
plot(ames_lasso)

min(ames_lasso$cvm)       # minimum MSE 
ames_lasso$lambda.min     # lambda for this min MSE
ames_lasso$cvm[ames_lasso$lambda == ames_lasso$lambda.1se]
ames_lasso$lambda.1se  # lambda for this MSE

ames_lasso_min <- glmnet(
  x = ames_train_x,
  y = ames_train_y,
  alpha = 1
)

plot(ames_lasso_min, xvar = "lambda")
abline(v = log(ames_lasso$lambda.min), col = "red", lty = "dashed")
abline(v = log(ames_lasso$lambda.1se), col = "red", lty = "dashed")

coef(ames_lasso, s = "lambda.1se") %>%
  broom ::tidy() %>%
  filter(row != "(Intercept)") %>%
  ggplot(aes(value, reorder(row, value), color = value > 0)) +
  geom_point(show.legend = FALSE) +
  ggtitle("Influential variables") +
  xlab("Coefficient") +
  ylab(NULL)

# minimum Ridge MSE
min(ames_ridge$cvm)
# minimum Lasso MSE
min(ames_lasso$cvm)
