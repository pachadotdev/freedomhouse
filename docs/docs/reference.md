# Reference 

## Country rating statuses
-------------------------------------------------------

### Description

For each country and territory, Freedom in the World analyzes the
electoral process, political pluralism and participation, the
functioning of the government, freedom of expression and of belief,
associational and organizational rights, the rule of law, and personal
autonomy and individual rights.

### Usage

    country_rating_statuses

### Format

A `data frame` with 9,043 observations and 9 variables.

### Variables

-   `year`: Year of observation (1972-2022). The survey is applied the
    year after.

-   `country`: Country name.

-   `iso2c`: ISO 2-character country code. Czechoslovakia, Kosovo,
    Micronesia, Serbia and Montenegro, and Yugoslavia do not have
    unambiguous matches and appear as 'NA'.

-   `iso3c`: ISO 3-character country code. Same criteria for 'NA' as in
    `iso2c`.

-   `continent`: Continent name.

-   `year`: Year of observation (1973-2023).

-   `political_rights`: Political rights rating (1-7 scale, with one
    representing the highest degree of Freedom and seven the lowest).

-   `civil_liberties`: Civil liberties rating (1-7 scale, with one
    representing the highest degree of Freedom and seven the lowest).

-   `status`: Status of the country (Free, Partly Free, Not Free).

-   `color`: Color associated with the status of the country.

### Source

Adapted from Freedom House.

### References

Freedom House. 2023. Freedom in the World 2023: Marking 50 Years in the
Struggle for Democracy. Washington, DC: Freedom House.
https://freedomhouse.org/report/freedom-world/2023/marking-50-years.
Accessed 2022-10-01.


---
## Country rating texts
-----------------------------------------------

### Description

Provides the text for each sub-item in the `country_scores` table. For
each sub-item the text corresponds to the justification for the assigned
score.

### Usage

    country_rating_texts

### Format

A `data frame` with 27,803 observations and 7 variables.

### Variables

-   `year`: Year of observation (2017-2022).

-   `country`: Country name.

-   `iso2c`: ISO 2-character country code. Abkhazia, Crimea, Eastern
    Donbas, Kosovo, Micronesia, Nagorno-Karabakh, Somaliland, South
    Ossetia, Tibet, Transnistria do not have unambiguous matches and
    appear as 'NA'.

-   `iso3c`: ISO 3-character country code. Abkhazia, Crimea, Eastern
    Donbas, Kosovo, Micronesia, Nagorno-Karabakh, Somaliland, South
    Ossetia, Tibet, Transnistria do not have unambiguous matches and
    appear as 'NA'.

-   `continent`: Continent name.

-   `sub_item`: Sub-item letter and number (A1-G4).

-   `detail`: Details and justification for the assigned score in the
    sub-item.

### Source

Own creation, based on texts scraped from Freedom House.

### References

Freedom House. 2023. Freedom in the World 2023: Marking 50 Years in the
Struggle for Democracy. Washington, DC: Freedom House.
https://freedomhouse.org/report/freedom-world/2023/marking-50-years.
Accessed 2022-10-01.


---
## Country scores
-----------------------------------------------------

### Description

Adding to the `country_rating_statuses` table, the items displayed here
can be summed up to obtain the `political_rights` aggregate score (sum
of items A to C) and `civil_liberties` aggregate score (items D to G).
The sub-items are scored from 0 to 4, with 0 representing the lowest
degree of achievement in a given category and 4 the highest. For
example, a country with 36 or more points in the political rights
aggregate score obtains a political rights rating of 1, from 30 to 35
points a rating of 2, and so on.

### Usage

    country_scores

### Format

A `data frame` with 57,625 observations and 8 variables.

### Variables

-   `year`: Year of observation (2012-2022).

-   `country_territory`: Country or territory name.

-   `iso2c`: ISO 2-character country code. Abkhazia, Crimea, Eastern
    Donbas, Kosovo, Micronesia, Nagorno-Karabakh, Somaliland, South
    Ossetia, Tibet, Transnistria do not have unambiguous matches and
    appear as 'NA'.

-   `iso3c`: ISO 3-character country code. Same criteria for 'NA' as in
    `iso2c`.

-   `continent`: Continent name.

-   `item`: Item letter (A-G).

-   `sub_item`: Sub-item letter and number (A1-G4).

-   `item_description`: Description of the item.

-   `sub_item_description`: Description of the sub-item.

-   `score`: Score for the sub-item (0-4).

### Source

Adapted from Freedom House.


---
