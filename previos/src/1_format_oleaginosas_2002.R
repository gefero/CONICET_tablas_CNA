library(tidyverse)
library(readxl) 
source('../CONICET_estr_agr/code/utility_functions.R', encoding = 'UTF8')

path <- '../CONICET_tablas_CNA/tablas_cna_2002/uso_suelo/'
file.list <- list.files(path, pattern='*_S.xls', full.names = TRUE)

format_tables <- function(df, nn = n){
        
        
        if ('Partido' %in% names(df)){
                df <- df %>% rename(Departamento=Partido)
        }
        if (!('Sin discriminar' %in% names(df))){
                df <- df %>% add_column(`Sin discriminar`='0')
        }
        if (!('Período de ocupación' %in% names(df))){
                df <- df %>% rename(`Período de ocupación`=`...2`)
        }        
        
        df <- df %>%
                fill(Departamento, .direction = "down") %>%
                filter(!is.na(Departamento)) %>%
                filter(!str_detect(`Departamento`, 'Nota')) %>%
                filter(!str_detect(`Departamento`, 'Fuente'))
        
        df <- janitor::clean_names(df)
        
        #df <- df %>% mutate(across((total:sin_discriminar)),
        #                     ~case_when(
        #                             . == '-' ~ '0',
        #                             TRUE ~ .,
        #                             ))
        #
        return(df)
        
}


list_total <- list()

for (f in file.list){
        n <- str_match(f, '//\\b([0-9]*)')[2]
        
        table <- read_excel(f, skip=2)
        table <- format_tables(df=table)
        
        table <- table %>% add_column(cod_provincia=n)
        table <- table %>% select(cod_provincia, everything())
        
        print(table)
        
        table <- table %>%
                        mutate(across(total:sin_discriminar, as.character)) %>%
                        pivot_longer(total:sin_discriminar) %>%
                        mutate(value=str_replace(value, '-', '0'),
                               value=as.numeric(value)) %>%
                        drop_na()
                
        
        list_total[[n]] <- table
        
}

tabla_final <- do.call(rbind, list_total)

tabla_final <- tabla_final %>%
                mutate(value=str_replace(value, '-', '0'),
                value=as.numeric(value)) 



tabla_final <- tabla_final %>% rename(cultivo=name,
                          has=value)

tabla_final_depto <- tabla_final %>% filter(periodo_de_ocupacion!='Total') %>%
        filter(departamento!='Total') %>%
        filter(cultivo!='total')

tabla_final_depto <- tabla_final_depto %>%
        mutate(departamento = case_when(
                cod_provincia == '06' & departamento == "General Lamadrid" ~ "General La Madrid",
                cod_provincia == '82' & departamento == "Nueve de Julio" ~ "9 De Julio",
                cod_provincia == '22' & departamento == '1° De Mayo' ~ '1 De Mayo',
                TRUE ~ departamento
        ))


tabla_final_depto$departamento <- stringi::stri_trans_general(tabla_final_depto$departamento, "Latin-ASCII")
tabla_final_depto$departamento<-sapply(tabla_final_depto$departamento, trimws)
tabla_final_depto$departamento<-str_replace(gsub("\\s+", " ", str_trim(tabla_final_depto$departamento)), "B", "b")
tabla_final_depto$departamento<-sapply(tabla_final_depto$departamento, cap_str)

library(sf)
deptos <- read_sf('../CONICET_estr_agr/proc_data/CNA_CNPyV_estr_agrarias.geojson') %>%
        filter(!provincia %in% c('Tierra Del Fuego', "Chubut", "Santa Cruz", "Rio Negro", "Neuquen"))




depto_keys <- deptos %>%
        st_set_geometry(NULL) %>%
        rename(cod_provincia=codpcia) %>%
        mutate(cod_departamento = str_sub(link, 3,5)) %>%
        select(link, cod_provincia, provincia, departamento, cod_departamento)

tabla_final_depto <- tabla_final_depto %>%
        left_join(depto_keys)


tabla_final_depto <- tabla_final_depto %>%
        select(link, provincia, cod_provincia, cod_departamento, departamento, everything())

write_csv(tabla_final_depto, '../CONICET_estr_agr/proc_data/CNA02_Oleaginosas.csv')






# 
# total_sup_provincia <- tabla_final %>% 
#         filter(periodo_de_ocupacion=='Total' & departamento=='Total' & name=='total')
# 
# tabla_final_depto %>%
#         group_by(provincia, periodo_de_ocupacion) %>%
#         summarise(has=sum(value))
#               