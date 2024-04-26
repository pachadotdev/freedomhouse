library(dplyr)
library(purrr)
library(writexl)

load_all()

try(dir.create("dev/texts"))

country_score %>%
  distinct(country = country_territory) %>%
  bind_rows(
    country_rating_text %>%
      distinct(country)
  ) %>%
  bind_rows(
    country_rating_status %>%
      distinct(country)
  ) %>%
  distinct() %>%
  write_xlsx("dev/texts/countries.xlsx")

country_score %>%
  distinct(continent) %>%
  bind_rows(
    country_rating_text %>%
      distinct(continent)
  ) %>%
  bind_rows(
    country_rating_status %>%
      distinct(continent)
  ) %>%
  distinct() %>%
  write_xlsx("dev/texts/continents.xlsx")

country_score %>%
  distinct(item_description) %>%
  write_xlsx("dev/texts/score_items.xlsx")

country_score %>%
  distinct(sub_item_description) %>%
  write_xlsx("dev/texts/score_sub_items.xlsx")

country_rating_text %>%
  distinct(sub_item) %>%
  write_xlsx("dev/texts/rating_sub_items.xlsx")

country_rating_status %>%
  distinct(status) %>%
  write_xlsx("dev/texts/rating_statuses.xlsx")

# country_rating_text %>%
#   distinct(detail) %>%
#   write_xlsx("dev/texts/rating_details.xlsx")

# save multiple files of 5,000 rows each
detail <- country_rating_text %>%
  distinct(detail)

detail %>%
  split(1:nrow(detail) %/% 5000) %>%
  walk2(seq_along(.), ~ write_xlsx(.x, paste0("dev/texts/rating_details_", .y, ".xlsx")))
