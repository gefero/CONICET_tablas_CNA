library(tidyverse)
library(readxl) 

path <- './example/CNA2018_resultados_definitivos.xls'

# Extraemos nombres de hojas
tab_names <- excel_sheets(path = path)
tab_prov <- tab_names[1]
## Generamos vector de nombres de cuadros
tab_depto <- tab_names[5:27]


# Extraemos nombres de provincias
prov <- read_excel(path, sheet=tab_prov, range="B10:B33")
colnames(prov) <- "XX"

## Armonizamos nombres de provincias
prov <- prov %>%
        mutate(prov = str_replace(XX, 'del', 'de')) %>%
        mutate(prov = str_match(prov, "de\\s*(.*?)\\s*\\. ")[,2]) %>%
        pull()

prov[21] <- 'Santiago del Estero'
prov[22] <- 'Tierra del Fuego'


# Generamos lista total de hojas
list_total <- lapply(tab_depto, function(x) read_excel(path = path, sheet = x, skip=6))

# La formateamos
for (l in 1:length(list_total)){
        list_total[[l]]$eti_prov <- prov[l]
}

# La transformamos en data.frame
total <- do.call(rbind, list_total)

# Nombres de columnas
## Nombramos las columnas
colnames(total) <- c("cod_depto", "eti_depto", 
                      "eaps_definidos", "parcelas_eaps_definidos", "superificie_eaps_definidos", "ELIMINAR1",
                      "eaps_mixta", "parcelas_eaps_mixta", "superificie_eaps_mixta", "eaps_mixta_terreno_sinlim", "ELIMINAR",
                      "eaps_no_definidos", "eti_prov")

## Corregimos algunos deptos a mano
total <- total %>%
        mutate(eti_depto = case_when(
                eti_prov == 'Formosa' & cod_depto == '14' ~ 'Formosa capital',
                TRUE ~ eti_depto 
        ))

deptos <- total %>%
        filter(!(eti_depto %in% prov))

## FILTRAR LAS FILAS CON PROVINCIA

provs <- total %>%
        filter(eti_depto %in% prov)

total[total$eti_depto %in% prov,]

colnames(provs) <- c("cod_prov", "eti_prov", 
                      "eaps_definidos", "parcelas_eaps_definidos", "superificie_eaps_definidos", "ELIMINAR1",
                      "eaps_mixta", "parcelas_eaps_mixta", "superificie_eaps_mixta", "eaps_mixta_terreno_sinlim", "ELIMINAR",
                      "eaps_no_definidos", "ELIMINAR3")

deptos <-deptos %>%
        select(-ELIMINAR1, -ELIMINAR)

provs <-provs %>%
        select(-ELIMINAR1, -ELIMINAR, -ELIMINAR3)

deptos <- deptos[!grepl('Fuente', x=deptos$cod_depto, fixed=TRUE),]%>%
        filter(!is.na(cod_depto))


## LLevamos cod_depto a tres caratcteres (para poder generar la columna link)
deptos <- deptos %>%
        mutate(cod_depto = case_when(
                nchar(cod_depto) == 1 ~ paste0('00',cod_depto),
                nchar(cod_depto) == 2 ~ paste0('0',cod_depto),
                TRUE ~ cod_depto
        ))

## Unificamos
deptos <- deptos %>%
        left_join(provs %>% select(cod_prov, eti_prov)) %>%
        mutate(link = paste0(cod_prov, cod_depto)) %>%
        select(link, cod_prov, cod_depto, eti_prov, eti_depto, everything()) %>%
        mutate(across(6:13, str_replace, pattern='-', replacement='0')) %>%
        mutate(across(6:13, as.numeric))

write_csv(deptos, './proc_data/CNA2018_eaps_depto.csv')