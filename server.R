library(shiny)
library(leaflet)
library(baidumap)
library(rjson)

server <- shinyServer(function(input, output) {
  
  ## acquire the coordinate from rjson file
  getcoord <- function(x){## x is a name of some place
    x <- fromJSON(getCoordinate(x))
    return(x)
  }
  
  ## output leaflet map to the id:map
  output$map <- renderLeaflet({
    m <- leaflet()
    m <- m%>%addTiles()
    
    if(input$selected == 'Loc'){
      temp <- getcoord(input$Loc)
      if(temp$status!=0){
        output$Request <- renderText({
          c('The location failed to be found')
        })
        m
      }else{
        output$Request <- renderText({
          c('The location is found successfully')
        })
        m %>% addMarkers(lng=temp$result$location$lng,
                         lat=temp$result$location$lat,
                         popup = paste0(input$Loc,'--',temp$result$level))
      }
    }else{
      temp1 <- getcoord(input$Start)
      temp2 <- getcoord(input$End)
      if(temp1$status==0&temp2$status==0){
        output$Request <- renderText({
          c('Both start point and end point are valid')
        })
        route <- getRoute(input$Start,input$End)
        m%>%addPolylines(route$lon,route$lat)%>%
          addMarkers(lng=route$lon[c(1,nrow(route))],
                     lat=route$lat[c(1,nrow(route))],
                     popup = c(paste0(input$Start,'--',temp1$result$level),
                               paste0(input$End,'--',temp2$result$level)))
      }else{
        output$Request <- renderText({
          c('One or both of origin and destination is invalid')
        })
      }
    }
  })
})