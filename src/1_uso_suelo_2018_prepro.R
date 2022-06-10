library(tidyverse)

uso_2002<-list.files('./data/raw/2002_uso_suelo/', '*.csv', full.names = TRUE) %>% 
        map_df(~read_csv(., col_types = cols(
                Censo = col_double(),
                Cuadro = col_character(),
                Provincia = col_character(),
                Departamento = col_character(),
                `Unidad de registro` = col_character(),
                Indicador = col_character(),
                Valor = col_double(),
                Link = col_character()
        )))

## Limpio campo Indicador

uso_2002 <- uso_2002 %>%
        mutate(Indicador = case_when(
                grepl(c('Bosques y montes'), Cuadro)  ~ paste0('Perenne | ',Indicador),
                grepl(c('Forrajeras perennes'), Cuadro)  ~ paste0('Perenne | ',Indicador),
                grepl(c('Frutales'), Cuadro)  ~ paste0('Perenne | ',Indicador),
                TRUE ~ Indicador
        ))


x <- str_split_fixed(uso_2002$Indicador, ' \\| ', n=2)
colnames(x) <- c('periodo',  'cultivo')
x <- as_tibble(x)


uso_2002 <- uso_2002 %>%
        bind_cols(x)

uso_2002 <- uso_2002 %>%
        mutate(grupo_cultivo = str_trim(str_split_fixed(uso_2002$Cuadro, "\\.", n=5)[,4]))

uso_2002 <- uso_2002 %>%
        janitor::clean_names() %>%
        select(censo, cuadro, indicador, link, provincia, departamento, unidad_de_registro, grupo_cultivo, periodo, cultivo, valor)

totales <- uso_2002 %>%
        filter(grepl(c('Total'), indicador))

uso_2002_limpio <- uso_2002 %>%
        filter(!grepl(c('Total'), indicador))


uso_2002_limpio <- uso_2002_limpio %>%
        mutate(grupo_cultivo = case_when(
                grupo_cultivo=='EAP con límites definidos' ~ 'Frutales',
                TRUE ~ grupo_cultivo
        ))


uso_2002_limpio <- uso_2002_limpio %>%
        mutate(
               periodo = case_when(
                       grupo_cultivo=='Bosques y Montes implantados' & cultivo  == '' ~ 'Perenne',
                       TRUE ~ periodo),
               
               cultivo = case_when(
                       grupo_cultivo=='Bosques y Montes implantados' & cultivo  == '' ~ periodo,
                       TRUE ~ cultivo
               )
        )

write_csv(uso_2002_limpio, './data/proc/uso_suelo_2002.csv')

uso_2002_limpio %>%
        select(grupo_cultivo, periodo, cultivo) %>%
        distinct() %>%
        write_csv('./data/outputs/listado_cultivos2002.csv')
