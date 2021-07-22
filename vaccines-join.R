

library('dplyr')
library(tidyverse)

vax <- read.csv( url("http://ix.cnn.io/data/novel-coronavirus-2019-ncov/vaccines-world/vaccine-owid-latest.csv")) 

un_regions <- read_csv('un-mod-regions.csv') %>%
  mutate( code = data__alpha3 ) %>%
  select( c('code', 'cnnRegion'))


joined <- vax %>%
  left_join(un_regions)

grouped <- joined %>%
  filter(!is.na(totalDosesPer100)) %>%
  write_csv( 'with-regions.csv')
