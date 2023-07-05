
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
  select(year, iso3c, sub_item, score, detail)
#> # A tibble: 6 × 5
#>    year iso3c sub_item score detail                                             
#>   <int> <fct> <chr>    <int> <chr>                                              
#> 1  2022 CAN   E3           4 Trade unions and business associations enjoy high …
#> 2  2021 CAN   E3           4 Trade unions and business associations enjoy high …
#> 3  2020 CAN   E3           4 Trade unions and business associations enjoy high …
#> 4  2019 CAN   E3           4 Trade unions and business associations enjoy high …
#> 5  2018 CAN   E3           4 Trade unions and business associations enjoy high …
#> 6  2017 CAN   E3           4 Trade unions and business associations enjoy high …
```

## Translations

### Spanish

## Traducciones

Las traducciones disponibles dentro de `casadelalibertad` son las
siguientes:

| Nombre | Titulo | Dataset |
| :----- | :----- | :------ |

El paquete `casadelalibertad` se carga igual que todos los paquetes de
R:

``` r
library(casadelalibertad)
library(dplyr)
```

Las variables que contienen los datos van a estar disponibles
inmediatamente para su uso, pero los datos no se traducirán hasta que la
variable sea “llamada” explícitamente en el código que se escriba. En
este ejemplo, el *dataset* `puntajes_por_categoria`, que proviene de
`freedomhouse::category_scores`, se carga en la memoria de R en el
momento en que lo llamamos por primera vez en español:

``` r
glimpse(puntajes_por_categoria)
#> Rows: 57,625
#> Columns: 8
#> $ anio            <int> 2022, 2022, 2022, 2022, 2022, 2022, 2022, 2022, 2022, …
#> $ pais_territorio <fct> Abjasia, Abjasia, Abjasia, Abjasia, Abjasia, Abjasia, …
#> $ iso2c           <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ iso3c           <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ continente      <fct> Asia, Asia, Asia, Asia, Asia, Asia, Asia, Asia, Asia, …
#> $ item            <fct> A, A, A, B, B, B, B, C, C, C, D, D, D, D, E, E, E, F, …
#> $ sub_item        <fct> A1, A2, A3, B1, B2, B3, B4, C1, C2, C3, D1, D2, D3, D4…
#> $ puntaje         <int> 2, 2, 1, 2, 3, 2, 1, 1, 1, 2, 2, 2, 1, 3, 3, 1, 1, 1, …
```

Los datos traducidos quedarán cargados durante toda la sesión de R:

``` r
puntajes_por_categoria %>%
  filter(pais_territorio == "Canad\u00e1")
#> # A tibble: 275 × 8
#>     anio pais_territorio iso2c iso3c continente   item  sub_item puntaje
#>    <int> <fct>           <fct> <fct> <fct>        <fct> <fct>      <int>
#>  1  2022 Canadá          CA    CAN   Las Américas A     A1             4
#>  2  2022 Canadá          CA    CAN   Las Américas A     A2             4
#>  3  2022 Canadá          CA    CAN   Las Américas A     A3             4
#>  4  2022 Canadá          CA    CAN   Las Américas B     B1             4
#>  5  2022 Canadá          CA    CAN   Las Américas B     B2             4
#>  6  2022 Canadá          CA    CAN   Las Américas B     B3             4
#>  7  2022 Canadá          CA    CAN   Las Américas B     B4             4
#>  8  2022 Canadá          CA    CAN   Las Américas C     C1             4
#>  9  2022 Canadá          CA    CAN   Las Américas C     C2             4
#> 10  2022 Canadá          CA    CAN   Las Américas C     C3             4
#> # ℹ 265 more rows
```

## Development

(This is a note for myself)

1.  Open `translations/es`.

2.  Document:

<!-- end list -->

``` r
devtools::load_all()
writeLines(create_rd("inst/specs/category_scores.yml"),
  "man/puntajes_por_categoria.Rd")
```

3.  Verify:

<!-- end list -->

``` r
attachment::att_amend_desc()
devtools::check()
```

4.  Fix non-ASCII characters:

<!-- end list -->

``` bash
casadelalibertad (main) $ bash dev/fix_non_ascii.sh 
```
