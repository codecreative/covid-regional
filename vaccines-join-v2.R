

library('dplyr')
library(tidyverse)

# read in the full vax history
vax_raw <- read.csv( url("http://ix.cnn.io/data/novel-coronavirus-2019-ncov/vaccines-world/vaccine-owid-history.csv")) 

# filter out the no records for "totalDoses"
vax <- vax_raw %>%
  filter(!is.na(totalDoses))

# get the most recent record (of totalDoses) for each country
vax_latest <- vax %>%
  group_by(code) %>%
  arrange(date) %>%
  slice(n()) %>%
  ungroup()

# read in the country -> region matchup
un_regions <- read_csv('un-mod-regions.csv') %>%
  mutate( code = data__alpha3 ) %>%
  select( c('code', 'cnnRegion'))

# join the latest records with the region info
joined <- vax_latest %>%
  left_join(un_regions) %>%
  write_csv( 'with-regions-v2.csv')

# read in the population data for regions
region_pop <- read_csv('region_pop.csv')

# add up the totals for each region and get per100 based on the region pop data
by_continent <- joined %>%
  select( c('date', 'code', 'name', 'totalDoses', 'cnnRegion') )  %>%
  group_by( cnnRegion ) %>%
  summarise(across(
    .cols = c('totalDoses'), 
    .fns = sum, 
    .names = "{col}"
  )) %>%
  ungroup() %>%
  left_join( region_pop ) %>%
  mutate( 
    totalDosesPer100 = (totalDoses/pop_est_2020) * 100,
    totalDosesPer100Rounded = round( totalDosesPer100 )
  ) %>%
  arrange( desc(totalDosesPer100Rounded) ) %>%
  write_csv( 'with-regions-calculated.csv')
