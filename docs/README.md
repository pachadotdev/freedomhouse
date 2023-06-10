
<!-- README.md is generated from README.Rmd. Please edit that file -->

# freedom

<!-- badges: start -->

<!-- badges: end -->

The goal of freedom is to ease the usage of the Freedom in the World
dataset from Freedom House in R. The Freedom in the World dataset is
updated annually and is originally available for download in Excel
format.

Freedom House is best known for political advocacy surrounding issues of
Democracy, Political Freedom, and Human Rights. Each of these issues
trascends political colours. The Freedom in the World dataset is a
comprehensive and widely used measure of political freedom. It is used
by academics, journalists, and policy makers alike.

My added value is to presents all the tables in a really simple to use
format and to make all the texts with the justifications for each
sub-item scores, that you find in around 1,000 links of the form
<https://freedomhouse.org/country/canada/freedom-world/2023>, available
in a single tidy table. This is useful for text mining and sentiment
analysis.

## Installation

You can install the development version of freedom from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("pachadotdev/freedom")
```

## Example

This is a basic example which shows you how to join three tables

``` r
library(dplyr)
library(freedom)

# Search for "trade union" in the sub_item_description column
category_scores_items %>%
  filter(grepl("trade union", sub_item_description))
#> # A tibble: 1 × 4
#>   item  sub_item item_description                        sub_item_description   
#>   <chr> <chr>    <chr>                                   <chr>                  
#> 1 E     E3       Associational and Organizational Rights Is there freedom for t…

# Get the full description of the sub-item
category_scores_items %>%
  filter(sub_item == "E3") %>%
  pull(sub_item_description)
#> [1] "Is there freedom for trade unions and similar professional or labor organizations?"

# Filter by sub-item code and country code for trade unions in Canada
category_scores %>%
  filter(
    sub_item == "E3",
    iso3c == "CAN"
  )  %>%
  inner_join(
    country_ratings_texts %>%
      select(year, iso3c, sub_item, detail) %>%
      filter(
        sub_item == "E3",
        iso3c == "CAN"
      ),
    by = c("year", "iso3c", "sub_item")
  ) %>%
  select(year, iso3c, detail)
#> # A tibble: 6 × 3
#>    year iso3c detail                                                            
#>   <int> <fct> <chr>                                                             
#> 1  2022 CAN   Trade unions and business associations enjoy high levels of membe…
#> 2  2021 CAN   Trade unions and business associations enjoy high levels of membe…
#> 3  2020 CAN   Trade unions and business associations enjoy high levels of membe…
#> 4  2019 CAN   Trade unions and business associations enjoy high levels of membe…
#> 5  2018 CAN   Trade unions and business associations enjoy high levels of membe…
#> 6  2017 CAN   Trade unions and business associations enjoy high levels of membe…
```
