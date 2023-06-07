# Packages ----

library(dplyr)
library(tidyr)
library(readxl)
library(countrycode)
library(stringr)

library(RPostgres)
library(economiccomplexity)
library(igraph)

library(janitor)
library(stringr)

library(usethis)
library(devtools)

# Political Rights and Civil Liberties ----

# Based on
# https://martakolczynska.com/post/cleaning-fh-data/
# https://freedomhouse.org/report/freedom-world/

url <- "https://freedomhouse.org/sites/default/files/2023-02/Country_and_Territory_Ratings_and_Statuses_FIW_1973-2023%20.xlsx"
raw_xlsx <- gsub("%20", "", gsub(".*/", "dev/", url))

if (!file.exists(raw_xlsx)) {
  download.file(url, raw_xlsx)
}

country_rating_statuses <- read_excel(raw_xlsx,
                            sheet = 2, # read in data from the second sheet
                            na = "-"
) # recode "-" to missing

names(country_rating_statuses)[1] <- "country"

country_rating_statuses

# filter out the first and second row of data
country_rating_statuses <- country_rating_statuses %>%
  filter(
    country != "Year(s) Under Review",
    !is.na(country)
  )

country_rating_statuses

# convert the whole data set to long format
country_rating_statuses <- country_rating_statuses %>%
  pivot_longer(cols = 2:151, names_to = "year", values_to = "value")

country_rating_statuses

# obtain the year by removing all non-numeric characters in year
country_rating_statuses <- country_rating_statuses %>%
  mutate(
    year = as.integer(gsub("[^0-9]", "", year)) - 1L,
    year = case_when(
      year < 1972 ~ NA_integer_,
      TRUE ~ year
    )
  )

country_rating_statuses

# replace year = NA
country_rating_statuses <- country_rating_statuses %>%
  fill(year)

country_rating_statuses

# add measurement categories
country_rating_statuses <- country_rating_statuses %>%
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

country_rating_statuses

# put in tidy format
country_rating_statuses <- country_rating_statuses %>%
  select(-n) %>%
  pivot_wider(names_from = category, values_from = value)

country_rating_statuses

# convert political rights and civil liberties to integer
remove_parenthesis <- function(x) {
  y <- str_extract(x, "\\((.*?)\\)")
  y <- str_replace_all(y, "\\(|\\)", "")
  return(y)
}

country_rating_statuses <- country_rating_statuses %>%
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

country_rating_statuses %>%
  filter(country == "South Africa", year == 1973)

country_rating_statuses

# recode the status
country_rating_statuses <- country_rating_statuses %>%
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

country_rating_statuses

# some verifications

country_rating_statuses %>%
  filter(is.na(country))

country_rating_statuses %>%
  filter(is.na(year))

country_rating_statuses %>%
  filter(is.na(political_rights))

# fix the year variable as some years are in the format "1983-84"
country_rating_statuses <- country_rating_statuses %>%
  mutate(
    year = case_when(
      nchar(year) > 4 ~ as.integer(substr(year, 1, 4)),
      TRUE ~ year
    )
  )

country_rating_statuses %>%
  filter(is.na(political_rights))

# discard country-year combinations with missing values
country_rating_statuses <- country_rating_statuses %>%
  drop_na(political_rights, civil_liberties, status)

# almost there, now add ISO-2 and ISO-3 codes
countries <- country_rating_statuses %>%
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
country_rating_statuses <- country_rating_statuses %>%
  left_join(countries, by = "country") %>%
  select(year, country, iso2c, iso3c, continent, political_rights, civil_liberties, status)

# add colours
country_rating_statuses <- country_rating_statuses %>%
  mutate(
    color = case_when(
      status == "Free" ~ "#549f95",
      status == "Partially Free" ~ "#a1aafc",
      status == "Not Free" ~ "#7454a6"
    )
  )

# covnert chr to fct
country_rating_statuses <- country_rating_statuses %>%
  mutate_if(is.character, as.factor)

# save
use_data(country_rating_statuses, overwrite = TRUE)

# Add a network of similar exports ----

con <- dbConnect(
    Postgres(),
    host = "localhost",
    dbname = "uncomtrade",
    user = Sys.getenv("LOCAL_SQL_USR"),
    password = Sys.getenv("LOCAL_SQL_PWD")
  )

trade <- tbl(con, "hs_rev1992_tf_import_al_6") %>%
  filter(year == 2020) %>%
  mutate(commodity_code = substr(commodity_code, 1, 4)) %>%
  filter(partner_iso != "wld") %>%
  filter(partner_iso != "0-unspecified") %>%
  filter(reporter_iso != "0-unspecified") %>%
  group_by(partner_iso, commodity_code) %>%
  summarise(
    trade = sum(trade_value_usd, na.rm = TRUE)
  ) %>%
  collect()

dbDisconnect(con)

trade <- trade %>%
  mutate(
    partner_iso = toupper(partner_iso)
  )

trade <- trade %>%
  filter(trade > 0)

trade <- trade %>%
  rename(country = partner_iso, product = commodity_code, value = trade)

trade_aux <- country_rating_statuses %>%
  filter(year == 2022) %>%
  distinct(country, iso2c, iso3c) %>%
  inner_join(
    trade %>%
      distinct(country), by = c("iso3c" = "country")) %>%
  inner_join(
    trade %>%
      distinct(country), by = c("iso3c" = "country"))

trade <- trade %>%
  inner_join(trade_aux, by = c("country" = "iso3c")) %>%
  select(country = country.y, product, value)

bi <- balassa_index(trade)

pro <- proximity(bi)

net <- projections(pro$proximity_country, pro$proximity_product)

country_exports_similarity <- net$network_country

trade <- trade %>%
  group_by(country) %>%
  summarise(value = sum(value, na.rm = TRUE))
trade_size <- trade$value
names(trade_size) <- trade$country
trade_size <- trade_size[V(country_exports_similarity)$name]
V(country_exports_similarity)$exports <- unname(trade_size)

trade_color <- tibble(country = trade$country) %>%
  left_join(
    country_rating_statuses %>% 
      filter(year == 2023) %>%
      select(country, color), 
    by = "country")
trade_color_2 <- trade_color$color
names(trade_color_2) <- trade_color$country
trade_color_2 <- trade_color_2[V(country_exports_similarity)$name]
V(country_exports_similarity)$color <- unname(trade_color_2)

V(country_exports_similarity)$status <- ifelse(V(country_exports_similarity)$color == "#549f95", "Free", 
  ifelse(V(country_exports_similarity)$color == "#a1aafc", "Partially Free", "Not Free"))

use_data(country_exports_similarity, overwrite = TRUE)

# Freedom in the World Dissaggregated Scores ----

url <- "https://freedomhouse.org/sites/default/files/2023-02/All_data_FIW_2013-2023.xlsx"
raw_xlsx <- gsub("%20", "", gsub(".*/", "dev/", url))

if (!file.exists(raw_xlsx)) {
  download.file(url, raw_xlsx)
}

category_scores <- read_excel(raw_xlsx,
                            sheet = 2, # read in data from the second sheet
                            skip = 1,
                            na = "N/A"
) %>%
  clean_names() %>%
  select(-c(region, status, pr_rating, cl_rating)) %>%
  # filter(c_t == "t") %>%
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

category_scores %>%
  filter(item == "p")

# remove aggregate scores
category_scores <- category_scores %>%
  filter(!sub_item %in% c("pr", "cl", "total"))

unique(category_scores$item)
unique(category_scores$sub_item)

category_scores_items <- category_scores %>%
  distinct(item, sub_item) %>%
  mutate(
    item_description = str_sub(item, 5),
    sub_item_description = str_sub(sub_item, 6),
    item = str_sub(item, 1, 1),
    sub_item = str_sub(sub_item, 1, 2)
  )

category_scores <- category_scores %>%
  mutate(
    item = str_sub(item, 1, 1),
    sub_item = str_sub(sub_item, 1, 2)
  )

# add iso2c, iso3c and continent
category_scores <- category_scores %>%
  # left_join(
  #   country_rating_statuses %>%
  #     select(country, iso2c, iso3c, continent) %>%
  #     distinct(),
  #   by = c("country_territory" = "country")
  # ) %>%
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
category_scores %>%
  select(country_territory, continent) %>%
  filter(is.na(continent)) %>%
  distinct()

category_scores <- category_scores %>%
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

category_scores %>%
  select(country_territory, continent) %>%
  filter(is.na(continent)) %>%
  distinct()

# convert chr to fct and dbl to int
category_scores <- category_scores %>%
  mutate_if(is.character, as.factor) %>%
  mutate_if(is.numeric, as.integer)

use_data(category_scores, overwrite = TRUE)
use_data(category_scores_items, overwrite = TRUE)

# Configure package and test ----

use_cc_license("by-nc-sa") # usethis version from https://github.com/r-lib/usethis/pull/1855
use_build_ignore("dev")
use_git_ignore(".Rproj.user")
use_git_ignore(".Rhistory")
document()
check()

use_readme_rmd()
