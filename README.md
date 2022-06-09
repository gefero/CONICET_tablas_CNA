# Datos de Censos Nacionales Agropecuarios
## Uso del suelo
### Tablas
- [CNA 2002 - con coeficientes técnicos de demanda laboral](./data/proc/uso_suelo_2002_con_coeficientes.csv)
- [CNA 2018 - con coeficientes técnicos de demanda laboral](./data/proc/uso_suelo_2018_con_coeficientes.csv)
- [Archivo apilado CNA 2002/2018 - con coeficientes técnicos de demanda laboral](./data/proc/uso_suelo_2002_2018_coefs.csv)

### Código para replicar la construcción de las tab
- [Limpieza de datos crudos 2002](./src/0_prepro_uso_suelo_2002.R)
- [Limpieza de datos crudos 2018](./src/1_prepro_uso_suelo_2018.R)
- [Agregado de coeficientes técnicos de demanda laboral](./src/2_agregado_coeficientes.R)