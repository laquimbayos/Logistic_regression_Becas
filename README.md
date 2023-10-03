# Logistic_regression_Becas
Proyecto de aplicación de la regresión logística con regularización en un hipotético mecanismo de clasificación de beneficiarios a una beca con base a los resultados de la prueba Saber 11
# Modelo de Clasificación para el Programa de Becas en Colombia

## Autores
- Luis Alejandro Quimbayo Suarez
- Sergio David Bravo Talero 

## Universidad
- Universidad de los Andes
- Departamento de Ingeniería Industrial
- Maestría en Inteligencia Analítica para la Toma de Decisiones (Analytics)
- Bogotá D.C.
- 2022

## Contenido

1. [Introducción](#introducción)
2. [Marco Teórico](#marco-teórico)
3. [Metodología](#metodología)
    - [Selección de Variables](#selección-de-variables)
    - [Modelo de Clasificación](#modelo-de-clasificación)
4. [Interpretación del Modelo](#interpretación-del-modelo)
    - [Bondad de Predicción](#bondad-de-predicción)
5. [Validaciones Adicionales](#validaciones-adicionales)
6. [Conclusiones](#conclusiones)
7. [Anexos](#anexos)
8. [Bibliografía](#bibliografía)

## Introducción

Este proyecto tiene como objetivo desarrollar un modelo de clasificación para la selección de estudiantes candidatos a un nuevo programa de becas en Colombia. El modelo se basa en los resultados de la prueba SABER 11 y las condiciones socioeconómicas de los estudiantes, medido por el INSE.

## Marco Teórico

Según estudios realizados por Ángulo y Hernández en 2021, las variables socioeconómicas tienen incidencia en los resultados de la prueba SABER 11. Además, el estudio de García y Skrita en 2019 muestra que estos resultados también están relacionados con las condiciones familiares. En este contexto, el gobierno nacional propone un programa de becas que se dirige a estudiantes cuyo puntaje INSE sea menor a 80 y cuyo puntaje global obtenido sea mayor a 359.

## Metodología

El gobierno cuenta con la base de datos del ICFES de los estudiantes que se inscribieron en la prueba SABER 11. Las variables se clasifican en cuatro categorías: del estudiante, de capital humano, proxy del ingreso familiar y del colegio. Debido a la gran cantidad de variables y su correlación, se utiliza la regresión Lasso para seleccionar las variables más significativas.

### Selección de Variables

Se preseleccionan variables relevantes y se eligen las siguientes:
- ESTU_TIENEETNIA
- ESTU_INSE_INDIVIDUAL
- PUNT_GLOBAL
- ESTU_HORASSEMANATRABAJA
- ESTU_DEPTO_RESIDE
- FAMI_ESTRATOVIVIENDA
- FAMI_TIENEINTERNET
- COLE_NATURALEZA
- ESTU_NSE_ESTABLECIMIENTO

### Modelo de Clasificación

Se realiza una regresión logística con las variables seleccionadas y se elige el modelo con las variables PUNT_GLOBAL y ESTU_INSE_INDIVIDUAL como las más significativas. Se utiliza un umbral de 0.4 para la clasificación.

## Interpretación del Modelo

- Por cada unidad de incremento en PUNT_GLOBAL, los odds asociados a CANDIDATO_BECA aumentan en 0.15, manteniendo otras variables constantes.
- Por cada unidad de incremento en ESTU_INSE_INDIVIDUAL, los odds asociados a CANDIDATO_BECA disminuyen en 0.12, manteniendo otras variables constantes.

### Bondad de Predicción

Se utiliza un umbral de 0.4 para clasificar a los estudiantes candidatos a ser becados. El modelo tiene una precisión del 95% y una sensibilidad del 87.2%, lo que reduce el riesgo de rechazar a estudiantes que cumplen con las condiciones.

## Validaciones Adicionales

Se muestra una curva ROC con un AUC alto de 0.927 como parte de las validaciones adicionales.

## Conclusiones

Se ha desarrollado un modelo de clasificación efectivo para seleccionar a estudiantes candidatos al programa de becas en Colombia, basado en los resultados de la prueba SABER 11 y el puntaje INSE. El modelo es preciso y sensible, reduciendo la probabilidad de negar la beca a estudiantes que cumplen con los requisitos.

## Anexos

1. Archivos de R con la programación de los procedimientos y cálculos.
2. Base de datos de la prueba SABER 11 del año 2020.

## Bibliografía

- Angulo Cambindo, G. D., & Hernández Flórez, M. (2021). DETERMINANTES DEL RENDIMIENTO EN LAS PRUEBAS SABER – 11 EN ANTIOQUIA PARA LOS AÑOS 2017 A 2019 Y SU COMPARACIÓN CON OTRAS REGIONES CON CARACTERÍSTICAS SIMILARES.
- El Instituto Colombiano para la Evaluación de la Educación (ICFES). (2021). Resultados prueba SABER 11° 2020.
- García, J. D., & Skrita, A. (2019). Predicting Academic Performance Based On Students’ Family Environment: Evidence For Colombia Using Classification Trees. Psychology, Society, & Education, Vol 11, No 3.
