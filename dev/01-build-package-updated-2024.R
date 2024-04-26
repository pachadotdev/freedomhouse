# Packages ----

library(dplyr)
library(tidyr)
library(readxl)
library(purrr)
library(forcats)

library(countrycode)
library(stringr)
library(janitor)

library(rvest)

library(usethis)
library(devtools)

# Political Rights and Civil Liberties ----

# Based on
# https://martakolczynska.com/post/cleaning-fh-data/
# https://freedomhouse.org/report/freedom-world/

url <- "https://freedomhouse.org/sites/default/files/2024-02/Country_and_Territory_Ratings_and_Statuses_FIW_1973-2024.xlsx"
raw_xlsx <- gsub(".*/", "dev/", url)

if (!file.exists(raw_xlsx)) {
  download.file(url, raw_xlsx)
}

country_rating_status <- read_excel(raw_xlsx,
  sheet = 2, # read in data from the second sheet
  na = "-" # recode "-" to missing
)

names(country_rating_status)[1] <- "country"

country_rating_status

# filter out the first and second row of data
country_rating_status <- country_rating_status %>%
  filter(
    country != "Year(s) Under Review",
    !is.na(country)
  )

country_rating_status

# convert the whole data set to long format
country_rating_status <- country_rating_status %>%
  pivot_longer(cols = 2:154, names_to = "year", values_to = "value")

country_rating_status

# obtain the year by removing all non-numeric characters in year
country_rating_status <- country_rating_status %>%
  mutate(
    year = as.integer(gsub("[^0-9]", "", year)) - 1L,
    year = case_when(
      year < 1972 ~ NA_integer_,
      TRUE ~ year
    )
  )

country_rating_status

# replace year = NA
country_rating_status <- country_rating_status %>%
  fill(year)

country_rating_status

max(country_rating_status$year)

# add measurement categories
country_rating_status <- country_rating_status %>%
  group_by(country, year) %>%
  mutate(
    n = row_number(),
    category = case_when(
      n == 1 ~ "political_rights",
      n == 2 ~ "civil_liberties",
      n == 3 ~ "status"
    )
  ) %>%
  ungroup()

country_rating_status

# put in tidy format
country_rating_status <- country_rating_status %>%
  select(-n) %>%
  pivot_wider(names_from = category, values_from = value)

country_rating_status

# convert political rights and civil liberties to integer
remove_parenthesis <- function(x) {
  y <- str_extract(x, "\\((.*?)\\)")
  y <- str_replace_all(y, "\\(|\\)", "")
  return(y)
}

country_rating_status <- country_rating_status %>%
  mutate(
    political_rights = case_when(
      country == "South Africa" & year == 1973 ~ remove_parenthesis(political_rights),
      TRUE ~ political_rights
    ),
    civil_liberties = case_when(
      country == "South Africa" & year == 1973 ~ remove_parenthesis(civil_liberties),
      TRUE ~ civil_liberties
    ),
    status = case_when(
      country == "South Africa" & year == 1973 ~ remove_parenthesis(status),
      TRUE ~ status
    ),
    political_rights = as.integer(political_rights),
    civil_liberties = as.integer(civil_liberties)
  )

country_rating_status %>%
  filter(country == "South Africa", year == 1973)

country_rating_status

# recode the status
country_rating_status <- country_rating_status %>%
  mutate(
    status = factor(
      case_when(
        status == "PF" ~ "Partially Free",
        status == "NF" ~ "Not Free",
        status == "F" ~ "Free"
      ),
      levels = c("Free", "Partially Free", "Not Free"),
    )
  )

country_rating_status

# some verifications

country_rating_status %>%
  filter(is.na(country))

country_rating_status %>%
  filter(is.na(year))

country_rating_status %>%
  filter(is.na(political_rights))

# fix the year variable as some years are in the format "1983-84"
country_rating_status <- country_rating_status %>%
  mutate(
    year = case_when(
      nchar(year) > 4 ~ as.integer(substr(year, 1, 4)),
      TRUE ~ year
    )
  )

max(country_rating_status$year)

country_rating_status %>%
  filter(is.na(political_rights))

# discard country-year combinations with missing values
country_rating_status <- country_rating_status %>%
  drop_na(political_rights, civil_liberties, status)

# almost there, now add ISO-2 and ISO-3 codes
countries <- country_rating_status %>%
  ungroup() %>%
  distinct(country) %>%
  mutate(
    iso2c = countrycode(
      country,
      origin = "country.name",
      destination = "iso2c"
    ),
    iso3c = countrycode(
      country,
      origin = "country.name",
      destination = "iso3c"
    )
  )

# countries without unambiguous matches
countries %>%
  filter(is.na(iso2c))

# add continent
countries <- countries %>%
  mutate(
    continent = countrycode(
      iso3c,
      origin = "iso3c",
      destination = "continent"
    )
  )

# fix missing continents
countries %>%
  filter(is.na(continent))

countries <- countries %>%
  mutate(
    continent = case_when(
      country == "Czechoslovakia" ~ "Europe",
      country == "Kosovo" ~ "Europe",
      country == "Micronesia" ~ "Oceania",
      country == "Serbia and Montenegro" ~ "Europe",
      country == "Yugoslavia" ~ "Europe",
      TRUE ~ continent
    )
  )

# join the two data sets
country_rating_status <- country_rating_status %>%
  left_join(countries, by = "country") %>%
  select(year, country, iso2c, iso3c, continent, political_rights, civil_liberties, status)

# add colours
country_rating_status <- country_rating_status %>%
  mutate(
    color = case_when(
      status == "Free" ~ "#549f95",
      status == "Partially Free" ~ "#a1aafc",
      status == "Not Free" ~ "#7454a6"
    )
  )

# convert chr to fct
country_rating_status <- country_rating_status %>%
  mutate_if(is.character, as.factor)

country_rating_status %>%
  filter(is.na(iso2c)) %>%
  distinct(country)

# save
use_data(country_rating_status, overwrite = TRUE, compress = "xz")

# Freedom in the World Dissaggregated Scores ----

url <- "https://freedomhouse.org/sites/default/files/2024-02/All_data_FIW_2013-2024.xlsx"
raw_xlsx <- gsub(".*/", "dev/", url)

if (!file.exists(raw_xlsx)) {
  download.file(url, raw_xlsx)
}

country_score <- read_excel(raw_xlsx,
  sheet = 2, # read in data from the second sheet
  skip = 1,
  na = "N/A"
) %>%
  clean_names() %>%
  select(-c(region, status, pr_rating, cl_rating)) %>%
  pivot_longer(
    cols = -c(country_territory, c_t, edition),
    names_to = "item",
    values_to = "score"
  ) %>%
  filter(!item %in% letters[1:7]) %>%
  mutate(
    sub_item = item,
    item = substr(item, 1, 1),
    item = case_when(
      item == "a" ~ "A - Political Rights",
      item == "b" ~ "B - Political Pluralism and Participation",
      item == "c" ~ "C - Functioning of Government",
      item == "d" ~ "D - Freedom of Expression and Belief",
      item == "e" ~ "E - Associational and Organizational Rights",
      item == "f" ~ "F - Rule of Law",
      item == "g" ~ "G - Personal Autonomy and Individual Rights",
      TRUE ~ item
    ),
    sub_item = case_when(
      sub_item == "a1" ~ "A1 - Was the current head of government or other chief national authority elected through free and fair elections?",
      sub_item == "a2" ~ "A2 - Were the current national legislative representatives elected through free and fair elections?",
      sub_item == "a3" ~ "A3 - Are the electoral laws and framework fair, and are they implemented impartially by the relevant election management bodies?",
      sub_item == "b1" ~ "B1 - Do the people have the right to organize in different political parties or other competitive political groupings of their choice, and is the system free of undue obstacles to the rise and fall of these competing parties or groupings?",
      sub_item == "b2" ~ "B2 - Is there a realistic opportunity for the opposition to increase its support or gain power through elections?",
      sub_item == "b3" ~ "B3 - Are the people’s political choices free from domination by the military, foreign powers, religious hierarchies, economic oligarchies, or any other powerful group that is not democratically accountable?",
      sub_item == "b4" ~ "B4 - Do various segments of the population (including ethnic, religious, gender, LGBT, and other relevant groups) have full political rights and electoral opportunities?",
      sub_item == "c1" ~ "C1 - Do the freely elected head of government and national legislative representatives determine the policies of the government?",
      sub_item == "c2" ~ "C2 - Are safeguards against official corruption strong and effective?",
      sub_item == "c3" ~ "C3 - Does the government operate with openness and transparency?",
      sub_item == "d1" ~ "D1 - Are there free and independent media?",
      sub_item == "d2" ~ "D2 - Are individuals free to practice and express their religious faith or nonbelief in public and private?",
      sub_item == "d3" ~ "D3 - Is there academic freedom, and is the educational system free from extensive political indoctrination?",
      sub_item == "d4" ~ "D4 - Are individuals free to express their personal views on political or other sensitive topics without fear of surveillance or retribution?",
      sub_item == "e1" ~ "E1 - Is there freedom of assembly?",
      sub_item == "e2" ~ "E2 - Is there freedom for nongovernmental organizations, particularly those that are engaged in human rights– and governance-related work?",
      sub_item == "e3" ~ "E3 - Is there freedom for trade unions and similar professional or labor organizations?",
      sub_item == "f1" ~ "F1 - Is there an independent judiciary?",
      sub_item == "f2" ~ "F2 - Does due process prevail in civil and criminal matters?",
      sub_item == "f3" ~ "F3 - Is there protection from the illegitimate use of physical force and freedom from war and insurgencies?",
      sub_item == "f4" ~ "F4 - Do laws, policies, and practices guarantee equal treatment of various segments of the population?",
      sub_item == "g1" ~ "G1 - Do individuals enjoy freedom of movement, including the ability to change their place of residence, employment, or education?",
      sub_item == "g2" ~ "G2 - Are individuals able to exercise the right to own property and establish private businesses without undue interference from state or nonstate actors?",
      sub_item == "g3" ~ "G3 - Do individuals enjoy personal social freedoms, including choice of marriage partner and size of family, protection from domestic violence, and control over appearance?",
      sub_item == "g4" ~ "G4 - Is there equality of opportunity and the absence of economic exploitation?",
      TRUE ~ sub_item
    )
  ) %>%
  mutate(year = as.integer(edition - 1)) %>%
  select(year, country_territory, c_t, item, sub_item, score)

country_score %>%
  filter(item == "p")

# remove aggregate scores
country_score <- country_score %>%
  filter(!sub_item %in% c("pr", "cl", "total"))

unique(country_score$item)
unique(country_score$sub_item)

country_score_items <- country_score %>%
  distinct(item, sub_item) %>%
  mutate(
    item_description = str_sub(item, 5),
    sub_item_description = str_sub(sub_item, 6),
    item = str_sub(item, 1, 1),
    sub_item = str_sub(sub_item, 1, 2)
  )

country_score <- country_score %>%
  mutate(
    item = str_sub(item, 1, 1),
    sub_item = str_sub(sub_item, 1, 2)
  )

# add iso2c, iso3c and continent
country_score <- country_score %>%
  mutate(
    iso2c = countrycode(
      country_territory,
      origin = "country.name",
      destination = "iso2c"
    ),
    iso3c = countrycode(
      country_territory,
      origin = "country.name",
      destination = "iso3c"
    ),
    continent = countrycode(
      country_territory,
      origin = "country.name",
      destination = "continent"
    )
  ) %>%
  select(year, country_territory, iso2c, iso3c, continent, item, sub_item, score)

# fix missing continents
country_score %>%
  select(country_territory, continent) %>%
  filter(is.na(continent)) %>%
  distinct()

country_score <- country_score %>%
  mutate(
    continent = case_when(
      country_territory == "Abkhazia" ~ "Asia",
      country_territory == "Crimea" ~ "Europe",
      country_territory == "Eastern Donbas" ~ "Europe",
      country_territory == "Kosovo" ~ "Europe",
      country_territory == "Micronesia" ~ "Oceania",
      country_territory == "Nagorno-Karabakh" ~ "Asia",
      country_territory == "South Ossetia" ~ "Asia",
      country_territory == "Tibet" ~ "Asia",
      country_territory == "Transnistria" ~ "Europe",
      TRUE ~ continent
    )
  )

country_score %>%
  select(country_territory, continent) %>%
  filter(is.na(continent)) %>%
  distinct()

# convert chr to fct and dbl to int
country_score <- country_score %>%
  mutate_if(is.character, as.factor) %>%
  mutate_if(is.numeric, as.integer)

unique(country_score$sub_item)
unique(nchar(country_score_items$sub_item_description))

country_score_items %>%
  mutate(n = nchar(sub_item_description)) %>%
  arrange(n)

country_score_items %>%
  filter(is.na(sub_item))

country_score_items %>%
  filter(sub_item == "ad")

country_score <- country_score %>%
  filter(sub_item != "ad")

country_score_items <- country_score_items %>%
  filter(sub_item != "ad")

sort(unique(country_score_items$sub_item_description))

# remove – and change ’ for '
country_score_items <- country_score_items %>%
  mutate(
    sub_item_description = str_replace_all(sub_item_description, "–", " "),
    sub_item_description = str_replace_all(sub_item_description, "\\s+", " "),
    sub_item_description = str_replace_all(sub_item_description, "’", "'"),
  )

country_score <- country_score %>%
  left_join(country_score_items) %>%
  select(-score, everything()) %>%
  mutate(
    item = as.factor(item),
    sub_item = as.factor(sub_item),
    item_description = as.factor(item_description),
    sub_item_description = as.factor(sub_item_description)
  )

# fix 'Is there freedom for nongovernmental organizations, particularly those that are engaged in human rights and governance-related work?'

country_score <- country_score %>%
  mutate(
    sub_item_description = case_when(
      sub_item_description == "Is there freedom for nongovernmental organizations, particularly those that are engaged in human rights and governance-related work?" ~ "Is there freedom for nongovernmental organizations, particularly those that are engaged in human rights and governance related work?",
      TRUE ~ sub_item_description
    )
  )

# fix
# 'Pakistani Kashmir' -> 'Pakistan Kashmir'
# 'Transnitria' -> 'Transnistria'
country_score <- country_score %>%
  mutate(
    country_territory = case_when(
      country_territory == "Pakistani Kashmir" ~ "Pakistan Kashmir",
      country_territory == "Transnitria" ~ "Transnistria",
      TRUE ~ country_territory
    )
  )

country_score %>%
  filter(is.na(iso2c)) %>%
  distinct(country_territory) %>%
  mutate(iso2c = countrycode(country_territory, origin = "country.name", destination = "iso2c"))

use_data(country_score, overwrite = TRUE, compress = "xz")

# Add texts ----

# for each x=country since y=2018, go to https://freedomhouse.org/country/x/freedom-world/y/

# use /y/ to avoid messing /yemen
baseurl <- "https://freedomhouse.org/country/x/freedom-world/y/"

countries <- str_to_lower(unique(country_rating_status$country))
countries <- str_replace_all(countries, " ", "-")

# remove all after ","
countries <- str_split(countries, ",") %>%
  map_chr(1)

countries <- str_replace_all(countries, "\\.", "")

# fix urls
# the-gambia -> gambia
# st-vincent-and-the-grenadines -> st-vincent-and-grenadines
countries <- str_replace_all(countries, "the-gambia", "gambia")
countries <- str_replace_all(countries, "st-vincent-and-the-grenadines", "st-vincent-and-grenadines")

countries <- sort(unique(countries))colnames(remote_tbl) <- c("country", "total_score", "political_rights", "civil_liberties")


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

# same fix as for the urls
remote_tbl <- remote_tbl %>%
  mutate(
    country = str_replace_all(country, "the-gambia", "gambia"),
    country = str_replace_all(country, "st-vincent-and-the-grenadines", "st-vincent-and-grenadines")
  ) %>%
  arrange(country)

unique(remote_tbl$country)

countries <- countries[countries %in% remote_tbl$country]
countries <- unique(sort(countries))

country_text <- list()

for (i in seq_along(countries)) {
  country <- countries[i]
  for (year in 2018:2024) {
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

country_text <- country_text %>%
  map(~ str_replace_all(.x, "\n", "")) %>% # remove all \n
  map(~ str_replace_all(.x, "\\s+", " ")) %>% # remove multiple spaces
  map(~ str_replace_all(.x, "header[0-9]", "")) %>% # remove "headerX"
  map(~ str_replace_all(.x, "Overview", "BEGIN OVERVIEW")) %>% # add "BEGIN OVERVIEW"
  map(~ str_replace_all(.x, "Key Developments", "END OVERVIEW BEGIN KEY DEVELOPMENTS")) %>% # add "BEGIN OVERVIEW"
  # from here I use the item description to tag each insight
  map(~ str_replace_all(
    .x,
    country_score_items %>%
      filter(sub_item == "A1") %>%
      pull(sub_item_description),
    "BEGIN A1"
  ))

# add END %s BEGIN %s

sub_items <- country_score_items %>%
  distinct(sub_item) %>%
  pull(sub_item)

# can this be done in a single map? at least it works
for (x in seq_along(country_text)) {
  for (y in seq_along(sub_items)) {
    print(paste(x, y))
    if (y <= 24) {
      z <- sprintf("END %s BEGIN %s", sub_items[y], sub_items[y + 1])

      country_text[[x]] <- str_replace_all(
        country_text[[x]],
        country_score_items %>%
          filter(sub_item == sub_items[y + 1]) %>%
          pull(sub_item_description),
        z
      )
    } else {
      z <- sprintf("END %s", sub_items[y])
      country_text[[x]] <- str_replace_all(
        country_text[[x]],
        country_score_items %>%
          filter(sub_item == sub_items[y]) %>%
          pull(sub_item_description),
        z
      )
    }
  }
}

# add END G4 at the end of each text
for (x in seq_along(country_text)) {
  print(x)
  country_text[[x]] <- paste0(country_text[[x]], " END G4")
}

country_text$canada_2024

country_score_items %>%
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

country_text$canada_2024

country_rating_text <- map_df(
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
country_rating_text <- country_rating_text %>%
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

unique(country_rating_text$country)

# obtain iso code for the country and then replace with the names as they are in country_rating_status

country_rating_status %>%
  filter(grepl("Timor", country)) %>%
  distinct(country)

# check the match
country_rating_text %>%
  mutate(
    country = str_replace(country, " And ", " and "),
    country = str_replace(country, "St ", "St\\. "),
    country = str_replace(country, "Guinea Bissau", "Guinea-Bissau"),
    country = str_replace(country, "Timor Leste", "Timor-Leste")
  ) %>%
  left_join(
    country_rating_status %>%
      select(country, iso3c, iso2c, continent) %>%
      distinct(),
    by = "country"
  ) %>%
  filter(is.na(continent)) %>%
  distinct(country)

country_rating_text <- country_rating_text %>%
  mutate(
    country = str_replace(country, " And ", " and "),
    country = str_replace(country, "St ", "St\\. "),
    country = str_replace(country, "Guinea Bissau", "Guinea-Bissau"),
    country = str_replace(country, "Timor Leste", "Timor-Leste")
  ) %>%
  left_join(
    country_rating_status %>%
      select(country, iso3c, iso2c, continent) %>%
      distinct(),
    by = "country"
  ) %>%
  select(year, country, iso3c, iso2c, continent, sub_item, detail)

country_rating_text %>%
  filter(is.na(continent)) %>%
  distinct(country)

# add continent for Gambia and St. Vincent and Grenadines
country_rating_text <- country_rating_text %>%
  mutate(
    continent = case_when(
      country == "Gambia" ~ "Africa",
      country == "St. Vincent and Grenadines" ~ "Americas",
      TRUE ~ continent
    )
  )

# remove starting "Ratings Change " from detail
country_rating_text <- country_rating_text %>%
  mutate(
    detail = str_remove(detail, "^Ratings Change ")
  )

# fix ' and "
country_rating_text <- country_rating_text %>%
  mutate(
    detail = str_replace_all(detail, "’", "'"),
    detail = str_replace_all(detail, "“", "\""),
    detail = str_replace_all(detail, "”", "\"")
  )

# convert country to fct
country_rating_text <- country_rating_text %>%
  mutate(country = as.factor(country))

# substract 1 year
country_rating_text <- country_rating_text %>%
  mutate(year = year - 1L)

# put iso2c before iso3c, oops
country_rating_text <- country_rating_text %>%
  select(year, country, iso2c, iso3c, continent, sub_item, detail)

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
country_rating_text <- country_rating_text %>%
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
country_rating_text <- country_rating_text %>%
  mutate(
    detail = str_replace_all(detail, "\\s+", " ")
  ) %>%
  mutate(
    detail = str_trim(detail)
  )

# convert the detail to a vector
detail <- country_rating_text$detail

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

country_rating_text %>%
  filter(year == 2020, country == "Angola")

country_rating_text <- country_rating_text %>%
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

country_rating_text %>%
  filter(sub_item == "Key Developmentslourenço")

country_rating_text <- country_rating_text %>%
  filter(detail != "")

country_rating_text %>%
  filter(sub_item == "Key")

country_rating_text <- country_rating_text %>%
  mutate(
    detail = case_when(
      sub_item == "Key" ~ str_replace(detail, "DEVELOPMENTS 2022 ", ""),
      sub_item == "Key" ~ str_replace(detail, "DEVELOPMENTS 2023 ", ""),
      TRUE ~ detail
    ),
    sub_item = case_when(
      sub_item == "Key" ~ "Key Developments",
      TRUE ~ sub_item
    )
  )

country_rating_text %>%
  filter(year == 2023, country == "Cuba")

country_rating_text %>%
  filter(sub_item == "") %>%
  distinct(detail)

country_rating_text <- country_rating_text %>%
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

country_rating_text %>%
  filter(sub_item == "") %>%
  distinct(detail)

country_rating_text <- country_rating_text %>%
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

country_rating_text <- country_rating_text %>%
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

unique(country_rating_text$sub_item)

# replace all Ratings change by Rating Change
country_rating_text <- country_rating_text %>%
  mutate(
    sub_item = case_when(
      sub_item == "Ratings Change" ~ "Rating Change",
      TRUE ~ sub_item
    )
  )

country_rating_text %>%
  filter(sub_item == "") %>%
  distinct(detail)

country_rating_text <- country_rating_text %>%
  mutate(
    sub_item = case_when(
      grepl("^Trend Arrow ", detail) ~ "Trend Arrow",
      TRUE ~ sub_item
    ),
    detail = case_when(
      grepl("^Trend Arrow ", detail) ~ str_replace(detail, "Status Change ", ""),
      TRUE ~ detail
    )
  )

country_rating_text %>%
  filter(sub_item == "") %>%
  distinct() %>%
  pull(detail)

country_rating_text <- country_rating_text %>%
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

country_rating_text %>%
  filter(sub_item == "")

# Gambia 2017: remove "Status Change, Rating Change " from detail and add "Status Change" to sub_item
country_rating_text <- country_rating_text %>%
  mutate(
    detail = case_when(
      country == "Gambia" & year == 2017 & sub_item == "" ~ str_replace(detail, "Status Change, Rating Change ", ""),
      TRUE ~ detail
    ),
    sub_item = case_when(
      country == "Gambia" & year == 2017 & sub_item == "" ~ "Status Change",
      TRUE ~ sub_item
    )
  )

country_rating_text <- country_rating_text %>%
  filter(sub_item != "")

country_rating_text %>%
  filter(country == "Fiji")

# remove
# 0 / 4
# 1 / 4
# 1 / 4 (-1)
# 1 / 4 (+1)
# 3 / 4
# 3 / 4
# 4 / 4
country_rating_text <- country_rating_text %>%
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

country_rating_text <- country_rating_text %>%
  mutate(
    detail = str_trim(str_replace_all(detail, "\\(\\+1\\)", "")),
    detail = str_trim(str_replace_all(detail, "\\(–1\\)", "")), # not a -
    detail = str_trim(str_replace_all(detail, "\\(−1\\)", ""))
  )

# remove leading ‘
country_rating_text <- country_rating_text %>%
  mutate(
    detail = str_trim(str_replace_all(detail, "^‘", "")),
    detail = str_trim(str_replace_all(detail, "^'", ""))
  )

# fix double punctuation
country_rating_text <- country_rating_text %>%
  mutate(
    detail = str_replace_all(detail, "\\.\\.", ".")
  )

# fix multiple spaces
country_rating_text <- country_rating_text %>%
  mutate(
    detail = str_trim(str_replace_all(detail, "\\s+", " "))
  )

country_rating_text <- country_rating_text %>%
  distinct()

country_rating_text %>%
  filter(is.na(iso3c)) %>%
  distinct(country) %>%
  mutate(
    iso2c = countrycode(country, origin = "country.name", destination = "iso2c"),
    iso3c = countrycode(country, origin = "country.name", destination = "iso3c")
  )

# add iso2/3 to Gambia and St. Vincent and Grenadines
country_rating_text <- country_rating_text %>%
  mutate(
    iso3c = case_when(
      country == "Gambia" ~ "GMB",
      country == "St. Vincent and Grenadines" ~ "VCT",
      TRUE ~ iso3c
    ),
    iso2c = case_when(
      country == "Gambia" ~ "GM",
      country == "St. Vincent and Grenadines" ~ "VC",
      TRUE ~ iso2c
    )
  )

# convert iso2/3, continent and sub_item to fct
country_rating_text <- country_rating_text %>%
  mutate(
    iso2c = as_factor(iso2c),
    iso3c = as_factor(iso3c),
    continent = as_factor(continent),
    sub_item = as_factor(sub_item)
  )

levels(country_rating_text$continent)
levels(country_rating_text$sub_item)

# sub_item order: Overview, Key Developments, Status Change, Rating Change, Trend Arrow, Notes, A1, ...
country_rating_text <- country_rating_text %>%
  mutate(
    sub_item = fct_relevel(sub_item, "Overview"),
    sub_item = fct_relevel(sub_item, "Key Developments", after = 1L),
    sub_item = fct_relevel(sub_item, "Status Change", after = 2L),
    sub_item = fct_relevel(sub_item, "Rating Change", after = 3L),
    sub_item = fct_relevel(sub_item, "Trend Arrow", after = 4L),
    sub_item = fct_relevel(sub_item, "Notes", after = 5L)
  )

country_rating_text %>%
  filter(is.na(iso2c)) %>%
  distinct(country) %>%
  mutate(iso2c = countrycode(country, origin = "country.name", destination = "iso2c"))

use_data(country_rating_text, overwrite = TRUE, compress = "xz")

# Configure package and test ----

use_cc_license("by-nc-sa") # usethis version from https://github.com/r-lib/usethis/pull/1855
use_build_ignore("dev")
use_build_ignore("README.html")
use_build_ignore("README_files")
use_build_ignore(".github")
use_git_ignore(".Rproj.user")
use_git_ignore(".Rhistory")
use_git_ignore("README.html")
use_git_ignore("README_files")
document()
check()

use_news_md()
use_readme_rmd()
