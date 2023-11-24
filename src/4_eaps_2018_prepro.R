library(tidyverse)

eaps2018 <- read_csv('./data/raw/eaps/2018_eaps_segun_tamano.csv')

eaps2018 <- eaps2018 %>%
        janitor::clean_names() %>%
        select(-x1, censo:cuadro, link, 
               provincia, departamento, indicador, unidad_de_registro, valor)


eaps2018 <- eaps2018 %>%
        mutate(indicador = case_when(
                indicador == 'Hasta 5' ~ '0 - 5',
                indicador == 'Hasta 500' ~ '0 - 500',
                indicador == 'Hasta 25' ~ '0 - 25',
                indicador == '5,1  10' ~ '5,1 - 10',
                indicador == '10,1  25' ~ '10,1 - 25',
                indicador == '25,1  50' ~ '25,1 - 50',
                indicador == '50,1  100' ~ '50,1 - 100',
                indicador == '1.000,1  1.500' ~ '1.000,1 - 1.500',
                indicador == '100,1  200' ~ '100,1 - 200',
                indicador == '200,1  500' ~ '200,1 - 500',
                indicador == '500,1  1.000' ~ '500,1 - 1.000',
                indicador == '1.000,1  1.500' ~ '1.000,1 - 1.500',
                indicador == '1.500,1  2.000' ~ '1.500,1 - 2.000',
                indicador == '2.000,1  2.500' ~ '2.000,1 - 2.500',
                indicador == '2.500,1  5.000' ~ '2.500,1 - 5.000',
                indicador == '5.000,1  10.000' ~ '5.000,1 - 10.000',
                indicador == '10.000,1  y más' ~ '10.000,1 y más',
                indicador == '1000,1  2.500' ~ '1.000,1 - 2.500', 
                indicador == '10.000,1  20.000' ~ '10.000,1 - 20.000',
                TRUE ~ indicador
                ))

eaps2018<-eaps2018 %>%
        mutate(indicador = stringr::str_squish(indicador))

eaps2018 <- eaps2018 %>%
        mutate(escala_total = case_when(
                indicador %in% c("0 - 5",
                                 "0 - 25",
                                 "5,1 - 10",
                                 "10,1 - 25") ~ "0-25",
                indicador == '25,1 - 50' ~ "25-50",
                indicador == '50,1 - 100' ~ "50-100",
                indicador == '100,1 - 200' ~ "100-200",
                indicador == '200,1 - 500' ~ "200-500",
                indicador == '500,1 - 1.000' ~ "500-1.000",
                indicador %in% c("1.000,1 - 1.500",
                               "1.500,1 - 2.000",
                               "2.000,1 - 2.500",
                               "1.000,1 - 2.500") ~ "1.000-2.500",
                indicador == "2.500,1 - 5.000" ~ "2.500-5.000",
                indicador %in% c("5.000,1 - 10.000",
                                 "5.000,1 - 7.500")~ "5.000-10.000",
                indicador %in% c("10.000,1 y más",
                               "10.000,1 - 20.000",
                               "7.500,1 - 10.000",
                               "20.000,1 y más") ~ "10.000 y más", 
                indicador == "2.500,1 y más" ~ "2.500,1 y más (Tucumán)",
                indicador == "1.000,1 y mas" ~ "1.000,1 y más (San Juan)",
                indicador == "Total" ~ "Total"
        )
               )

write_csv(eaps2018, './data/proc/eaps_sup_2018.csv')
