load_all()

library(dplyr)
library(purrr)
library(openxlsx)

country_rating_status

country_score

unique(country_score$year)

country_rating_text

unique(country_rating_text$year)

country_score <- country_score %>%
  left_join(country_rating_text, by = c("year", "country", "iso2c", "iso3c",
    "continent", "item", "sub_item", "item_description",
    "sub_item_description"))

yrs <- sort(unique(country_rating_status$year))

wb <- createWorkbook()

map(
  yrs,
  function(y) {
    # y = yrs[1]
    d <- country_rating_status %>%
      filter(year == y)

    sname <- paste("country_rating_status_", y)

    addWorksheet(wb, sheetName = sname)

    writeData(wb, sheet = sname, x = d)

    TRUE
  }
)

saveWorkbook(wb, "exported-spreadsheets/country-rating-status.xlsx", overwrite = TRUE)

yrs <- sort(unique(country_score$year))

wb <- createWorkbook()

map(
  yrs,
  function(y) {
    # y = yrs[1]
    d <- country_score %>%
      filter(year == y)

    sname <- paste("country_score_", y)

    addWorksheet(wb, sheetName = sname)

    writeData(wb, sheet = sname, x = d)

    TRUE
  }
)

saveWorkbook(wb, "exported-spreadsheets/country-score.xlsx", overwrite = TRUE)

