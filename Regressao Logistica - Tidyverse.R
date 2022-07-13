rm(list = ls())
library(tidymodels)
library(readr)
library(janitor)
library(stringr)
library(lubridate)
library(ggplot2)
library(plotly)
library(DataExplorer)
#library(quantmod)

#carregando Base extraida do site investing
base <- read_csv('Futuros Ibovespa - Dados Históricos.csv') %>% clean_names() %>% 
  mutate(data = lubridate::dmy(data),
         meta = if_else(var_percent > 0,1,0) %>% as.factor()) %>% 
  #select(-c(var_percent,vol)) %>%
  arrange(data)

#base do yahoo finance
#base_yahoo <- quantmod::getSymbols(Symbols = '^BVSP') %>% clean_names()

#Avaliando tipos de dados e verificando dados faltantes
DataExplorer::plot_intro(base)

#Analisando gráfico da seríe temporal
ggplotly(
ggplot(base,aes(x = data,y = ultimo))+
  geom_line()+
  geom_point(color='blue',size=1)+
  ggtitle('Gráfico Cotação diária')+
  scale_x_date(date_breaks = "1 month", date_labels = "%b %d")
)


#Dividindo entre treino e teste
split_base <- initial_split(base,prop = .8)
train_base <- training(split_base)
test_base <- testing(split_base)


# Criando modelo ----------------------------------------------------------
lr_model <- logistic_reg() %>% 
  set_mode('classification') %>% 
  set_engine('glm')


# Criando Recipe ----------------------------------------------------------
lr_recipe <- recipe(meta ~ .,data = train_base) %>% 
  step_rm(var_percent,vol) %>% prep()


# Criando Workflow --------------------------------------------------------
wkf_model <- workflow() %>% 
  add_model(lr_model) %>% 
  add_recipe(lr_recipe)


# Treinando Modelo --------------------------------------------------------
lr_result <- last_fit(wkf_model,split = split_base)


# Avaliando Resultado -----------------------------------------------------
#Accuracy and roc_auc
lr_result %>% collect_metrics()

#Matriz de Confusão
lr_result %>% unnest(.predictions) %>% conf_mat(truth = meta, estimate = .pred_class) %>% autoplot(type='heatmap')


# Salvando modelo Final ---------------------------------------------------
final_lr_result <- fit(wkf_model,base)
saveRDS(object = final_lr_result,file = 'win_model.rds')
