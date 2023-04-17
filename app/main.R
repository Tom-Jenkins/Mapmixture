# app/main.R

# Import R packages / functions into module
box::use(
  shiny[moduleServer, NS, tags, fluidPage, fluidRow, span, h1, h2, h3, h4, strong, icon, p, a, sidebarLayout, sidebarPanel, mainPanel, fileInput, tabsetPanel, tabPanel, div, actionButton, splitLayout, br, renderTable, tableOutput, req, callModule, reactive, column, plotOutput, uiOutput],
  bslib[bs_theme],
  sf[st_read],
)

# Import modules
box::use(
  app/view/file_upload,
  app/view/info_modals_module,
  app/view/plot_bttn_module,
  app/view/map_params_module,
  app/view/map_plot_module,
)


# UI COMPONENTS
#' @export
ui <- function(id) {
  ns <- NS(id)
  
  fluidPage(

    # Bootstrap version and bootswatch theme ----
    theme = bs_theme(version = 5, bootswatch = "flatly"),

    # Navbar with title and links ----
    fluidRow(
      style = "background: #18bc9c; color: white; padding: 10px; margin-bottom: 5px;",
      span(
        span(icon("chart-pie", style = "margin-right: 5px;"), strong("Mapmixture v0.1")),
        a(
          style = "color: white;",
          href = "https://twitter.com/tom__jenkins",
          target = "_blank",
          span(style = "float: right;", icon("twitter", style = "margin-right: 5px;"), "Twitter"),
        ),        
        a(
          style = "color: white;",
          href = "https://github.com/Tom-Jenkins",
          target = "_blank",
          span(style = "float: right; margin-right: 20px;", icon("github", style = "margin-right: 5px;"), "GitHub")),
      ),
    ),
    # Sidebar layout with inputs (left) and outputs (right) ----
    sidebarLayout(

      # Sidebar panel for inputs ----
      sidebarPanel(

        # File upload UI module ----
        file_upload$ui(ns("file_upload")),

        # Plot button UI module ----
        plot_bttn_module$ui(ns("plot_bttn_module")),

        # Tab panel for map and bar chart input parameters ----
        div(class = "nav-justified",
          tabsetPanel(
            type = "pills",
            tabPanel(
              style = "height: 530px; overflow-y: scroll; padding-left: 5px; padding-right: 20px; padding-top: 10px; margin-top: 10px;",
              title = "Map Options",
              map_params_module$ui(ns("map_params_module")),
            ),
            # tabPanel(
            #   class = "nav-fill",
            #   title = "Bar Chart Options",
            # ),
          ),
        ),
      ),

      # Main panel for displaying outputs ----
      mainPanel(
        tabsetPanel(
          tabPanel(
            title = "Admixture Map",
            icon = icon("earth-europe"),
            # fluidRow(
            #   column(6, tableOutput(ns("admixture_table"))),
            #   column(6, tableOutput(ns("coords_table"))),
            # ),
            map_plot_module$ui(ns("map_plot_module")),
          ),
          # tabPanel(
          #   title = "Bar Chart",
          #   icon = icon("chart-simple"),
          # ),
          tabPanel(
            title = "FAQs",
            icon = icon("circle-question"),
            #TBC
          ),
        )
      )
    )
  )
}


# SERVER COMPONENTS
#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    # Load static data ----
    world_data <- st_read("./app/static/data/world.gpkg")

    # Import data from file upload module ----
    admixture_data <- file_upload$server("file_upload")[["admixture_data"]]
    coords_data <- file_upload$server("file_upload")[["coords_data"]]

    # Capture button click events ----
    admixture_info_bttn <- file_upload$server("file_upload")[["admixture_info_bttn"]]
    coords_info_bttn <- file_upload$server("file_upload")[["coords_info_bttn"]]
    plot_bttn <- plot_bttn_module$server("plot_bttn_module", admixture_df = admixture_data)[["plot_bttn"]]

    # Information modals module ----
    info_modals_module$server("info_modals_module", admixture_info_bttn, coords_info_bttn)

    # Map parameters module ----
    map_params_module$server("map_params_module", admixture_df = admixture_data)

    # Import map parameters ----
    selected_CRS <- map_params_module$server("map_params_module", admixture_df = admixture_data)[["params_CRS"]]
    selected_bbox <- map_params_module$server("map_params_module", admixture_df = admixture_data)[["params_bbox"]]
    selected_expand <- map_params_module$server("map_params_module", admixture_df = admixture_data)[["param_expand"]]
    selected_cols <- map_params_module$server("map_params_module", admixture_df = admixture_data)[["param_cols"]]
    selected_clusters <- map_params_module$server("map_params_module", admixture_df = admixture_data)[["params_clusters"]]
    selected_pie_size <- map_params_module$server("map_params_module", admixture_df = admixture_data)[["param_pie_size"]]
    selected_title <- map_params_module$server("map_params_module", admixture_df = admixture_data)[["param_title"]]
    selected_land_col <- map_params_module$server("map_params_module", admixture_df = admixture_data)[["param_land_col"]]
    selected_map_theme <- map_params_module$server("map_params_module", admixture_df = admixture_data)[["param_map_theme"]]
    selected_advanced <- map_params_module$server("map_params_module", admixture_df = admixture_data)[["param_advanced"]]

    # Map plot module ----
    map_plot_module$server(
      "map_plot_module",
      bttn = plot_bttn,
      admixture_df = admixture_data,
      coords_df = coords_data,
      world_data = world_data,
      user_CRS = selected_CRS,
      user_bbox = selected_bbox,
      user_expand = selected_expand,
      user_title = selected_title,
      cluster_cols = selected_cols,
      cluster_names = selected_clusters,
      user_land_col = selected_land_col,
      pie_size = selected_pie_size,
      map_theme = selected_map_theme,
      user_advanced = selected_advanced
    )

    # # Render admixture table
    # output$admixture_table <- renderTable({
    #   req(admixture_data())
    #   admixture_data()
    # })

    # # Render coords table
    # output$coords_table <- renderTable({
    #   req(coords_data())
    #   coords_data()
    # })
  })
}