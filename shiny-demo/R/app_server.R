#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @import d3po
#' @importFrom rlang sym
#' @importFrom stringr str_to_lower str_replace_all
#' @importFrom dplyr filter mutate left_join group_by summarise dense_rank ungroup
#' @importFrom tidyr pivot_longer
#' @noRd
app_server <- function(input, output, session) {
  selected_country <- reactive({
    input$country
  })

  selected_year <- reactive({
    input$year
  })

  selected_item <- reactive({
    input$item
  })

  country_tbl <- reactive({    
    daux <- freedomhouse::country_rating_status %>%
      filter(
        !!sym("year") %in% seq(selected_year()[1], selected_year()[2]),
        !!sym("country") == selected_country()
      )

    # print(daux)

    return(daux)
  })

  output$pr_plot <- render_d3po({
    d3po(country_tbl()) %>%
      po_line(
        daes(
          x = !!sym("year"),
          y = !!sym("political_rights"),
          group = !!sym("status"),
          color = !!sym("color")
        )
      ) %>%
      po_title(paste("Political Rights Ranking for", selected_country()))
  })

  output$cl_plot <- render_d3po({
    d3po(country_tbl()) %>%
      po_line(
        daes(
          x = !!sym("year"),
          y = !!sym("civil_liberties"),
          group = !!sym("status"),
          color = !!sym("color")
        )
      ) %>%
      po_title(paste("Civil Liberties Ranking for", selected_country()))
  })
}
