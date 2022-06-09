library(tidyverse)

uso_2018 <- read_csv('./data/raw/2018_uso_suelo_total.csv')
bosques_2018 <- read_csv('./data/raw/2018_bosques_sup.csv') %>%
        select(-`...1`)

bosques_2018 <- bosques_2018 %>%
        select(Censo, Cuadro, Provincia, Departamento, Link, `Unidad de registro`, Indicador, Valor)

uso_2018 <- uso_2018 %>%
        bind_rows(bosques_2018)

uso_2018 <- uso_2018 %>%
        filter(`Unidad de registro` == 'Hectáreas')

## Limpio campo Indicador
x <- str_split_fixed(uso_2018$Indicador, ' \\| ', n=3) 
colnames(x) <- c('periodo', 'periodo_ocupacion', 'cultivo')
x <- as_tibble(x)

x<-x %>%
        mutate(cultivo = case_when(
                cultivo=='' & periodo_ocupacion=='' & periodo!='' ~ periodo,
                cultivo=='' & periodo_ocupacion!='' & periodo=='Total' ~ periodo_ocupacion,
                cultivo=='' & periodo_ocupacion!='' & periodo=='Primera población' ~ periodo_ocupacion,
                cultivo=='' & periodo_ocupacion!='' & periodo=='Segunda población' ~ periodo_ocupacion,
                
                TRUE ~ cultivo)
        ) 

uso_2018 <- uso_2018 %>%
        bind_cols(x)

## Limpio campo Cuadro

uso_2018 <- uso_2018 %>%
        mutate(grupo_cultivo = str_extract(Cuadro, '[^.]+')) 

## Ordeno variables

uso_2018 <- uso_2018 %>%
        janitor::clean_names() %>%
        select(censo, cuadro, indicador, link, provincia, departamento, unidad_de_registro, grupo_cultivo, periodo_ocupacion, cultivo, valor)


## Eliminar lo que contiene totales...

totales <- uso_2018 %>%
        filter(grepl(c('Total'), indicador))

uso_2018_limpio <- uso_2018 %>%
        filter(!grepl(c('Total'), indicador))

cultivos_clasificar <- uso_2018_limpio %>%
        mutate(valor = if_else(valor == -1, 0, valor)) %>%
        group_by(provincia, grupo_cultivo, cultivo) %>%
        summarise(valor = sum(valor)) %>%
        group_by(provincia) %>%
        top_n(10) %>%
        ungroup() %>%
        select(grupo_cultivo, cultivo) %>%
        unique()


xxx<-uso_2018_limpio %>%
        mutate(valor = if_else(valor == -1, 0, valor)) %>%
        group_by(provincia, cultivo) %>%
        summarise(valor = sum(valor))


xxxx<-xxx %>%
        filter(cultivo == 'Soja')


uso_2018_limpio %>%
        mutate(valor = if_else(valor == -1, 0, valor)) %>%
        select(grupo_cultivo, cultivo, valor) %>%
        group_by(grupo_cultivo, cultivo) %>%
        summarise(has = sum(valor)) %>%
        group_by(grupo_cultivo) %>%
        mutate(prop = has/sum(has)) %>%
        arrange(grupo_cultivo, desc(prop)) %>%
        ungroup() %>%
        write_csv('./data/outputs/listado_cultivos.csv')

write_csv(uso_2018_limpio, './data/proc/uso_suelo_2018.csv')
