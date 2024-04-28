library(dplyr)
library(tidyr)
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

estado <- read_excel("dev/texts/translation_es/statuses.xlsx")

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
  left_join(pais, by = "country")

puntaje_pais %>%
  filter(is.na(pais))

descripcion_item <- read_excel("dev/texts/translation_es/items_description.xlsx")

puntaje_pais <- puntaje_pais %>%
  left_join(descripcion_item)

puntaje_pais %>%
  filter(is.na(descripcion_categoria))

sub_item <- read_excel("dev/texts/translation_es/sub_items.xlsx")
descripcion_sub_item <- read_excel("dev/texts/translation_es/sub_items_description.xlsx")

puntaje_pais <- puntaje_pais %>%
  left_join(sub_item) %>%
  left_join(descripcion_sub_item)

puntaje_pais %>%
  filter(is.na(sub_categoria))

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
  list.files("dev/texts/translation_es/", full.names = TRUE, pattern = "details_"),
  ~ read_excel(.x)
)

texto_calificacion_pais <- texto_calificacion_pais %>%
  left_join(detalle)

texto_calificacion_pais %>%
  filter(is.na(detalle))

texto_calificacion_pais %>%
  distinct(sub_item) %>%
  pull()

texto_calificacion_pais <- texto_calificacion_pais %>%
  left_join(sub_item)

texto_calificacion_pais %>%
  filter(is.na(sub_item))

sub_item %>%
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
  left_join(
    country_rating_text %>%
      distinct(item, item_description) %>%
      drop_na()
  ) %>%
  left_join(descripcion_item) %>%
  left_join(descripcion_sub_item)

# this is ok
texto_calificacion_pais %>%
  filter(is.na(descripcion_categoria)) %>%
  distinct(item_description, descripcion_categoria)

# also this
texto_calificacion_pais %>%
  filter(is.na(descripcion_sub_categoria)) %>%
  distinct(sub_item, descripcion_sub_categoria)

texto_calificacion_pais <- texto_calificacion_pais %>%
  select(
    anio, pais, iso2c, iso3c, continente,
    categoria = item, sub_categoria,
    descripcion_categoria, descripcion_sub_categoria, detalle
  )

texto_calificacion_pais <- texto_calificacion_pais %>%
  mutate(pais = as_factor(pais))

texto_calificacion_pais %>%
  filter(is.na(detalle))

texto_calificacion_pais %>%
  filter(pais == "Chile", anio == 2022L)

descripcion_categoria_order <- texto_calificacion_pais %>%
  distinct(categoria, descripcion_categoria) %>%
  drop_na() %>%
  pull(descripcion_categoria)

descripcion_sub_categoria_order <- texto_calificacion_pais %>%
  distinct(sub_categoria, descripcion_sub_categoria) %>%
  drop_na() %>%
  pull(descripcion_sub_categoria)

detalle_order <- texto_calificacion_pais %>%
  distinct(sub_categoria, detalle) %>%
  drop_na() %>%
  pull(detalle)

texto_calificacion_pais <- texto_calificacion_pais %>%
  mutate(
    descripcion_categoria = factor(descripcion_categoria, levels = descripcion_categoria_order),
    descripcion_sub_categoria = factor(descripcion_sub_categoria, levels = descripcion_sub_categoria_order),
    detalle = factor(detalle, levels = detalle_order)
  )

save(texto_calificacion_pais, file = "translations/es/data/texto_calificacion_pais.rda", compress = "xz")
