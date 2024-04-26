library(dplyr)
library(readxl)
library(purrr)
library(forcats)

load_all()

# fix 'Is there freedom for nongovernmental organizations, particularly those that are engaged in human rights and governance-related work?'

country_scores <- country_scores %>%
  mutate(
    sub_item_description = case_when(
      sub_item_description == "Is there freedom for nongovernmental organizations, particularly those that are engaged in human rights and governance-related work?" ~ "Is there freedom for nongovernmental organizations, particularly those that are engaged in human rights and governance related work?",
      TRUE ~ sub_item_description
    )
  )

# fix
# 'Pakistani Kashmir' -> 'Pakistan Kashmir'
# 'Transnitria' -> 'Transnistria'
country_scores <- country_scores %>%
  mutate(
    country_territory = case_when(
      country_territory == "Pakistani Kashmir" ~ "Pakistan Kashmir",
      country_territory == "Transnitria" ~ "Transnistria",
      TRUE ~ country_territory
    )
  )

use_data(country_scores, overwrite = TRUE)
