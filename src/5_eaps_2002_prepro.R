library(tidyverse)

eaps2002 <- read_csv('./data/raw/eaps/2002_eaps_total.csv')

eaps2002 <- eaps2002 %>%
        janitor::clean_names() %>%
        select(-unidad_de_registro, censo:cuadro, link, 
               provincia, departamento, indicador, valor)

eaps2002 <- eaps2002 %>%
        separate(col=indicador,
                 into=c("unidad_de_registro", "indicador"),
                 sep=" \\| ")

eaps2002 <- eaps2002 %>%
        select(censo:cuadro, link, 
               provincia, departamento, unidad_de_registro, indicador, valor)

eaps2002 <- eaps2002 %>%
        filter(!indicador %in% c("EAP con límites definidos"))

eaps2002 <- eaps2002 %>%
        mutate(indicador = str_squish(indicador))

inds_2 <- eaps2002 %>%
        select(indicador) %>%
        distinct()

eaps2002 <- eaps2002 %>%
        mutate(indicador = case_when(
                indicador == 'Hasta 5' ~ '0 - 5',
                indicador == "Hasta 50" ~ '0 - 50',
                indicador == 'Hasta 500' ~ '0 - 500',
                str_detect(indicador, "a") ~ str_replace(indicador, "a", "-"), 
                TRUE ~ indicador
        ))

eaps2002 %>% filter(indicador == "500,1 - 2.500") %>% group_by(provincia) %>% summarise(n=n())

eaps2002 <- eaps2002 %>%
        mutate(escala_total = case_when(
                indicador == "0 - 50" ~ '0-50 (Chubut)',
                indicador == "0 - 500" ~ "0 - 500 (Tierra del Fuego y Santa Cruz)",
                indicador == "500,1 - 2.500" ~ "500-2500 (Tierra del Fuego y Santa Cruz)",
                indicador == "Más de 5.000" ~ "Más de 5.000 (Santiago y Chaco)",
                indicador == "Más de 2.500" ~ "Más de 2.500 (Misiones y Tucumán)",
                indicador == "Más de 1.000" ~ "Más de 1.000 (San Juan)",
                indicador == "1. 000,1 - 20.000" ~ "1. 000,1 - 20.000 (Neuquen)",
                
                indicador %in% c("50,1 - 100",
                                 "50,1 - 75",
                                 "75,1 - 100") ~ "50-100",
                indicador %in% c('100,1 - 200', 
                               "100,1 - 150",
                               "150,1 - 200") ~ "100-200",
                
                indicador %in% c("200,1 - 300",
                                 "300,1 - 500",
                                 "200,1 - 500") ~ "200-500",
                
                indicador %in% c("500,1 - 1.000") ~ "500-1000",
                indicador %in% c("1.000,1 - 1.500",
                                 "1.500,1 - 2.000",
                                 "2.000,1 - 2.500",
                                 "1.000,1 - 2.500") ~ "1000-2500",
                indicador %in% c("2.500,1 - 3.500",
                                 "3.500,1 - 5.000",
                                 "2.500,1 - 5.000") ~ "2.500-5.000",
                
                indicador %in% c("5.000,1 - 10.000",
                                 "5.000,1 - 7.500",
                                 "7500,1 - 10.000",
                                 "5.000,1 - 7.000",
                                 "7.500,1 - 10.000",
                                 "7.000,1 - 10.000") ~ "5.000-10.000",
                
                indicador %in% c("10.000,1 - 15.000",
                                 "10.000,1 - 20.000",
                                 "15.000,1 - 20.000",
                                 "20.000,1 - 30.000",
                                 "30.000,1 - 40.000",
                                 "Más de 40.000",
                                 "Más de 10.000",
                                 "Más de 20.000") ~ "10.000 y más", 
                
                indicador %in% c("0 - 5",
                                 "0 - 25",
                                 "10,1 - 15",
                                 "15,1 - 25",
                                 "5,1 - 10",
                                 "10,1 - 25") ~ "0-25",
                
                indicador == '25,1 - 50' ~ "25-50",
                indicador %in% c('200,1 - 500', 
                                 "200,1 - 300", 
                                 "300,1 - 500") ~ "200-500",
                
                indicador == '500,1 - 1.000' ~ "500-1.000",
                indicador == "EAP sin límites definidos" ~ "EAP sin límites definidos",
                indicador == "Total" ~ "Total"
                
        )
        )

write_csv(eaps2002, './data/proc/eaps_sup_2002.csv')
