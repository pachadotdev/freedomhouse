
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Freedom House Datasets in R <img src="man/figures/logo.svg" align="right" height="139" alt="" />

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

Another addition of mine was is to add translations. This work is not
affiliated with Freedom House.

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

This is a basic example which shows you how to use the available three
tables.

``` r
library(dplyr)
library(freedomhouse)

# Search Canada in 2023
country_rating_status %>%
  filter(country == "Canada", year == 2023)
#> # A tibble: 1 × 9
#>    year country iso2c iso3c continent political_rights civil_liberties status
#>   <int> <fct>   <fct> <fct> <fct>                <int>           <int> <fct> 
#> 1  2023 Canada  CA    CAN   Americas                 1               1 Free  
#> # ℹ 1 more variable: color <fct>

# Search for the "trade union" sub item score for Canada
country_score %>%
  filter(country == "Canada", year == 2023) %>%
  filter(grepl("trade union", sub_item_description)) %>%
  select(sub_item_description)
#> # A tibble: 1 × 1
#>   sub_item_description                                                          
#>   <fct>                                                                         
#> 1 Is there freedom for trade unions and similar professional or labor organizat…

# Get the full description of the "trade union" sub-item
country_score %>%
  filter(sub_item == "E3") %>%
  distinct(sub_item_description)
#> # A tibble: 1 × 1
#>   sub_item_description                                                          
#>   <fct>                                                                         
#> 1 Is there freedom for trade unions and similar professional or labor organizat…

# Get the justification for the score on sub item E3
country_rating_text %>%
  filter(
    iso3c == "CAN",
    year == 2023,
    sub_item == "E3"
  ) %>%
  pull(detail)
#> [1] Trade unions and business associations enjoy high levels of membership and are well organized.
#> 29256 Levels: Afghanistan's political rights rating improved from 6 to 5 due to increased opposition political activity ahead of scheduled elections, as well as modest gains in government transparency. ...
```

## Shiny

There is an example with Shiny
[here](https://github.com/pachadotdev/freedomhouse/tree/main/shiny-demo).

## Translations

### Templates in Excel

The directory `dev/texts` contains the Excel files that I used for the
translations in `dev/texts/translation_es`. These can be used as
templates for translations to other languages different from Spanish.

What I did to add the translations in R was to use the `left_join`
function from the `dplyr` package to match each country/item/sub-item
with the corresponding translation.

### Spanish

Replica del ejemplo anterior.

``` r
# remotes::install_github("pachadotdev/freedomhouse", subdir = "translations/es")
library(dplyr)
library(freedomhouse)

estado_calificacion_pais %>%
  filter(pais == "Canadá", anio == 2023)

# # A tibble: 1 × 9
#    anio pais   iso2c iso3c continente derechos_politicos libertades_civiles
#   <int> <fct>  <fct> <fct> <fct>                   <int>              <int>
# 1  2023 Canadá CA    CAN   Américas                    1                  1
# # ℹ 2 more variables: estado <fct>, color <fct>

puntaje_pais %>%
  filter(pais == "Canadá", anio == 2023) %>%
  filter(grepl("sindicato", descripcion_sub_categoria)) %>%
  select(sub_categoria)

# # A tibble: 1 × 1
#   sub_categoria
#   <chr>        
# 1 E3

puntaje_pais %>%
  filter(sub_categoria == "E3") %>%
  distinct(descripcion_sub_categoria)

# # A tibble: 1 × 1
#   descripcion_sub_categoria                                                     
#   <chr>                                                                         
# 1 ¿Existe libertad para los sindicatos y organizaciones profesionales o laboral…

# Get the justification for the score on sub item E3
texto_calificacion_pais %>%
  filter(
    iso3c == "CAN",
    anio == 2023,
    sub_categoria == "E3"
  ) %>%
  pull(detalle)

# [1] Los sindicatos y las asociaciones empresariales gozan de un alto nivel de afiliación y están bien organizados.
# 27269 Levels: La calificación de derechos políticos de Afganistán mejoró de 6 a 5 debido a una mayor actividad política de la oposición antes de las elecciones programadas, así como a modestos avances en la transparencia del gobierno. ...
```

## Development

To verify the changes made to the package, run the following commands:

``` r
devtools::document()
attachment::att_amend_desc()
devtools::check()
```
