#' Civil Liberties and Political Rights Ratings, 1972-2023
#'
#' For each country and territory, Freedom in the World analyzes the electoral process,
#' political pluralism and participation, the functioning of the government, freedom of
#' expression and of belief, associational and organizational rights, the rule of law,
#' and personal autonomy and individual rights.
#'
#' @section Variables:
#'
#' \itemize{
#'  \item \code{year}: Year of observation (1972-2023). The survey is applied the year after.
#'  \item \code{country}: Country name.
#'  \item \code{iso2c}: ISO 2-character country code. Czechoslovakia, Kosovo, Micronesia,
#'   Serbia and Montenegro, and Yugoslavia do not have unambiguous matches and appear as 'NA'.
#'  \item \code{iso3c}: ISO 3-character country code. Same criteria for 'NA' as in \code{iso2c}.
#'  \item \code{continent}: Continent name.
#'  \item \code{year}: Year of observation (1973-2023).
#'  \item \code{political_rights}: Political rights rating (1-7 scale, with one representing the
#'   highest degree of Freedom and seven the lowest).
#'  \item \code{civil_liberties}: Civil liberties rating (1-7 scale, with one representing the
#'   highest degree of Freedom and seven the lowest).
#'  \item \code{status}: Status of the country (Free, Partly Free, Not Free).
#'  \item \code{color}: Color associated with the status of the country.
#' }
#'
#' @docType data
#' @name country_rating_status
#' @usage country_rating_status
#' @format A \code{data frame} with 9,238 observations and 9 variables.
#' @source Adapted from Freedom House.
#' @references Freedom House. 2024. Freedom in the World 2024: The Mounting Damage of Flawed Elections and Armed Conflict.
#' Washington, DC: Freedom House. https://freedomhouse.org/report/freedom-world/2024/mounting-damage-flawed-elections-and-armed-conflict.
#' Accessed 2024-04-25.
"country_rating_status"

#' Freedom in the World Dissaggregated Scores, 2012-2023
#'
#' Adding to the \code{country_rating_statuses} table, the items displayed here can be summed up
#' to obtain the \code{political_rights} aggregate score (sum of items A to C) and
#' \code{civil_liberties} aggregate score (items D to G). The sub-items are scored from 0 to 4,
#' with 0 representing the lowest degree of achievement in a given category and 4 the highest.
#' For example, a country with 36 or more points in the political rights aggregate score
#' obtains a political rights rating of 1, from 30 to 35 points a rating of 2, and so on.
#'
#' @section Variables:
#'
#' \itemize{
#'  \item \code{year}: Year of observation (2012-2023).
#'  \item \code{country}: Country (or territory) name.
#'  \item \code{iso2c}: ISO 2-character country code. Abkhazia, Crimea, Eastern Donbas, Kosovo,
#'   Micronesia, Nagorno-Karabakh, Somaliland, South Ossetia, Tibet, Transnistria do not have
#'   unambiguous matches and appear as 'NA'.
#'  \item \code{iso3c}: ISO 3-character country code. Same criteria for 'NA' as in \code{iso2c}.
#'  \item \code{continent}: Continent name.
#'  \item \code{item}: Item letter (A-G).
#'  \item \code{sub_item}: Sub-item letter and number (A1-G4).
#'  \item \code{item_description}: Description of the item.
#'  \item \code{sub_item_description}: Description of the sub-item.
#'  \item \code{score}: Score for the sub-item (0-4).
#' }
#'
#' @docType data
#' @name country_score
#' @usage country_score
#' @format A \code{data frame} with 62,875 observations and 10 variables.
#' @source Adapted from Freedom House.
"country_score"

#' Freedom in the World Sub-Items Texts, 2017-2023
#'
#' Provides the text for each sub-item in the \code{country_scores} table. For each
#' sub-item the text corresponds to the justification for the assigned score.
#'
#' @section Variables:
#'
#' \itemize{
#'  \item \code{year}: Year of observation (2017-2023).
#'  \item \code{country}: Country name.
#'  \item \code{iso2c}: ISO 2-character country code. Abkhazia, Crimea, Eastern Donbas, Kosovo,
#'  Micronesia, Nagorno-Karabakh, Somaliland, South Ossetia, Tibet, Transnistria do not have
#'  unambiguous matches and appear as 'NA'.
#'  \item \code{iso3c}: ISO 3-character country code. Abkhazia, Crimea, Eastern Donbas, Kosovo,
#'  Micronesia, Nagorno-Karabakh, Somaliland, South Ossetia, Tibet, Transnistria do not have
#'  unambiguous matches and appear as 'NA'.
#'  \item \code{continent}: Continent name.
#'  \item \code{item}: Item letter (A-G).
#'  \item \code{sub_item}: Sub-item letter and number (A1-G4) besides 'Overview', 'Key Developments'
#'  'Rating Change', 'Trend Arrow', and 'Notes'.
#'  \item \code{item_description}: Description of the item.
#'  \item \code{sub_item_description}: Description of the sub-item.
#'  \item \code{detail}: Details and justification for the assigned score in the sub-item.
#' }
#'
#' @docType data
#' @name country_rating_text
#' @usage country_rating_text
#' @format A \code{data frame} with 33,601 observations and 10 variables.
#' @source Own creation, based on texts scraped from Freedom House.
#' @references Freedom House. 2023. Freedom in the World 2023: Marking 50 Years in the Struggle for Democracy.
#' Washington, DC: Freedom House. https://freedomhouse.org/report/freedom-world/2023/marking-50-years.
#' Accessed 2024-04-25.
"country_rating_text"
