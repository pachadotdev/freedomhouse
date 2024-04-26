
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

Another addition of mine was is to add translations.

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

El *dataset* `puntaje_pais` es una traducción del original
`country_scores`:

``` r
> glimpse(puntaje_pais)
Rows: 62,875
Columns: 10
$ anio                      <int> 2012, 2012, 2012, 2012, 2012, 2012, 2012, 20…
$ pais                      <chr> "Abjasia", "Abjasia", "Abjasia", "Abjasia", …
$ iso2c                     <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
$ iso3c                     <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
$ continente                <chr> "Asia", "Asia", "Asia", "Asia", "Asia", "Asi…
$ categoria                 <fct> A, A, A, B, B, B, B, C, C, C, D, D, D, D, E,…
$ sub_categoria             <fct> A1, A2, A3, B1, B2, B3, B4, C1, C2, C3, D1, …
$ descripcion_categoria     <chr> "Derechos políticos", "Derechos políticos", …
$ descripcion_sub_categoria <chr> "¿Fue el actual jefe de gobierno u otra auto…
$ puntaje                   <int> 3, 2, 2, 2, 2, 2, 1, 1, 1, 2, 2, 2, 1, 3, 2,…
```

``` r
> puntaje_pais %>%
  filter(pais == "Canad\u00e1")
# A tibble: 300 × 10
    anio pais   iso2c iso3c continente   categoria sub_categoria
   <int> <chr>  <fct> <fct> <chr>        <fct>     <fct>        
 1  2012 Canadá CA    CAN   Las Américas A         A1           
 2  2012 Canadá CA    CAN   Las Américas A         A2           
 3  2012 Canadá CA    CAN   Las Américas A         A3           
 4  2012 Canadá CA    CAN   Las Américas B         B1           
 5  2012 Canadá CA    CAN   Las Américas B         B2           
 6  2012 Canadá CA    CAN   Las Américas B         B3           
 7  2012 Canadá CA    CAN   Las Américas B         B4           
 8  2012 Canadá CA    CAN   Las Américas C         C1           
 9  2012 Canadá CA    CAN   Las Américas C         C2           
10  2012 Canadá CA    CAN   Las Américas C         C3           
# ℹ 290 more rows
# ℹ 3 more variables: descripcion_categoria <chr>,
#   descripcion_sub_categoria <chr>, puntaje <int>
# ℹ Use `print(n = ...)` to see more rows
```

``` r
> puntaje_pais %>%
  filter(pais == "Canadá")
# A tibble: 300 × 10
    anio pais   iso2c iso3c continente   categoria sub_categoria
   <int> <chr>  <fct> <fct> <chr>        <fct>     <fct>        
 1  2012 Canadá CA    CAN   Las Américas A         A1           
 2  2012 Canadá CA    CAN   Las Américas A         A2           
 3  2012 Canadá CA    CAN   Las Américas A         A3           
 4  2012 Canadá CA    CAN   Las Américas B         B1           
 5  2012 Canadá CA    CAN   Las Américas B         B2           
 6  2012 Canadá CA    CAN   Las Américas B         B3           
 7  2012 Canadá CA    CAN   Las Américas B         B4           
 8  2012 Canadá CA    CAN   Las Américas C         C1           
 9  2012 Canadá CA    CAN   Las Américas C         C2           
10  2012 Canadá CA    CAN   Las Américas C         C3           
# ℹ 290 more rows
# ℹ 3 more variables: descripcion_categoria <chr>,
#   descripcion_sub_categoria <chr>, puntaje <int>
# ℹ Use `print(n = ...)` to see more rows
```

`texto_calificacion_pais` es una traducción del original
`country_rating_texts`:

``` r
> glimpse(texto_calificacion_pais)
Rows: 29,587
Columns: 7
$ anio          <int> 2017, 2017, 2017, 2017, 2017, 2017, 2017, 2017, 2017, 20…
$ pais          <chr> "Afganistán", "Afganistán", "Afganistán", "Afganistán", …
$ iso2c         <fct> AF, AF, AF, AF, AF, AF, AF, AF, AF, AF, AF, AF, AF, AF, …
$ iso3c         <fct> AFG, AFG, AFG, AFG, AFG, AFG, AFG, AFG, AFG, AFG, AFG, A…
$ continente    <chr> "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", …
$ sub_categoria <fct> Resumen, Desarrollos Clave, Cambio de Calificación, A1, …
$ detalle       <chr> "La constitución de Afganistán prevé un Estado unitario,…
```

`estado_calificacion_pais` es una traducción del original
`country_rating_status`:

``` r
> glimpse(estado_calificacion_pais)
Rows: 9,238
Columns: 9
$ anio               <int> 1972, 1973, 1974, 1975, 1976, 1977, 1978, 1979, 198…
$ pais               <chr> "Afganistán", "Afganistán", "Afganistán", "Afganist…
$ iso2c              <fct> AF, AF, AF, AF, AF, AF, AF, AF, AF, AF, AF, AF, AF,…
$ iso3c              <fct> AFG, AFG, AFG, AFG, AFG, AFG, AFG, AFG, AFG, AFG, A…
$ continente         <chr> "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "As…
$ derechos_politicos <int> 4, 7, 7, 7, 7, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 6, 7, …
$ libertades_civiles <int> 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 6, 7, …
$ estado             <chr> "Parcialmente Libre", "No Libre", "No Libre", "No L…
$ color              <fct> #a1aafc, #7454a6, #7454a6, #7454a6, #7454a6, #7454a…
```

## Development

To verify the changes made to the package, run the following commands:

``` r
devtools::document()
attachment::att_amend_desc()
devtools::check()
```
