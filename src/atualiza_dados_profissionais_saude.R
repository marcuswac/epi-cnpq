library(dplyr)
library(janitor)
library(here)
library(readr)
library(stringr)
knitr::opts_chunk$set(echo = FALSE)

atualiza_dados_profissionais_covid <- function() {
  cnes_dir <- "~/local/datasets/dados-sus/BASE_DE_DADOS_CNES"
  
  tipo_estabelecimento <- file.path(cnes_dir, "tbTipoEstabelecimento202009.csv") %>%
    read_csv2()
  
  natureza_juridica <- file.path(cnes_dir, "tbNaturezaJuridica202009.csv") %>%
    read_csv2()
  
  estabelecimento <- file.path(cnes_dir, "tbEstabelecimento202009.csv") %>%
    read_csv2(col_types = cols("CO_UNIDADE" = "c")) %>%
    left_join(tipo_estabelecimento) %>%
    left_join(natureza_juridica)
  
  dados_prof_sus <- file.path(cnes_dir, "tbDadosProfissionalSus202009.csv") %>%
    read_csv2()
  
  cbo_familia <- file.path("data", "CBO2002 - Familia.csv") %>%
    read_csv2(locale = locale(encoding = "latin1")) %>%
    rename(CO_CBO_FAMILIA = CODIGO, CBO_FAMILIA = TITULO)
  
  atividade_prof <- file.path(cnes_dir, "tbAtividadeProfissional202009.csv") %>%
    read_csv2(col_types = cols("CO_CBO" = col_character()))
  
  carga_horaria_sus <- file.path(cnes_dir, "tbCargaHorariaSus202009.csv") %>%
    read_csv2() %>%
    left_join(dados_prof_sus, by = "CO_PROFISSIONAL_SUS") %>%
    left_join(atividade_prof) %>%
    mutate(CO_CBO_FAMILIA = str_sub(CO_CBO, end = 4)) %>%
    left_join(cbo_familia, by = "CO_CBO_FAMILIA")
    
  estabelecimento_covid <- here("data/srag_covid_notificacoes_resumo.csv") %>%
    read_csv(col_types = cols("CO_CNES" = "c"))
  
  estabelecimento_profs <- estabelecimento %>%
    left_join(carga_horaria_sus, by = "CO_UNIDADE") %>%
    group_by(CO_CNES = as.character(CO_CNES),
             unidade = NO_FANTASIA,
             atividade_profissional = paste(CO_CBO_FAMILIA, CBO_FAMILIA, sep = " - "),
             natureza_juridica = paste(CO_NATUREZA_JUR, DS_NATUREZA_JUR, sep = " - "),
             tipo_estabelecimento = DS_TIPO_ESTABELECIMENTO) %>%
    summarise(qtd_profissionais_sus = sum(TP_SUS_NAO_SUS == "S"),
              qtd_profissionais_nao_sus = sum(TP_SUS_NAO_SUS == "N"),
              qtd_profissionais_total = n()) 
  
  estabelecimento_covid_profs <- estabelecimento_covid %>%
    left_join(estabelecimento_profs, by = "CO_CNES") %>%
    rename(cnes = CO_CNES)
  
  # prof_covid <- estabelecimento_covid %>%
  #   filter(!is.na(DS_ATIVIDADE_PROFISSIONAL)) %>%
  #   group_by(UF,
  #            Municipio = MUNICIPIO,
  #            Unidade = NO_FANTASIA,
  #            `Atividade profissional` = DS_ATIVIDADE_PROFISSIONAL,
  #            `Natureza juridica` = paste(CO_NATUREZA_JUR, DS_NATUREZA_JUR),
  #            #`Natureza Juridica` = case_when(
  #           #   str_starts(CO_NATUREZA_JUR, "1") ~ "Administração pública",
  #           #   str_starts(CO_NATUREZA_JUR, "2") ~ "Entidade empresarial",
  #           #   str_starts(CO_NATUREZA_JUR, "3") ~ "Entidade sem fins lucrativos",
  #           #   str_starts(CO_NATUREZA_JUR, "4") ~ "Pessoa física",
  #           #   TRUE ~ "Outros"
  #           # ),
  #            `Tipo de estabelecimento` = DS_TIPO_ESTABELECIMENTO,
  #            `Atende SUS` = TP_SUS_NAO_SUS,
  #   ) %>%
  #   summarise(`Qtd profissionais` = n(),
  #             `Notificações COVID total da unidade` = first(notificacoes)) %>%
  #   arrange(desc(`Notificações COVID total da unidade`), desc(`Qtd profissionais`))
  
  write_csv2(estabelecimento_covid_profs, here("data", "profissionais_unidades_covid.csv"))
}

atualiza_dados_profissionais_covid()
