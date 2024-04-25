library(dplyr)
library(purrr)
library(writexl)

load("data/country_rating_texts.rda")

country_rating_texts_23 <- country_rating_texts %>%
  filter(year == 2023)

levels(country_rating_texts_23$country)

country_rating_texts_gsy <- country_rating_texts %>%
  filter(
    year < 2023,
    country %in% c("Gambia", "St. Vincent and Grenadines", "Yemen")
  )

unique(country_rating_texts_gsy$country)

country_rating_texts_23 <- country_rating_texts_23 %>%
  distinct(detail)

country_rating_texts_gsy <- country_rating_texts_gsy %>%
  distinct(detail)

write_xlsx(country_rating_texts_23, "dev/es/detalles/2023.xlsx")
write_xlsx(country_rating_texts_gsy, "dev/es/detalles/gsy-before-2023.xlsx")
