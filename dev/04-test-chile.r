library(dplyr)
library(writexl)

load_all()

load("translations/es/data/texto_calificacion_pais.rda")

texto_calificacion_pais %>%
  filter(pais == "Chile", anio == 2023L) %>%
  write_xlsx("dev/texto_chile.xlsx")
