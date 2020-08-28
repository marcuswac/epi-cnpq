library(dplyr)
library(here)
library(readr)

srag_url <- "https://s3-sa-east-1.amazonaws.com/ckan.saude.gov.br/SRAG/2020/INFLUD-24-08-2020.csv"
srag <- read_csv2(srag_url, col_types = cols(.default = col_character()))
write_csv2(srag, gzfile(here("data", "srag.csv.gz"), "w"))