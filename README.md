
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
#> # A tibble: 2,305 × 10
#>     year country_territory iso2c iso3c continent item  sub_item item_description
#>    <int> <fct>             <fct> <fct> <fct>     <fct> <fct>    <fct>           
#>  1  2022 Abkhazia          <NA>  <NA>  Asia      E     E3       Associational a…
#>  2  2022 Afghanistan       AF    AFG   Asia      E     E3       Associational a…
#>  3  2022 Albania           AL    ALB   Europe    E     E3       Associational a…
#>  4  2022 Algeria           DZ    DZA   Africa    E     E3       Associational a…
#>  5  2022 Andorra           AD    AND   Europe    E     E3       Associational a…
#>  6  2022 Angola            AO    AGO   Africa    E     E3       Associational a…
#>  7  2022 Antigua and Barb… AG    ATG   Americas  E     E3       Associational a…
#>  8  2022 Argentina         AR    ARG   Americas  E     E3       Associational a…
#>  9  2022 Armenia           AM    ARM   Asia      E     E3       Associational a…
#> 10  2022 Australia         AU    AUS   Oceania   E     E3       Associational a…
#> # ℹ 2,295 more rows
#> # ℹ 2 more variables: sub_item_description <fct>, score <int>

# Get the full description of the sub-item
country_scores %>%
  filter(sub_item == "E3") %>%
  distinct(sub_item_description) %>%
  pull(sub_item_description)
#> [1] Is there freedom for trade unions and similar professional or labor organizations?
#> 25 Levels: Are individuals able to exercise the right to own property and establish private businesses without undue interference from state or nonstate actors? ...

# Filter by sub-item code and country code for trade unions in Canada
country_scores %>%
  filter(
    sub_item == "E3",
    iso3c == "CAN"
  )  %>%
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
este ejemplo, el *dataset* `puntajes_pais`, que proviene de
`freedomhouse::country_scores`, se carga en la memoria de R en el
momento en que lo llamamos por primera vez en español:

``` r
glimpse(puntaje_pais)
#> Rows: 57,625
#> Columns: 10
#> $ anio                      <int> 2022, 2022, 2022, 2022, 2022, 2022, 2022, 20…
#> $ pais_territorio           <fct> Abjasia, Abjasia, Abjasia, Abjasia, Abjasia,…
#> $ iso2c                     <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ iso3c                     <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ continente                <fct> Asia, Asia, Asia, Asia, Asia, Asia, Asia, As…
#> $ categoria                 <fct> A, A, A, B, B, B, B, C, C, C, D, D, D, D, E,…
#> $ sub_categoria             <fct> A1, A2, A3, B1, B2, B3, B4, C1, C2, C3, D1, …
#> $ descripcion_categoria     <fct> Derechos políticos, Derechos políticos, Dere…
#> $ descripcion_sub_categoria <fct> "¿Fue el actual jefe de gobierno u otra auto…
#> $ puntaje                   <int> 2, 2, 1, 2, 3, 2, 1, 1, 1, 2, 2, 2, 1, 3, 3,…
```

Los datos traducidos quedarán cargados durante toda la sesión de R:

``` r
puntaje_pais %>%
  filter(pais_territorio == "Canad\u00e1")
#> # A tibble: 275 × 10
#>     anio pais_territorio iso2c iso3c continente   categoria sub_categoria
#>    <int> <fct>           <fct> <fct> <fct>        <fct>     <fct>        
#>  1  2022 Canadá          CA    CAN   Las Américas A         A1           
#>  2  2022 Canadá          CA    CAN   Las Américas A         A2           
#>  3  2022 Canadá          CA    CAN   Las Américas A         A3           
#>  4  2022 Canadá          CA    CAN   Las Américas B         B1           
#>  5  2022 Canadá          CA    CAN   Las Américas B         B2           
#>  6  2022 Canadá          CA    CAN   Las Américas B         B3           
#>  7  2022 Canadá          CA    CAN   Las Américas B         B4           
#>  8  2022 Canadá          CA    CAN   Las Américas C         C1           
#>  9  2022 Canadá          CA    CAN   Las Américas C         C2           
#> 10  2022 Canadá          CA    CAN   Las Américas C         C3           
#> # ℹ 265 more rows
#> # ℹ 3 more variables: descripcion_categoria <fct>,
#> #   descripcion_sub_categoria <fct>, puntaje <int>

puntaje_pais %>%
  filter(pais_territorio == "Canadá")
#> # A tibble: 275 × 10
#>     anio pais_territorio iso2c iso3c continente   categoria sub_categoria
#>    <int> <fct>           <fct> <fct> <fct>        <fct>     <fct>        
#>  1  2022 Canadá          CA    CAN   Las Américas A         A1           
#>  2  2022 Canadá          CA    CAN   Las Américas A         A2           
#>  3  2022 Canadá          CA    CAN   Las Américas A         A3           
#>  4  2022 Canadá          CA    CAN   Las Américas B         B1           
#>  5  2022 Canadá          CA    CAN   Las Américas B         B2           
#>  6  2022 Canadá          CA    CAN   Las Américas B         B3           
#>  7  2022 Canadá          CA    CAN   Las Américas B         B4           
#>  8  2022 Canadá          CA    CAN   Las Américas C         C1           
#>  9  2022 Canadá          CA    CAN   Las Américas C         C2           
#> 10  2022 Canadá          CA    CAN   Las Américas C         C3           
#> # ℹ 265 more rows
#> # ℹ 3 more variables: descripcion_categoria <fct>,
#> #   descripcion_sub_categoria <fct>, puntaje <int>
```

## Development

(This is a note for myself)

1.  Open `translations/es`.

2.  Document:

<!-- end list -->

``` r
devtools::load_all()
writeLines(create_rd("inst/specs/country_scores.yml"),
  "man/puntaje_pais.Rd")
writeLines(create_rd("inst/specs/country_rating_statuses.yml"),
  "man/estado_calificacion_pais.Rd")
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

5.  Update site:

<!-- end list -->

``` r
unlink("docs", recursive = TRUE)
altdoc::use_mkdocs(theme = "readthedocs")
```
