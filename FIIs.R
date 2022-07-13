rm(list = ls())
library(dplyr)
library(ggplot2)
library(rvest)
library(janitor)
library(readr)
library(stringr)

acoes <- 'https://fundamentus.com.br/detalhes.php'
opcoes <- 'https://opcoes.net.br/opcoes/pozinhos'
fiis <- 'https://fundamentus.com.br/fii_resultado.php'

opcoes <- read_html(opcoes) %>% html_table()
opcoes <- opcoes[[4]] %>% rename()

fiis <- read_html(fiis) %>% html_table() %>% data.frame() %>% clean_names() %>% 
  mutate(cotacao = parse_number(x = cotacao, locale = locale(decimal_mark = ',',grouping_mark = '.')),
         p_vp = parse_number(x = p_vp, locale = locale(decimal_mark = ',',grouping_mark = '.')),
         valor_de_mercado = parse_number(x = valor_de_mercado, locale = locale(decimal_mark = ',',grouping_mark = '.')),
         liquidez = parse_number(x = liquidez, locale = locale(decimal_mark = ',',grouping_mark = '.')),
         preco_do_m2 = parse_number(x = preco_do_m2, locale = locale(decimal_mark = ',',grouping_mark = '.')),
         aluguel_por_m2 = parse_number(x = aluguel_por_m2, locale = locale(decimal_mark = ',',grouping_mark = '.')),
         ffo_yield = str_replace_all(string = ffo_yield, pattern = '%',replacement = '') %>% parse_number(locale = locale(decimal_mark = ',',grouping_mark = '.')),
         dividend_yield = str_replace_all(string = dividend_yield, pattern = '%',replacement = '') %>% parse_number(locale = locale(decimal_mark = ',',grouping_mark = '.')),
         cap_rate = str_replace_all(string = cap_rate, pattern = '%',replacement = '') %>% parse_number(locale = locale(decimal_mark = ',',grouping_mark = '.')),
         vacancia_media = str_replace_all(string = vacancia_media, pattern = '%',replacement = '') %>% parse_number(locale = locale(decimal_mark = ',',grouping_mark = '.')),
         across(where(is.character), as.factor)
         )

