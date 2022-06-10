library(tidyverse)
uso2002 <- read_csv('./data/proc/uso_suelo_2002_con_coeficientes.csv')
uso2018 <- read_csv('./data/proc/uso_suelo_2018_con_coeficientes.csv')

uso2002 %>%
        group_by(provincia, demanda_agg) %>%
        summarise(has = sum(valor)) %>%
        ungroup() %>%
        group_by(provincia) %>%
        mutate(prop_sobre_provincia = has/sum(has)) %>%
        ungroup() %>%
        mutate(prop_sobre_total = has/sum(has)) %>%
        filter(demanda_agg == 'S/D') %>%
        arrange(provincia, desc(prop_sobre_provincia))  %>%
        ggplot() +
                geom_col(aes(x=reorder(provincia, prop_sobre_provincia), y=prop_sobre_provincia)) +
                coord_flip() +
                labs(title='CNA 2002',
                        x='Provincia',
                     y='% de sup. sin datos') +
                scale_y_continuous(labels=scales::percent, limits=c(0,0.1)) +
                theme_minimal() 


uso2018 %>%
        group_by(provincia, demanda_agg) %>%
        summarise(has = sum(valor)) %>%
        ungroup() %>%
        group_by(provincia) %>%
        mutate(prop_sobre_provincia = has/sum(has)) %>%
        ungroup() %>%
        mutate(prop_sobre_total = has/sum(has)) %>%
        filter(demanda_agg == 'S/D') %>%
        arrange(provincia, desc(prop_sobre_provincia))  %>%
        ggplot() +
                geom_col(aes(x=reorder(provincia, prop_sobre_provincia), y=prop_sobre_provincia)) +
                coord_flip() +
                labs(title='CNA 2018',
                        x='Provincia',
                        y='% de sup. sin datos') +
        scale_y_continuous(labels=scales::percent, limits=c(0,0.1)) +
                theme_minimal() 


sin_datos2002 <- uso2002 %>%
        group_by(provincia, grupo_cultivo, cultivo, demanda_agg) %>%
        summarise(has = sum(valor)) %>%
        ungroup() %>%
        group_by(provincia) %>%
        mutate(prop_sobre_provincia = has/sum(has)) %>%
        ungroup() %>%
        mutate(prop_sobre_total = has/sum(has)) %>%
        filter(demanda_agg == 'S/D') %>%
        arrange(provincia, desc(prop_sobre_provincia)) %>%
        group_by(provincia) %>%
        top_n(wt=prop_sobre_provincia, 30)


sin_datos2002 %>%
        gt(groupname_col = c("provincia")) %>%
        fmt_number(has, decimals=1) %>%
        fmt_percent(columns=c("prop_sobre_provincia", "prop_sobre_total"),
                    decimals = 3) %>%
        summary_rows(
                groups = TRUE,
                columns = c(has),
                fns = list(
                        total = "sum"),
        ) %>%
        summary_rows(
                groups = TRUE,
                columns = c(prop_sobre_provincia, prop_sobre_total),
                fns = list(
                        total = "sum"),
                formatter = fmt_percent,
        )

openxlsx::write.xlsx(sin_datos2002, './data/outputs/uso_sin_datos_coeficientes_2002.xlsx')

uso2018 %>%
        group_by(grupo_cultivo, cultivo, demanda_agg) %>%
        summarise(has = sum(valor)) %>%
        mutate(prop_sobre_grupo = has/sum(has)*100) %>%
        ungroup() %>%
        mutate(prop_sobre_total = has/sum(has)*100) %>%
        filter(demanda_agg=='S/D')

sin_datos2018 <- uso2018 %>%
        #filter(grupo_cultivo != 'Bosques y montes implantados') %>%
        group_by(provincia, grupo_cultivo, cultivo, demanda_agg) %>%
        summarise(has = sum(valor)) %>%
        #mutate(prop_sobre_grupo = has/sum(has)) %>%
        ungroup() %>%
        group_by(provincia) %>%
        mutate(prop_sobre_provincia = has/sum(has)) %>%
        ungroup() %>%
        mutate(prop_sobre_total = has/sum(has)) %>%
        filter(demanda_agg == 'S/D') %>%
        arrange(provincia, desc(prop_sobre_provincia)) %>%
        group_by(provincia) %>%
        top_n(wt=prop_sobre_provincia, 30)

openxlsx::write.xlsx(sin_datos2018, './data/outputs/uso_sin_datos_coeficientes_2018.xlsx')

sin_datos2018 %>%
        gt(groupname_col = c("provincia")) %>%
        fmt_number(has, decimals=1) %>%
        fmt_percent(columns=c("prop_sobre_provincia", "prop_sobre_total"),
                    decimals = 3) %>%
        summary_rows(
                groups = TRUE,
                columns = c(has),
                fns = list(
                        total = "sum"),
        ) %>%
        summary_rows(
                groups = TRUE,
                columns = c(prop_sobre_provincia, prop_sobre_total),
                fns = list(
                        total = "sum"),
                formatter = fmt_percent,
        )

