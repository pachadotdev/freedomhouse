library(dplyr)
library(writexl)

load_all()

load("translations/es/data/texto_calificacion_pais.rda")

texto_calificacion_pais %>%
  filter(pais == "Chile", anio == 2022L) %>%
  write_xlsx("dev/texto_chile.xlsx")

texto_calificacion_pais %>%
  filter(pais == "Chile", anio == 2022L) %>%
  pull(detalle) %>%
  writeLines("dev/texto_chile.txt", sep = "\n\n")

country_rating_text %>%
  filter(country == "Chile", year == 2022L) %>%
  pull(detail) %>%
  writeLines("dev/text_chile.txt", sep = "\n\n")
