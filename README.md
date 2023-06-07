
<!-- README.md is generated from README.Rmd. Please edit that file -->

# freedom

<!-- badges: start -->

<!-- badges: end -->

The goal of freedom is to ease the usage of the Freedom in the World
dataset from Freedom House in R.

Freedom House is best known for political advocacy surrounding issues of
Democracy, Political Freedom, and Human Rights. Each of these issues
trascends political colours. The Freedom in the World dataset is a
comprehensive and widely used measure of political freedom. It is used
by academics, journalists, and policy makers alike.

The Freedom in the World dataset is updated annually and is originally
available for download in Excel format.

## Installation

You can install the development version of freedom from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("pachadotdev/freedom")
```

## Example

This is a basic example which shows you how to join two tables

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
  )
#> # A tibble: 11 × 8
#>     year country_territory iso2c iso3c continent item  sub_item score
#>    <int> <fct>             <fct> <fct> <fct>     <fct> <fct>    <int>
#>  1  2022 Canada            CA    CAN   Americas  E     E3           4
#>  2  2021 Canada            CA    CAN   Americas  E     E3           4
#>  3  2020 Canada            CA    CAN   Americas  E     E3           4
#>  4  2019 Canada            CA    CAN   Americas  E     E3           4
#>  5  2018 Canada            CA    CAN   Americas  E     E3           4
#>  6  2017 Canada            CA    CAN   Americas  E     E3           4
#>  7  2016 Canada            CA    CAN   Americas  E     E3           4
#>  8  2015 Canada            CA    CAN   Americas  E     E3           4
#>  9  2014 Canada            CA    CAN   Americas  E     E3           4
#> 10  2013 Canada            CA    CAN   Americas  E     E3           4
#> 11  2012 Canada            CA    CAN   Americas  E     E3           4
```
