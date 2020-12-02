library(dplyr)
library(here)
library(readr)

srag <- read_csv2(here("data", "srag.csv.gz"))

srag_covid <- srag %>%
  filter(CLASSI_FIN == 5) %>%
  count(UF = SG_UF_NOT,
        MUNICIPIO = ID_MUNICIP,
        NO_FANTASIA = ID_UNIDADE,
        CO_CNES = as.character(CO_UNI_NOT),
        sort = TRUE,
        name = "notificacoes")

write_csv(srag_covid, here("data/srag_covid_notificacoes_resumo.csv"))
