library(tidyverse)
library(gt)
## Generación clasificación de cultivos 
### 2018
coef2018 <- googlesheets4::read_sheet('https://docs.google.com/spreadsheets/d/1in66AmitsKbsOhTaQtnnF6SdzRY05lLeiVOiU7fwh_0/edit#gid=1821318905',
                                  sheet = 'final_2018') %>%
        select(-cultivo) %>% 
        rename(cultivo = cultivo_arm_cna18)
uso2018 <- read_csv('./data/proc/uso_suelo_2018.csv')


uso2018 <- uso2018 %>% 
        mutate(id_fila = row_number()) %>%
        select(id_fila, everything())

has2018a<-uso2018 %>%
        group_by(grupo_cultivo) %>%
        summarise(has = sum(valor))

# listado_cultivos <- uso2018 %>%
#         select(grupo_cultivo, cultivo) %>%
#         unique() %>%
#         arrange(grupo_cultivo, cultivo) 
# 
# z <- listado_cultivos %>%
#         filter(grupo_cultivo == 'Forrajeras perennes' | 
#                        grupo_cultivo == 'Forrajeras anuales')

uso2018 <- uso2018 %>%
        left_join(coef2018)


#x<-uso2018[duplicated(uso2018$id_fila) | duplicated(uso2018$id_fila, fromLast = TRUE),]

uso2018 <- uso2018[!duplicated(uso2018$id_fila),] 

has2018b<-uso2018 %>%
        group_by(grupo_cultivo) %>%
        summarise(has = sum(valor))

has2018a == has2018b        
# uso2018 <- uso2018 %>%
#         mutate(demanda_agg = case_when(
#                 str_detect(cultivo, "Girasol") ~ 'Baja',
#                 TRUE ~ demanda_agg))

uso2018 <- uso2018 %>%
        mutate(demanda_agg = case_when(
                is.na(demanda_agg) ~ 'S/D',
                TRUE  ~ demanda_agg))

write_csv(uso2018, './data/proc/uso_suelo_2018_con_coeficientes.csv')

### 2002
coef2002 <- googlesheets4::read_sheet('https://docs.google.com/spreadsheets/d/1in66AmitsKbsOhTaQtnnF6SdzRY05lLeiVOiU7fwh_0/edit#gid=1821318905',
                                  sheet = 'final_2002') %>%         
        select(-cultivo) %>% 
        rename(cultivo = cultivo_arm_cna02_or)

coef2002 <- coef2002 %>% drop_na()

uso2002 <- read_csv('./data/proc/uso_suelo_2002.csv') 
uso2002 <- uso2002 %>%
        mutate(id_fila = row_number()) %>%
        select(id_fila, everything())

uso2002 <- uso2002 %>%
        mutate(grupo_cultivo = case_when(
                grupo_cultivo == 'Industriales' ~ 'Cultivos industriales',
                grupo_cultivo == 'Cereales para grano' ~ 'Cereales',
                grupo_cultivo == 'Bosques y Montes implantados' ~ 'Bosques y montes implantados',
                TRUE ~ grupo_cultivo
        ))

# uso2002 <- uso2002 %>%
#         mutate(cultivo = case_when(
#                 cultivo == 'Cebada | Cervecera' ~ 'Cebada cervecera',
#                 cultivo == 'Cebada | Forrajera' ~ 'Cebada forrajera',
#                 cultivo == 'Trigo | Candal' ~ 'Trigo candeal',
#                 cultivo == 'Trigo | Candeal' ~ 'Trigo candeal',
#                 cultivo == 'Trigo | Pan' ~ 'Trigo pan',
#                 cultivo == 'Alforfón (trigo sarraceno)' ~ 'Trigo',
#                 str_detect(cultivo, 'Algodón') ~ 'Algodón',
#                 str_detect(cultivo, 'Tabaco') ~ 'Tabaco',
#                 str_detect(cultivo, 'Duraznero') ~ 'Duraznero',
#                 str_detect(cultivo, 'Soja 1ra') ~ 'Soja 1ra',
#                 str_detect(cultivo, 'Soja 2da') ~ 'Soja 2da',
#                 str_detect(cultivo, 'Soja 2da') ~ 'Soja 2da',
#                 str_detect(cultivo, 'Vid') ~ 'Vid',
#                 str_detect(cultivo, 'Limonero') ~ 'Limonero',
#                 str_detect(cultivo, 'Almendro') ~ 'Almendro',
#                 str_detect(cultivo, 'Peral') ~ 'Peral',
#                 str_detect(cultivo, 'Manzano') ~ 'Manzano',
#                 str_detect(cultivo, 'Olivo') ~ 'Olivo',
#                 str_detect(cultivo, 'Mandarino') ~ 'Mandarino',
#                 str_detect(cultivo, 'Naranjo') ~ 'Naranjo',
#                 str_detect(cultivo, 'Nogal') ~ 'Nogal',
#                 str_detect(cultivo, 'Cerezo') ~ 'Cerezo',
#                 str_detect(cultivo, 'Nogal') ~ 'Nogal',
#                 str_detect(cultivo, 'Araucaria') ~ 'Araucaria',
#                 str_detect(cultivo, 'Algarrobo') ~ 'Algarrobo',
#                 str_detect(cultivo, 'Tipa') ~ 'Tipa',
#                 str_detect(cultivo, 'Otras nativas') ~ 'Otras nativas',
#                 str_detect(cultivo, 'Sorgo') ~ 'Sorgo',
#                 TRUE ~ cultivo
#         ))


#coef2002 <- coef2002 %>%
#        mutate(cultivo = str_trim(str_squish(cultivo)))

#uso2002 <- uso2002 %>%
#        mutate(cultivo = str_trim(str_squish(cultivo)))

has2002a<-uso2002 %>%
        group_by(grupo_cultivo) %>%
        summarise(n=sum(valor))

uso2002 <- uso2002 %>%
        left_join(coef2002)

uso2002 <- uso2002[!duplicated(uso2002$id_fila),] 

has2002b<-uso2002 %>%
        group_by(grupo_cultivo) %>%
        summarise(n=sum(valor))

## Cheque consistencias agregadas
has2002a == has2002b

uso2002 <- uso2002 %>%
        mutate(demanda_agg = case_when(
                is.na(demanda_agg) ~ 'S/D',
                TRUE  ~ demanda_agg))

write_csv(uso2002, './data/proc/uso_suelo_2002_con_coeficientes.csv')

uso2002018 <- uso2002 %>% bind_rows(uso2018)

write_csv(uso2002018, './data/proc/uso_suelo_2002_2018_coefs.csv')


