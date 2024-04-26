library(dplyr)
library(readxl)
library(purrr)
library(forcats)

load_all()

# estados ----

estado_calificacion_pais <- country_rating_status %>%
  rename(
    anio = year, derechos_politicos = political_rights,
    libertades_civiles = civil_liberties
  )

continente <- read_excel("dev/texts/translation_es/continents.xlsx")

estado_calificacion_pais <- estado_calificacion_pais %>%
  left_join(continente)

estado_calificacion_pais %>%
  filter(is.na(continente))

pais <- read_excel("dev/texts/translation_es/countries.xlsx")

estado_calificacion_pais <- estado_calificacion_pais %>%
  left_join(pais)

estado_calificacion_pais %>%
  filter(is.na(pais))

estado <- read_excel("dev/texts/translation_es/rating_statuses.xlsx")

estado_calificacion_pais <- estado_calificacion_pais %>%
  left_join(estado)

estado_calificacion_pais %>%
  filter(is.na(estado))

estado_calificacion_pais <- estado_calificacion_pais %>%
  select(
    anio, pais, iso2c, iso3c, continente, derechos_politicos,
    libertades_civiles, estado, color
  )

estado_calificacion_pais <- estado_calificacion_pais %>%
  mutate(
    pais = as_factor(pais),
    continente = as_factor(continente),
    estado = as_factor(estado)
  )

save(estado_calificacion_pais,
  file = "translations/es/data/estado_calificacion_pais.rda",
  compress = "xz"
)

# puntajes ----

puntaje_pais <- country_score %>%
  rename(anio = year)

puntaje_pais <- puntaje_pais %>%
  left_join(continente)

puntaje_pais %>%
  filter(is.na(continent))

puntaje_pais <- puntaje_pais %>%
  left_join(pais, by = c("country_territory" = "country"))

puntaje_pais %>%
  filter(is.na(pais))

descripcion_item <- read_excel("dev/texts/translation_es/score_items.xlsx")

puntaje_pais <- puntaje_pais %>%
  left_join(descripcion_item)

puntaje_pais %>%
  filter(is.na(descripcion_categoria))

descripcion_sub_item <- read_excel("dev/texts/translation_es/score_sub_items.xlsx")

puntaje_pais <- puntaje_pais %>%
  left_join(descripcion_sub_item)

puntaje_pais %>%
  filter(is.na(descripcion_sub_categoria))

puntaje_pais <- puntaje_pais %>%
  select(anio, pais, iso2c, iso3c, continente,
    categoria = item,
    sub_categoria = sub_item, descripcion_categoria,
    descripcion_sub_categoria, puntaje = score
  )

unique(puntaje_pais$sub_categoria)

save(puntaje_pais, file = "translations/es/data/puntaje_pais.rda", compress = "xz")

# detalles ----

texto_calificacion_pais <- country_rating_text %>%
  rename(anio = year)

texto_calificacion_pais <- texto_calificacion_pais %>%
  left_join(pais)

texto_calificacion_pais %>%
  filter(is.na(pais))

texto_calificacion_pais <- texto_calificacion_pais %>%
  left_join(continente)

texto_calificacion_pais %>%
  filter(is.na(continente))

detalle <- map_df(
  list.files("dev/texts/translation_es/", full.names = TRUE, pattern = "rating_details"),
  ~ read_excel(.x)
)

texto_calificacion_pais <- texto_calificacion_pais %>%
  left_join(detalle)

texto_calificacion_pais %>%
  filter(is.na(detalle))

texto_calificacion_pais %>%
  distinct(sub_item) %>%
  pull()

calificacion_sub_items <- read_excel("dev/texts/translation_es/rating_sub_items.xlsx")

texto_calificacion_pais <- texto_calificacion_pais %>%
  left_join(calificacion_sub_items)

texto_calificacion_pais %>%
  filter(is.na(sub_item))

calificacion_sub_items %>%
  pull(sub_categoria)

# reorder sub_item levels
texto_calificacion_pais <- texto_calificacion_pais %>%
  mutate(
    sub_categoria = fct_relevel(sub_categoria, "Descripción General"),
    sub_item = fct_relevel(sub_categoria, "Desarrollos Clave", after = 1L),
    sub_item = fct_relevel(sub_categoria, "Cambio de Estado", after = 2L),
    sub_categoria = fct_relevel(sub_categoria, "Cambio de Calificación", after = 3L),
    sub_categoria = fct_relevel(sub_categoria, "Flecha de Tendencia", after = 4L),
    sub_categoria = fct_relevel(sub_categoria, "Notas", after = 5L)
  )

texto_calificacion_pais <- texto_calificacion_pais %>%
  select(anio, pais, iso2c, iso3c, continente, sub_categoria, detalle)

texto_calificacion_pais <- texto_calificacion_pais %>%
  mutate(pais = as_factor(pais))

texto_calificacion_pais %>%
  filter(is.na(detalle))

texto_calificacion_pais %>%
  filter(pais == "Chile", anio == 2022L)

save(texto_calificacion_pais, file = "translations/es/data/texto_calificacion_pais.rda", compress = "xz")
