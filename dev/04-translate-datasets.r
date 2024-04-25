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

# fix
# 'Gambia' -> 'The Gambia
# 'St. Vincent and Grenadines' -> 'Saint Vincent and the Grenadines'
country_rating_texts <- country_rating_texts %>%
  mutate(
    country = case_when(
      country == "Gambia" ~ "The Gambia",
      country == "St. Vincent and Grenadines" ~ "St. Vincent and the Grenadines",
      TRUE ~ country
    )
  )

# 'Saint Vincent and the Grenadines' -> 'St. Vincent and the Grenadines'
country_rating_texts <- country_rating_texts %>%
  mutate(
    country = case_when(
      country == "Saint Vincent and the Grenadines" ~ "St. Vincent and the Grenadines",
      TRUE ~ country
    )
  )

sort(unique(country_rating_texts$country))

country_rating_texts <- country_rating_texts %>%
  mutate(
    country = as_factor(country)
  )

# add continent for 'St. Vincent and the Grenadines'
country_rating_texts <- country_rating_texts %>%
  mutate(
    continent = as_factor(case_when(
      country == "St. Vincent and the Grenadines" ~ "Americas",
      TRUE ~ continent
    ))
  )

use_data(country_rating_texts, overwrite = TRUE)

# estados ----

estado_calificacion_pais <- country_rating_statuses %>%
  rename(
    anio = year, derechos_politicos = political_rights,
    libertades_civiles = civil_liberties
  )

continente <- read_excel("dev/es/estados/continent.xlsx")

estado_calificacion_pais <- estado_calificacion_pais %>%
  left_join(continente)

estado_calificacion_pais %>%
  filter(is.na(continente))

pais <- read_excel("dev/es/estados/country.xlsx")

estado_calificacion_pais <- estado_calificacion_pais %>%
  left_join(pais)

estado_calificacion_pais %>%
  filter(is.na(pais))

estado <- read_excel("dev/es/estados/status.xlsx")

estado_calificacion_pais <- estado_calificacion_pais %>%
  left_join(estado)

estado_calificacion_pais %>%
  filter(is.na(estado))

estado_calificacion_pais %>%
  filter(is.na(estado)) %>%
  select(status, estado)

estado_calificacion_pais <- estado_calificacion_pais %>%
  select(
    anio, pais, iso2c, iso3c, continente, derechos_politicos,
    libertades_civiles, estado, color
  )

save(estado_calificacion_pais,
  file = "translations/es/data/estado_calificacion_pais.rda"
)

# puntajes ----

puntaje_pais <- country_scores %>%
  rename(anio = year)

continente <- read_excel("dev/es/puntajes/continents.xlsx")

puntaje_pais <- puntaje_pais %>%
  left_join(continente)

puntaje_pais %>%
  filter(is.na(continent))

pais <- read_excel("dev/es/puntajes/countries.xlsx")

puntaje_pais <- puntaje_pais %>%
  left_join(pais, by = c("country_territory" = "country"))

puntaje_pais %>%
  filter(is.na(pais))

descripcion_item <- read_excel("dev/es/puntajes/item_description.xlsx")

puntaje_pais <- puntaje_pais %>%
  left_join(descripcion_item)

puntaje_pais %>%
  filter(is.na(descripcion_item))

descripcion_sub_item <- read_excel("dev/es/puntajes/sub_item_description.xlsx")

puntaje_pais <- puntaje_pais %>%
  left_join(descripcion_sub_item)

puntaje_pais %>%
  filter(is.na(descripcion_sub_item))

puntaje_pais <- puntaje_pais %>%
  select(anio, pais, iso2c, iso3c, continente,
    categoria = item,
    sub_categoria = sub_item, descripcion_categoria = descripcion_item,
    descripcion_sub_categoria = descripcion_sub_item, puntaje = score
  )

unique(puntaje_pais$sub_categoria)

save(puntaje_pais, file = "translations/es/data/puntaje_pais.rda")

# detalles ----

texto_calificacion_pais <- country_rating_texts %>%
  rename(anio = year)

pais <- read_excel("dev/es/puntajes/countries.xlsx")

texto_calificacion_pais <- texto_calificacion_pais %>%
  left_join(pais)

texto_calificacion_pais %>%
  filter(is.na(pais))

continente <- read_excel("dev/es/puntajes/continents.xlsx")

texto_calificacion_pais <- texto_calificacion_pais %>%
  left_join(continente)

texto_calificacion_pais %>%
  filter(is.na(continente))

detalle <- map_df(
  list.files("dev/es/detalles", full.names = TRUE),
  ~ read_excel(.x)
) %>%
  distinct(detail, .keep_all = TRUE)

texto_calificacion_pais <- texto_calificacion_pais %>%
  left_join(detalle)

texto_calificacion_pais %>%
  filter(is.na(detail))

texto_calificacion_pais %>%
  distinct(sub_item) %>%
  pull()

texto_calificacion_pais <- texto_calificacion_pais %>%
  mutate(
    sub_item = as_factor(case_when(
      sub_item == "Overview" ~ "Resumen",
      sub_item == "Key Developments" ~ "Desarrollos Clave",
      sub_item == "Rating Change" ~ "Cambio de Calificación",
      sub_item == "Status Change" ~ "Cambio de Estado",
      sub_item == "Trend Arrow" ~ "Flecha de Tendencia",
      sub_item == "Notes" ~ "Notas",
      TRUE ~ sub_item
    ))
  )

# reorder sub_item levels
# country_rating_texts <- country_rating_texts %>%
#   mutate(
#     sub_item = fct_relevel(sub_item, "Overview"),
#     sub_item = fct_relevel(sub_item, "Key Developments", after = 1L),
#     sub_item = fct_relevel(sub_item, "Rating Change", after = 2L),
#     sub_item = fct_relevel(sub_item, "Status Change", after = 3L),
#     sub_item = fct_relevel(sub_item, "Trend Arrow", after = 4L),
#     sub_item = fct_relevel(sub_item, "Notes", after = 5L)
#   )
texto_calificacion_pais <- texto_calificacion_pais %>%
  mutate(
    sub_item = fct_relevel(sub_item, "Resumen"),
    sub_item = fct_relevel(sub_item, "Desarrollos Clave", after = 1L),
    sub_item = fct_relevel(sub_item, "Cambio de Calificación", after = 2L),
    sub_item = fct_relevel(sub_item, "Cambio de Estado", after = 3L),
    sub_item = fct_relevel(sub_item, "Flecha de Tendencia", after = 4L),
    sub_item = fct_relevel(sub_item, "Notas", after = 5L)
  )

texto_calificacion_pais <- texto_calificacion_pais %>%
  select(anio, pais, iso2c, iso3c, continente,
    sub_categoria = sub_item,
    detalle
  )

save(texto_calificacion_pais, file = "translations/es/data/texto_calificacion_pais.rda")
