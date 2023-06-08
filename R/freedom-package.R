#' Civil Liberties and Political Rights Ratings, 1972-2022
#'
#' For each country and territory, Freedom in the World analyzes the electoral process,
#' political pluralism and participation, the functioning of the government, freedom of
#' expression and of belief, associational and organizational rights, the rule of law, 
#' and personal autonomy and individual rights.
#'
#' @section Variables:
#'
#' \itemize{
#'  \item \code{year}: Year of observation (1972-2022). The survey is applied the year after.
#'  \item \code{country}: Country name.
#'  \item \code{iso2c}: ISO 2-character country code. Czechoslovakia, Kosovo, Micronesia,
#'   Serbia and Montenegro, and Yugoslavia do not have unambiguous matches and appear as 'NA'.
#'  \item \code{iso3c}: ISO 3-character country code. Czechoslovakia, Kosovo, Micronesia,
#'   Serbia and Montenegro, and Yugoslavia do not have unambiguous matches and appear as 'NA'.
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
#' @name country_rating_statuses
#' @usage country_rating_statuses
#' @format A \code{data frame} with 9,043 observations and 9 variables.
#' @source Adapted from Freedom House.
"country_rating_statuses"

#' Trade Network Coloured by Freedom Status
#'
#' Connections between countries correspond to the strongest arcs based on the products they export.
#' The network was trimmed until obtaining an average of four arcs per node. This network was
#' obtained by using UN COMTRADE data for exports, using reports from importing countries.
#'
#' @docType data
#' @name country_exports_similarity
#' @usage country_exports_similarity
#' @format A \code{igraph} object with 190 vertices (nodes) and 316 edges (arcs).
#' @source Adapted from the United Nations (trade volumes) and Freedom House (freedom information).
"country_exports_similarity"

#' Freedom in the World Dissaggregated Scores, 2012-2022
#' 
#' Adding to the \code{country_rating_statuses} table, the items displayed here can be summed up
#' to obtain the \code{political_rights} aggregate score (sum of items A to C) and 
#' \code{civil_liberties} aggregate score (items D to G). The sub-items are scored from 0 to 4, 
#' with 0 representing the lowest degree of achievement in a given category and 4 the highest.
#' For example, a country that sums 36 or more points in the political rights aggregate score 
#' obtains a political rights rating of 1, from 30 to 35 points a rating of 2, and so on.
#' 
#' @section Variables:
#' 
#' \itemize{
#'  \item \code{year}: Year of observation (2012-2022).
#'  \item \code{country_territory}: Country or territory name.
#'  \item \code{iso2c}: ISO 2-character country code. Abkhazia, Crimea, Eastern Donbas, Kosovo, 
#'   Micronesia, Nagorno-Karabakh, Somaliland, South Ossetia, Tibet, Transnistria do not have
#'   unambiguous matches and appear as 'NA'.
#'  \item \code{iso3c}: ISO 3-character country code. Abkhazia, Crimea, Eastern Donbas, Kosovo, 
#'   Micronesia, Nagorno-Karabakh, Somaliland, South Ossetia, Tibet, Transnistria do not have
#'   unambiguous matches and appear as 'NA'.
#'  \item \code{continent}: Continent name.
#'  \item \code{item}: Item letter (A-G).
#'  \item \code{sub_item}: Sub-item letter and number (A1-G4).
#'  \item \code{score}: Score for the sub-item (0-4).
#' }
#' 
#' @docType data
#' @name category_scores
#' @usage category_scores
#' @format A \code{data frame} with 62,235 observations and 8 variables.
#' @source Adapted from Freedom House.
"category_scores"

#' Freedom in the World Items and Sub-Items Description, 2012-2022
#' 
#' @section Variables:
#' 
#' Provides a full description for the meaning of each item and sub-item in the
#' \code{category_scores} table. For example, item A corresponds to Political Rights.
#' 
#' \itemize{
#'  \item \code{item}: Item letter (A-G).
#'  \item \code{sub_item}: Sub-item letter and number (A1-G4).
#'  \item \code{item_description}: Description of the item.
#'  \item \code{sub_item_description}: Description of the sub-item.
#' }
#' 
#' @docType data
#' @name category_scores_items
#' @usage category_scores_items
#' @format A \code{data frame} with 25 observations and 4 variables.
#' @source Adapted from Freedom House.
"category_scores_items"
