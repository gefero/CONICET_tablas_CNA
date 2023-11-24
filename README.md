# Datos de Censos Nacionales Agropecuarios
## Uso del suelo
### Tablas
- [CNA 2002 - con coeficientes técnicos de demanda laboral](./data/proc/uso_suelo_2002_con_coeficientes.csv)
- [CNA 2018 - con coeficientes técnicos de demanda laboral](./data/proc/uso_suelo_2018_con_coeficientes.csv)
- [Archivo apilado CNA 2002/2018 - con coeficientes técnicos de demanda laboral](./data/proc/uso_suelo_2002_2018_coefs.csv)

#### Estructura de las tablas
- `id_fila`: identificador de fila (construido de forma independiente para cada censo)
- `censo`: identifica el relevamiento censal (2002, 2018)
- `cuadro`: contiene el texto/título completo del cuadro relevado
- `indicador`: variable de la que se extrae información para generar otras
- `link`: código de 5 dígitos que identifica la provincia (dígitos 1 y 2) y el departamento (dígitos 3 a 5)
- `provincia`: etiqueta de provincia
- `departamento`: etiqueta de departamento
- `unidad_de_registro`: unidad en la que se encuentra medida la información (en el caso de esta tabla, siempre son hectáreas)
- `grupo_cultivo`: gran grupo de cultivos (cereales, oleaginosas, etc.)
- `periodo`: momento de ocupación/implantación del cultivo mencionado (primera, segunda, perenne, etc.)
- `cultivo`: etiqueta específica de cada cultivo (soja, maíz, etc.); esta variable se halla aún en _proceso de normalización_
- `valor`: la cantidad de unidades (en este caso, hectáreas) para esta fila
- `demanda`: cantidad de jornales/hectárea/año estimados
- `demanda_agg`: niveles de demanda de fuerza de trabajo construidos sobre `demanda` (bajo, medio, alto)

### Documento metodológico
- [Metodología para la estimación de la superficie sembrada según demanda de trabajo](https://docs.google.com/document/d/1oqwe1_WpLphaot4TyfBI8AqXgyOzjXN0DN6cp8Bwuls/edit?usp=sharing)

### Scripts en R para replicar la construcción de las tablas
- [Limpieza de datos crudos 2002](./src/0_uso_suelo_2002_prepro.R)
- [Limpieza de datos crudos 2018](./src/1_uso_suelo_2018_prepro.R)
- [Agregado de coeficientes técnicos de demanda laboral](./src/2_uso_suelo_agregado_coeficientes.R)

## EAPs y superficie por estrato de tamaño según departamento
- [Censo Nacional Agropecuario - 2002](./data/proc/eaps_sup_2002.csv)
- [Censo Nacional Agropecuario - 2018](./data/proc/eaps_sup_2018.csv)

- `censo`: identifica el relevamiento censal (2002, 2018)
- `cuadro`: contiene el texto/título completo del cuadro relevado
- `link`: código de 5 dígitos que identifica la provincia (dígitos 1 y 2) y el departamento (dígitos 3 a 5)
- `provincia`: etiqueta de provincia
- `departamento`: etiqueta de departamento
- `unidad_de_registro`: unidad en la que se encuentra medida la información (EAPs o hectáreas)
- `indicador`: Estrato de tamaño crudo
- `valor`: la cantidad de unidades (EAP's o hectáreas) para esta fila
- `escala_total`: escala de tamaño normalizada para todo el dataset

### Scripts en R para replicar la construcción de las tablas
- [Limpieza de datos crudos 2002](./src/5_eaps_2002_prepro.R)
- [Limpieza de datos crudos 2018](./src/4_eaps_2018_prepro.R)