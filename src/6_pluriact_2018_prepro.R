library(tidyverse)
library(readxl)

col_n <- c("link", "depto", "unidad", "total", "agro_asal_todo", 
               "agro_asal_parte", "agro_tcp", "agro_patron", "vacia",
               "no_agro_asal_todo", "no_agro_asal_parte", "no_agro_tcp", 
               "no_agro_patron", "vacia_2", "sd"
)


format_df <- function(sh, cnames=col_n){
        x <- read_xlsx('./data/raw/CNA18_C_7_11.xlsx', sheet=sh,
                       skip=7, col_names = cnames) %>%
                select(-starts_with("vacia")) %>%
                mutate(link = as.character(link)) %>%
                filter(!grepl('Fuente|El total ', link)) %>%
                filter(if_any(everything(), ~ !is.na(.))) %>%
                fill(link, depto, .direction = "downup") 
        
        if (nchar(x$link[1]) == 1){
                prov_cod <- paste0("0", x$link[1])
                
        } else {
                prov_cod <- x$link[1]
                
        }
        prov_label <- x$depto[1]
        x <- x %>%
                mutate(link = case_when(
                        nchar(link) == 1 ~ paste0(prov_cod, "00", link),
                        nchar(link) == 2 ~ paste0(prov_cod, "0", link),
                        TRUE ~ paste0(prov_cod, link))
                ) %>%
                mutate(across(total:sd, as.numeric)) %>%
                mutate(across(total:sd, ~replace_na(.x, 0))) %>%
                filter(depto != prov_label)
        
}

pluriact <- map_dfr(.x=paste0("7.11.", 1:23), .f=format_df)

write_csv(pluriact, './data/proc/pluriact_2018.csv')
