library(dplyr)
library(here)
library(readr)
library(stringr)
knitr::opts_chunk$set(echo = FALSE)

atualiza_dados_profissionais_covid <- function() {
  cnes_dir <- "~/local/datasets/dados-sus/BASE_DE_DADOS_CNES"
  
  srag_covid <- here("data/srag_covid_notificacoes_resumo.csv") %>%
    read_csv()
  
  prof_sus <- file.path(cnes_dir, "tbDadosProfissionalSus202009.csv") %>%
    read_csv2()
  
  estabelecimento <- file.path(cnes_dir, "tbEstabelecimento202009.csv") %>%
    read_csv2(col_types = cols("CO_UNIDADE" = col_character()))
  
  carga_horaria_sus <- file.path(cnes_dir, "tbCargaHorariaSus202009.csv") %>%
    read_csv2()
  
  dados_profissionais_sus <- file.path(cnes_dir, "tbDadosProfissionalSus202009.csv") %>%
    read_csv2()
  
  atividade_prof <- file.path(cnes_dir, "tbAtividadeProfissional202009.csv") %>%
    read_csv2(col_types = cols("CO_CBO" = col_character()))
  
  natureza_juridica <- file.path(cnes_dir, "tbNaturezaJuridica202009.csv") %>%
    read_csv2()
  
  tipo_estabelecimento <- file.path(cnes_dir, "tbTipoEstabelecimento202009.csv") %>%
    read_csv2()
  
  estabelecimento_covid <- here("data/srag_covid_notificacoes_resumo.csv") %>%
    read_csv()
  
  estabelecimento_covid <- estabelecimento_covid %>%
    left_join(estabelecimento, by = "NO_FANTASIA") %>%
    left_join(carga_horaria_sus, by = "CO_UNIDADE") %>%
    left_join(dados_profissionais_sus, by = "CO_PROFISSIONAL_SUS") %>%
    left_join(atividade_prof) %>%
    left_join(natureza_juridica) %>%
    left_join(tipo_estabelecimento)
  
  prof_covid <- estabelecimento_covid %>%
    filter(!is.na(DS_ATIVIDADE_PROFISSIONAL)) %>%
    group_by(UF,
             Municipio = MUNICIPIO,
             Unidade = NO_FANTASIA,
             `Atividade profissional` = DS_ATIVIDADE_PROFISSIONAL,
             `Natureza juridica` = DS_NATUREZA_JUR,
             #`Natureza Juridica` = case_when(
            #   str_starts(CO_NATUREZA_JUR, "1") ~ "Administração pública",
            #   str_starts(CO_NATUREZA_JUR, "2") ~ "Entidade empresarial",
            #   str_starts(CO_NATUREZA_JUR, "3") ~ "Entidade sem fins lucrativos",
            #   str_starts(CO_NATUREZA_JUR, "4") ~ "Pessoa física",
            #   TRUE ~ "Outros"
            # ),
             `Tipo de estabelecimento` = DS_TIPO_ESTABELECIMENTO,
             `Atende SUS` = TP_SUS_NAO_SUS,
    ) %>%
    summarise(`Qtd profissionais` = n(),
              `Notificações COVID total da unidade` = first(notificacoes)) %>%
    arrange(desc(`Notificações COVID total da unidade`), desc(`Qtd profissionais`))
  
  write_csv2(prof_covid, here("data", "profissionais_unidades_covid.csv"))
}

atualiza_dados_profissionais_covid()
