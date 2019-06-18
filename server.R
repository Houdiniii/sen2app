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

shinyServer(function(input, output, session){
  



##########################  ADD THE MAP  #############################
  
  output$map <- renderLeaflet({
    
    leaflet() %>%
      enableTileCaching() %>%
      addProviderTiles("Esri.WorldImagery", group = "Esri World Imagery", options = providerTileOptions(minZoom = 2, maxZoom = 17), tileOptions(useCache = TRUE, crossOrigin = TRUE)) %>%
      addTiles(group = "OSM", urlTemplate = "https://{s}.tile.openstreetmap.de/tiles/osmde/{z}/{x}/{y}.png", attribution = '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors', options = providerTileOptions(minZoom = 2, maxZoom = 17), tileOptions(useCache = TRUE, crossOrigin = TRUE)) %>%
      addMiniMap(toggleDisplay = T) %>%
      addScaleBar(position = 'bottomleft') %>%
      setView(lng = 97.963,lat = 20.380, zoom = 6 ) %>%
      addLayersControl(baseGroups = c("Esri World Imagery", "OSM"))
  })

  
########################## READ SHAPEFILE #############################
  
  uploadShpfile <- reactive({
    if (!is.null(input$zip)) {
      inFile <- input$zip
      inFolder <- substr(inFile$datapath, 1, nchar(inFile$datapath) - 5)
      unzip(inFile$datapath, exdir = inFolder)
      shpDF <- input$zip
      pwd <- getwd()
      updir <- dirname(shpDF$datapath[1])
      setwd(updir)
      for (i in 1:nrow(shpDF)) {
        file.rename(shpDF$datapath[i], shpDF$name[i])
      }
      shpName <- shpDF$name[grep(x = shpDF$name, pattern = "*.shp")]
      shpPath <- paste(updir, shpName, sep = "/")
      setwd(pwd)
      shpFile <- readOGR(shpPath)
      shpFile <- spTransform(shpFile,CRS("+proj=longlat +datum=WGS84"))
      # shapefile(shpFile, tempfile(pattern = "", fileext = ".shp"))
    }
  })


  

##########################  ADD SHAPEFILE  ############################
  
  observeEvent(input$zip, {
    
    data = uploadShpfile()
    # shapefile(data, tempfile(pattern = "", tmpdir = "/tmp/temp_shp/", fileext = ".shp"))
    map = leafletProxy("map")
    if (!is.null(uploadShpfile())){
      if(inherits(data, "SpatialPolygons")){
        shinyalert("Successful upload !", type = "success")
        cent <- gCentroid(spgeom = uploadShpfile(), byid = FALSE)
        leafletProxy("map")%>%
          addPolygons(data = uploadShpfile(),
              stroke = TRUE,
              # color = "#00FFEC",
              # fillColor = "white",
              fillOpacity = 0.5)
        
      }
      
      if(inherits(data, "SpatialPoints")){
        shinyalert("Successful upload !", type = "success")
        cent <- gCentroid(spgeom = uploadShpfile(), byid = FALSE)
        leafletProxy("map") %>%
          addCircleMarkers(data = uploadShpfile(),
              stroke = TRUE,
              # color = "white",
              # fillColor = "#00FFEC",
              radius = 6,
              fillOpacity = 0.9)
        }
    }
  })
  
  
############################  OUTPUT  ################################
  
##########################  SEND BUTTON  #############################
  
##########################  RESET BUTTON  ############################
  
  observeEvent(input$reset_button, {
    js$reset()
  })
})
