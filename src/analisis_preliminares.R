library(tidyverse)
library(patchwork)
library(sf)
soft_sign_func <- function(x){ x / (1 + abs(x))  }

uso_suelo <- read_csv('./data/proc/uso_suelo_2002_2018_coefs.csv')

uso_suelo <- uso_suelo %>%
        mutate(jornales_totales = demanda * valor) 

uso_suelo_aggs <- uso_suelo %>%
                group_by(censo, link, demanda_agg) %>%
                summarise(has = sum(valor),
                          jornales = sum(jornales_totales)) %>%
                ungroup() %>%
                pivot_wider(names_from = c(censo, demanda_agg),
                            values_from = c(has, jornales)) %>%
                mutate(jornales_2002 = jornales_2002_Alta + jornales_2002_Media + jornales_2002_Baja,
                       jornales_2018 = jornales_2018_Alta + jornales_2018_Media + jornales_2018_Baja) %>%
                select(-c(jornales_2002_Alta, jornales_2002_Media, jornales_2002_Baja, 
                          jornales_2018_Alta, jornales_2018_Media, jornales_2018_Baja)) %>%
                mutate(var_Alta = `has_2018_Alta` /  `has_2002_Alta` - 1,
                        var_Media = `has_2018_Media` /  `has_2002_Media` - 1,
                        var_Baja = `has_2018_Baja` /  `has_2002_Baja` - 1,
                        var_Sin_datos =`has_2018_S/D` /  `has_2002_S/D` - 1,
                        var_Jornales = jornales_2018 / jornales_2002 -1) %>%
        ungroup()

frontera_deptos <- read_sf('/media/grosati/Elements/PEN/Datasets_ML/CONICET_estr_agr/proc_data/tablas_finales/frontera_depto.geojson')

total <- frontera_deptos %>%
        left_join(
                uso_suelo_aggs
        )




links <- total %>%
        st_set_geometry(NULL) %>%
        filter(depto_cna02 %in% c("burruyacu", "jimenez", "pellegrini") & provincia_cna02 != 'buenos aires') %>%
        select(link) %>%
        pull()

total %>%
        filter(link %in% links) %>%
        select(link, provincia_cna18, depto_cna18, jornales_2002, jornales_2018, var_Jornales)

total %>%
        ggplot() +
                geom_sf(aes(fill=soft_sign_func(var_Jornales))) +
                scale_fill_viridis_c() +
                theme_minimal()



total %>%
        st_set_geometry(NULL) %>%
        group_by(cluster2) %>%
        summarise(
                Q1_var_jornales = quantile(var_Media, probs=0.25, na.rm=TRUE),
                Q2_var_jornales = median(var_Media, na.rm=TRUE),
                Q3_var_jornales = quantile(var_Media, probs=0.75, na.rm=TRUE),
                n=n())
