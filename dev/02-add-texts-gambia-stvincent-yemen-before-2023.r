library(dplyr)
library(tidyr)
library(stringr)
library(forcats)
library(rvest)
library(purrr)

# for each x=country since y=2018, go to https://freedomhouse.org/country/x/freedom-world/y

baseurl <- "https://freedomhouse.org/country/x/freedom-world/y/"

countries <- c("gambia", "st-vincent-and-grenadines", "yemen")

# now read the table from https://freedomhouse.org/countries/freedom-world/scores
remote_tbl <- read_html("https://freedomhouse.org/countries/freedom-world/scores") %>%
  html_table(fill = TRUE) %>%
  as.data.frame() %>%
  as_tibble()

colnames(remote_tbl) <- c("country", "total_score", "political_rights", "civil_liberties")

remote_tbl <- remote_tbl %>%
  mutate(
    country = str_to_lower(country),
    country = str_replace_all(country, " ", "-"),
    country = str_replace_all(country, "\\*", ""),
    country = str_replace_all(country, "\\.", ""),
    country = str_replace_all(country, "'", ""),
    country = iconv(country, "", "ASCII//TRANSLIT", sub = "")
  )

unique(remote_tbl$country)

country_text <- list()

for (i in seq_along(countries)) {
  country <- countries[i]
  for (year in 2018:2023) {
    url <- str_replace_all(baseurl, "/x", paste0("/", country))
    url <- str_replace_all(url, "/y/", paste0("/", as.character(year), "/"))
    print(url)
    text <- try(read_html(url))

    # if error, go to next
    if (inherits(text, "try-error")) {
      next
    }

    # get the text from the div field field--name-field-dataset field--type-entity-reference field--label-hidden field__item
    country_text[[paste0(country, "_", year)]] <- text %>%
      html_nodes(".field--name-field-dataset.field--type-entity-reference.field--label-hidden.field__item") %>%
      html_text()
  }
}

country_scores_gsy_items <- readRDS("dev/country_scores_23_items.rds")

country_text <- country_text %>%
  map(~ str_replace_all(.x, "\n", "")) %>% # remove all \n
  map(~ str_replace_all(.x, "\\s+", " ")) %>% # remove multiple spaces
  map(~ str_replace_all(.x, "header[0-9]", "")) %>% # remove "headerX"
  map(~ str_replace_all(.x, "Overview", "BEGIN OVERVIEW")) %>% # add "BEGIN OVERVIEW"
  map(~ str_replace_all(.x, "Key Developments", "END OVERVIEW BEGIN KEY DEVELOPMENTS")) %>% # add "BEGIN OVERVIEW"
  # from here I use the item description to tag each insight
  map(~ str_replace_all(
    .x,
    country_scores_gsy_items %>%
      filter(sub_item == "A1") %>%
      pull(sub_item_description),
    "BEGIN A1"
  ))

# add END %s BEGIN %s

sub_items <- country_scores_gsy_items %>%
  distinct(sub_item) %>%
  pull(sub_item)

for (x in seq_along(country_text)) {
  for (y in seq_along(sub_items)) {
    print(paste(x, y))
    if (y <= 24) {
      z <- sprintf("END %s BEGIN %s", sub_items[y], sub_items[y + 1])

      country_text[[x]] <- str_replace_all(
        country_text[[x]],
        country_scores_gsy_items %>%
          filter(sub_item == sub_items[y + 1]) %>%
          pull(sub_item_description),
        z
      )
    } else {
      z <- sprintf("END %s", sub_items[y])
      country_text[[x]] <- str_replace_all(
        country_text[[x]],
        country_scores_gsy_items %>%
          filter(sub_item == sub_items[y]) %>%
          pull(sub_item_description),
        z
      )
    }
  }
}

# can the above be done in a single map?
# at least it works

# add END G4 at the end of each text
for (x in seq_along(country_text)) {
  print(x)
  country_text[[x]] <- paste0(country_text[[x]], " END G4")
}

country_scores_gsy_items %>%
  filter(sub_item == "G4") %>%
  pull(sub_item_description)

# "Is there equality of opportunity and the absence of economic exploitation?"
# appears as
# "Do individuals enjoy equality of opportunity and freedom from economic exploitation?"
# in some cases

country_text <- country_text %>%
  map(~ str_replace_all(
    .x,
    "Do individuals enjoy equality of opportunity and freedom from economic exploitation?",
    "END G3 BEGIN G4"
  ))

country_rating_texts_gsy <- map_df(
  seq_along(country_text),
  function(x) {
    # print(x)
    untidy_text <- country_text[[x]] %>%
      str_split("BEGIN ") %>%
      unlist() %>%
      # remove x.xx-y.yy (i.e., 1.001 4.004 Afghanistan’s president is directly...)
      str_remove("[0-9]\\.[0-9]{3} [0-9]\\.[0-9]{3}") %>%
      # remove 1.00-4.00 pts0-4 pts and END
      str_remove("1.00-4.00 pts0-4 pts") %>%
      str_remove(" END") %>%
      # replace KEY DEVELOPMENTS in XXXX
      str_replace_all("KEY DEVELOPMENTS in [0-9]{4}", "KEY_DEVELOPMENTS")

    # use all before the first space as element name
    untidy_text <- untidy_text %>%
      str_split(" ", n = 2) %>%
      map(~ set_names(.[2], .[1])) %>%
      reduce(c)

    untidy_text <- tibble(
      country_year = names(country_text[x]),
      sub_item = names(untidy_text),
      detail = untidy_text
    )

    untidy_text <- untidy_text %>%
      mutate(
        # remove AX, BX, ..., GX
        detail = str_remove_all(detail, "[A-G][0-9]"),
        # remove multiple spaces
        detail = str_replace_all(detail, "\\s+", " "),
        detail = str_trim(detail)
      )

    return(untidy_text)
  }
)

# more tidying
country_rating_texts_gsy <- country_rating_texts_gsy %>%
  separate(country_year, c("country", "year"), sep = "_") %>%
  mutate(
    year = as.integer(year),
    sub_item = str_remove(sub_item, "\\?")
  ) %>%
  mutate(
    country = str_to_title(str_replace_all(country, "-", " ")),
    sub_item = case_when(
      grepl("Ratings Change", detail) ~ "Ratings Change",
      TRUE ~ str_to_title(str_replace(sub_item, "_", " "))
    )
  )

unique(country_rating_texts_gsy$country)
unique(country_rating_texts_gsy$year)

country_rating_statuses_23 <- readRDS("dev/country_rating_statuses_23.rds")

country_rating_texts_gsy <- country_rating_texts_gsy %>%
  mutate(
    country = str_replace(country, " And ", " and "),
    country = str_replace(country, "St ", "St\\. "),
    country = str_replace(country, "Guinea Bissau", "Guinea-Bissau"),
    country = str_replace(country, "Timor Leste", "Timor-Leste")
  ) %>%
  left_join(
    country_rating_statuses_23 %>%
      select(country, iso3c, iso2c, continent) %>%
      distinct(),
    by = "country"
  ) %>%
  select(year, country, iso3c, iso2c, continent, sub_item, detail)

# remove starting "Ratings Change " from detail
country_rating_texts_gsy <- country_rating_texts_gsy %>%
  mutate(
    detail = str_remove(detail, "^Ratings Change ")
  )

# fix ' and "
country_rating_texts_gsy <- country_rating_texts_gsy %>%
  mutate(
    detail = str_replace_all(detail, "’", "'"),
    detail = str_replace_all(detail, "“", "\""),
    detail = str_replace_all(detail, "”", "\"")
  )

# convert country to fct
country_rating_texts_gsy <- country_rating_texts_gsy %>%
  mutate(country = as.factor(country))

# substract 1 year
country_rating_texts_gsy <- country_rating_texts_gsy %>%
  mutate(year = year - 1L)

# put iso2c before iso3c, oops
country_rating_texts_gsy <- country_rating_texts_gsy %>%
  select(year, country, iso2c, iso3c, continent, sub_item, detail)

# country_rating_texts_gsy_2 <- country_rating_texts_gsy %>%
#   mutate(detail_end = str_sub(detail, -20))

# country_rating_texts_gsy_2 <- country_rating_texts_gsy_2 %>%
#   distinct(detail_end)

# readr::write_csv(country_rating_texts_gsy_2, "dev/country_rating_texts_gsy.csv")

# remove "A Electoral Process",
# "B Political Pluralism and Participation"
# "C Functioning of Government"
# "D Freedom of Expression and Belief"
# "E Associational and Organizational Rights"
# "F Rule of Law"
# "G Personal Autonomy and Individual Rights"
# "OVERVIEW"
# "CL Civil Liberties"
# "PR Political Rights"
# "1.00-4.00 pts0-4 pts" from detail
country_rating_texts_gsy <- country_rating_texts_gsy %>%
  mutate(
    detail = str_remove_all(detail, "A Electoral Process"),
    detail = str_remove_all(detail, "B Political Pluralism and Participation"),
    detail = str_remove_all(detail, "C Functioning of Government"),
    detail = str_remove_all(detail, "D Freedom of Expression and Belief"),
    detail = str_remove_all(detail, "E Associational and Organizational Rights"),
    detail = str_remove_all(detail, "F Rule of Law"),
    detail = str_remove_all(detail, "G Personal Autonomy and Individual Rights"),
    detail = str_remove_all(detail, "OVERVIEW"),
    detail = str_remove_all(detail, "CL Civil Liberties"),
    detail = str_remove_all(detail, "PR Political Rights"),
    detail = str_remove_all(detail, "1.00-4.00 pts0-4 pts")
  )

# trim and remove multiple spaces
country_rating_texts_gsy <- country_rating_texts_gsy %>%
  mutate(
    detail = str_replace_all(detail, "\\s+", " ")
  ) %>%
  mutate(
    detail = str_trim(detail)
  )

# convert the detail to a vector
detail <- country_rating_texts_gsy$detail

# split detail by sentence
detail <- str_split(detail, "\\. ") %>%
  unlist()

# count the number of repeated sentences
detail <- detail %>%
  tibble(detail = .) %>%
  group_by(detail) %>%
  mutate(n = n()) %>%
  ungroup()

detail %>%
  filter(detail != "") %>%
  filter(detail != ".") %>%
  arrange(-n)

country_rating_texts_gsy %>%
  filter(year == 2023, country == "Gambia")

country_rating_texts_gsy <- country_rating_texts_gsy %>%
  mutate(
    detail = case_when(
      sub_item == "Key Developmentslourenço" ~ paste("Lourenço", detail),
      TRUE ~ detail
    ),
    sub_item = case_when(
      sub_item == "Key Developmentslourenço" ~ "Key Developments",
      TRUE ~ sub_item
    )
  )

country_rating_texts_gsy %>%
  filter(sub_item == "Key Developmentslourenço")

country_rating_texts_gsy <- country_rating_texts_gsy %>%
  filter(detail != "")

country_rating_texts_gsy %>%
  filter(sub_item == "Key")

country_rating_texts_gsy <- country_rating_texts_gsy %>%
  mutate(
    detail = case_when(
      sub_item == "Key" ~ str_replace(detail, "DEVELOPMENTS 2023 ", ""),
      TRUE ~ detail
    ),
    sub_item = case_when(
      sub_item == "Key" ~ "Key Developments",
      TRUE ~ sub_item
    )
  )

country_rating_texts_gsy %>%
  filter(year == 2022, country == "Gambia")

country_rating_texts_gsy %>%
  filter(sub_item == "") %>%
  distinct(detail)

country_rating_texts_gsy <- country_rating_texts_gsy %>%
  mutate(
    sub_item = case_when(
      grepl("^Note ", detail) ~ "Notes",
      TRUE ~ sub_item
    ),
    detail = case_when(
      grepl("^Note ", detail) ~ str_replace(detail, "Note ", ""),
      TRUE ~ detail
    )
  )

country_rating_texts_gsy %>%
  filter(sub_item == "") %>%
  distinct(detail)

country_rating_texts_gsy <- country_rating_texts_gsy %>%
  mutate(
    sub_item = case_when(
      grepl("^Rating Change ", detail) ~ "Rating Change",
      TRUE ~ sub_item
    ),
    detail = case_when(
      grepl("^Rating Change ", detail) ~ str_replace(detail, "Rating Change ", ""),
      TRUE ~ detail
    )
  )

country_rating_texts_gsy <- country_rating_texts_gsy %>%
  mutate(
    sub_item = case_when(
      grepl("^Status Change ", detail) ~ "Status Change",
      TRUE ~ sub_item
    ),
    detail = case_when(
      grepl("^Status Change ", detail) ~ str_replace(detail, "Status Change ", ""),
      TRUE ~ detail
    )
  )

unique(country_rating_texts_gsy$sub_item)

# replace all Ratings change by Rating Change
country_rating_texts_gsy <- country_rating_texts_gsy %>%
  mutate(
    sub_item = case_when(
      sub_item == "Ratings Change" ~ "Rating Change",
      TRUE ~ sub_item
    )
  )

country_rating_texts_gsy %>%
  filter(sub_item == "") %>%
  distinct(detail)

country_rating_texts_gsy <- country_rating_texts_gsy %>%
  mutate(
    sub_item = case_when(
      grepl("^Trend Arrow ", detail) ~ "Trend Arrow",
      grepl("^Status Change, ", detail) ~ "Status Change",
      TRUE ~ sub_item
    ),
    detail = case_when(
      grepl("^Trend Arrow ", detail) ~ str_replace(detail, "Status Change ", ""),
      grepl("^Status Change, ", detail) ~ str_replace(detail, "Status Change, ", ""),
      TRUE ~ detail
    )
  )

country_rating_texts_gsy %>%
  filter(sub_item == "") %>%
  distinct() %>%
  pull(detail)

country_rating_texts_gsy <- country_rating_texts_gsy %>%
  mutate(
    detail = str_trim(str_replace_all(detail, "Capital La Paz \\(administrative\\), Sucre \\(judicial\\)", "")),
    detail = str_trim(str_replace_all(detail, "Capital Mbabane \\(administrative\\), Lobamba \\(legislative, royal\\)", ""))
  ) %>%
  mutate(
    sub_item = case_when(
      grepl("^Trend Arrow ", detail) ~ "Trend Arrow",
      TRUE ~ sub_item
    ),
    detail = case_when(
      grepl("^Trend Arrow ", detail) ~ str_replace(detail, "Trend Arrow ", ""),
      TRUE ~ detail
    )
  )

country_rating_texts_gsy <- country_rating_texts_gsy %>%
  filter(sub_item != "")

country_rating_texts_gsy %>%
  filter(sub_item == "")

# remove
# 0 / 4
# 1 / 4
# 1 / 4 (-1)
# 1 / 4 (+1)
# 3 / 4
# 3 / 4
# 4 / 4
country_rating_texts_gsy <- country_rating_texts_gsy %>%
  mutate(
    detail = case_when(
      grepl("^0 / 4", detail) ~ str_trim(str_replace(detail, "0 / 4", "")),
      grepl("^1 / 4", detail) ~ str_trim(str_replace(detail, "1 / 4", "")),
      grepl("^2 / 4", detail) ~ str_trim(str_replace(detail, "2 / 4", "")),
      grepl("^3 / 4", detail) ~ str_trim(str_replace(detail, "3 / 4", "")),
      grepl("^4 / 4", detail) ~ str_trim(str_replace(detail, "4 / 4", "")),
      TRUE ~ detail
    )
  )

country_rating_texts_gsy <- country_rating_texts_gsy %>%
  mutate(
    detail = str_trim(str_replace_all(detail, "\\(\\+1\\)", "")),
    detail = str_trim(str_replace_all(detail, "\\(–1\\)", "")), # not a -
    detail = str_trim(str_replace_all(detail, "\\(−1\\)", ""))
  )

# remove leading ‘
country_rating_texts_gsy <- country_rating_texts_gsy %>%
  mutate(
    detail = str_trim(str_replace_all(detail, "^‘", "")),
    detail = str_trim(str_replace_all(detail, "^'", ""))
  )

# fix double punctuation
country_rating_texts_gsy <- country_rating_texts_gsy %>%
  mutate(
    detail = str_replace_all(detail, "\\.\\.", ".")
  )

# fix multiple spaces
country_rating_texts_gsy <- country_rating_texts_gsy %>%
  mutate(
    detail = str_trim(str_replace_all(detail, "\\s+", " "))
  )

country_rating_texts <- freedomhouse::country_rating_texts %>%
  bind_rows(country_rating_texts_gsy) %>%
  arrange(country, year)

country_rating_texts <- country_rating_texts %>%
  mutate(sub_item = as_factor(sub_item))

levels(country_rating_texts$sub_item)

# make Overview the first sub_item
country_rating_texts <- country_rating_texts %>%
  mutate(
    sub_item = fct_relevel(sub_item, "Overview"),
    sub_item = fct_relevel(sub_item, "Key Developments", after = 1L),
    sub_item = fct_relevel(sub_item, "Rating Change", after = 2L),
    sub_item = fct_relevel(sub_item, "Status Change", after = 3L),
    sub_item = fct_relevel(sub_item, "Trend Arrow", after = 4L),
    sub_item = fct_relevel(sub_item, "Notes", after = 5L)
  )

country_rating_texts <- country_rating_texts %>%
  arrange(country, year, sub_item)

country_rating_texts %>%
  filter(year == 2020, country == "Gambia", sub_item == "A1")

country_rating_texts %>%
  filter(is.na(continent)) %>%
  distinct(year, country)

# add continent
country_rating_texts <- country_rating_texts %>%
  mutate(
    continent = as_factor(case_when(
      country == "Gambia" ~ "Africa",
      country == "St Vincent and Grenadines" ~ "North America",
      country == "Yemen" ~ "Asia",
      TRUE ~ continent
    ))
  )

country_rating_texts %>%
  group_by(year, country, sub_item, detail) %>%
  summarise(n = n()) %>%
  filter(n > 1)

country_rating_texts <- country_rating_texts %>%
  distinct()

levels(country_rating_texts$country)

# relevel country
country_rating_texts <- country_rating_texts %>%
  mutate(country = fct_relevel(country, sort))

use_data(country_rating_texts, overwrite = TRUE)
