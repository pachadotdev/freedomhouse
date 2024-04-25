
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Freedom House Datasets in R

<!-- badges: start -->

<!-- badges: end -->

The goal of freedomhouse is to ease the usage of the Freedom in the
World dataset from Freedom House in R. The Freedom in the World dataset
is updated annually and is originally available for download in Excel
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

Another addition of mine was is to add translations, such as the side
package `casadelalibertad`.

## Installation

You can install the development version of freedom from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("pachadotdev/freedomhouse")
```

To install a translation, such as the Spanish translation, you can use:

``` r
remotes::install_github("pachadotdev/freedomhouse", subdir = "translations/es")
```

## Example

This is a basic example which shows you how to join three tables

``` r
library(dplyr)
library(freedomhouse)

# Search for "trade union" in the sub_item_description column
country_scores %>%
  filter(grepl("trade union", sub_item_description))
#> # A tibble: 2,515 × 10
#>     year country_territory iso2c iso3c continent item  sub_item item_description
#>    <int> <fct>             <fct> <fct> <fct>     <fct> <fct>    <fct>           
#>  1  2012 Abkhazia          <NA>  <NA>  Asia      E     E3       Associational a…
#>  2  2013 Abkhazia          <NA>  <NA>  Asia      E     E3       Associational a…
#>  3  2014 Abkhazia          <NA>  <NA>  Asia      E     E3       Associational a…
#>  4  2015 Abkhazia          <NA>  <NA>  Asia      E     E3       Associational a…
#>  5  2016 Abkhazia          <NA>  <NA>  Asia      E     E3       Associational a…
#>  6  2017 Abkhazia          <NA>  <NA>  Asia      E     E3       Associational a…
#>  7  2018 Abkhazia          <NA>  <NA>  Asia      E     E3       Associational a…
#>  8  2019 Abkhazia          <NA>  <NA>  Asia      E     E3       Associational a…
#>  9  2020 Abkhazia          <NA>  <NA>  Asia      E     E3       Associational a…
#> 10  2021 Abkhazia          <NA>  <NA>  Asia      E     E3       Associational a…
#> # ℹ 2,505 more rows
#> # ℹ 2 more variables: sub_item_description <fct>, score <int>

# Get the full description of the sub-item
country_scores %>%
  filter(sub_item == "E3") %>%
  distinct(sub_item_description) %>%
  pull(sub_item_description)
#> [1] Is there freedom for trade unions and similar professional or labor organizations?
#> 26 Levels: Are individuals able to exercise the right to own property and establish private businesses without undue interference from state or nonstate actors? ...

# Filter by sub-item code and country code for trade unions in Canada
country_scores %>%
  filter(
    sub_item == "E3",
    iso3c == "CAN"
  ) %>%
  inner_join(
    country_rating_texts %>%
      select(year, iso3c, sub_item, detail) %>%
      filter(
        sub_item == "E3",
        iso3c == "CAN"
      ),
    by = c("year", "iso3c", "sub_item")
  ) %>%
  select(year, iso3c, sub_item, score, detail)
#> # A tibble: 7 × 5
#>    year iso3c sub_item score detail                                             
#>   <int> <fct> <fct>    <int> <chr>                                              
#> 1  2017 CAN   E3           4 Trade unions and business associations enjoy high …
#> 2  2018 CAN   E3           4 Trade unions and business associations enjoy high …
#> 3  2019 CAN   E3           4 Trade unions and business associations enjoy high …
#> 4  2020 CAN   E3           4 Trade unions and business associations enjoy high …
#> 5  2021 CAN   E3           4 Trade unions and business associations enjoy high …
#> 6  2022 CAN   E3           4 Trade unions and business associations enjoy high …
#> 7  2023 CAN   E3           4 Trade unions and business associations enjoy high …
```

## Shiny

There is an example with Shiny
[here](https://github.com/pachadotdev/freedomhouse/tree/main/shiny-demo).

## Translations

### Templates in Excel

The directory `dev/es` contains the Excel files with the translations.
These can be used as templates for translations to other languages
different from Spanish.

What I did to add the translations in R was to use the `left_join`
function from the `dplyr` package to match each country/item/sub-item
with the corresponding translation.

### Spanish

El *dataset* `puntajes_pais` es una traducción del original
`country_scores`:

``` r
glimpse(puntaje_pais)
```

Los datos traducidos quedarán cargados durante toda la sesión de R:

``` r
puntaje_pais %>%
  filter(pais_territorio == "Canad\u00e1")

puntaje_pais %>%
  filter(pais_territorio == "Canadá")
```

## Development

To verify any changes, run the following commands:

``` r
devtools::document()
attachment::att_amend_desc()
devtools::check()
```

Then update the site with:

``` r
unlink("docs", recursive = TRUE)
altdoc::use_mkdocs(theme = "readthedocs")
```
