library(shiny)
library(shinydashboard)
library(leaflet)
library(rgdal)
library(utf8)
library(rgeos)
library(shinyjs)
library(sp)
library(V8)
library(shinyalert)
library(leaflet.extras)
library(raster)

jsResetCode <- "shinyjs.reset = function() {history.go(0)}"


shinyUI(
  dashboardPage(
    dashboardHeader(title ="Sen2extract"),
    sidebar <- dashboardSidebar(
      sidebarMenu(
        hr(),
        menuItem("Map", tabName= "carte", icon = icon("globe")),
        hr(),
        menuItem("About", tabName = "about", icon = icon("list-alt")),
        menuItem("F.A.Q", tabName = "faq", icon = icon("question-sign",lib= "glyphicon"))
      )
    ),

    dashboardBody(
      tabItems(
        tabItem(tabName ="carte",
                fluidRow(
                  box(
                    width = 3,
                    title = "Settings",
                    status = "primary",
                    solidHeader = TRUE,
                    collapsible = TRUE,
                    useShinyalert(),
                    fileInput(inputId = "zip", label = "Upload your file (.zip) :", multiple = FALSE, accept = c('.zip')),
                    checkboxGroupInput(inputId ="indice", label ="Choose a spectral index (multiple choice possible) :", choices = c("NDVI", "NDWIGAO", "NDWIMCF", "MNDWI")),
                    br(),
                    dateRangeInput(inputId ="dates", label = "Select the date range :", start = "", end = ""), br(),br(),
                    useShinyjs(),
                    extendShinyjs(text = jsResetCode),
                    div(style = "display:inline-block", actionButton("reset_button", "Refresh", icon("refresh", lib ="glyphicon"))),
                    div(style = "display:inline-block", actionButton("send", "Send now !", icon("send", lib = "glyphicon"), style = "background-color : #000000 ; color : #fff ; border-color : #717878"))                 
                  ),

                  box(
                    width = 9,
                    title = "Map",
                    status = "primary",
                    solidHeader = TRUE,
                    collapsible = FALSE,
                    # width = 500,
                    height = 1000,
                    leafletOutput(outputId = "map", width="100%", height = 940)
                  )
                )
        ),
        tabItem(tabName ="about",h1("Bienvenue sur l'application sen2extract !"),
                p("Cet outils permet l'extraction de series temporelles des indices spectraux sur differents sites d'etudes.")),
        
        tabItem(tabName ="faq", h1("F.A.Q"), h3("Mon shape ne s'importe pas, comment faire ?"),
                p("Referez-vous aux indications de l'onglet Description"),
                h3("L'extraction de ma serie temporelle est anormalement longue, est-ce normal ?"),
                p("Il est possible que l'extraction prenne du temps. Cela va dependre du nombre de polygones en entree, ainsi que de la plage temporelle configuree"))
      )
    )
  )
)
