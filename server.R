#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(pdfetch)
library(ggplot2)
library(tidyverse)
library(xts)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    ## VALORES DINAMIOCS ##
    # Para el buen funcionamiento de la APP, hay que usar valores dinámicos.
    
    
    # PINICIALIZACION DEL CURSOR
    values<- reactiveValues(
        x_value=as.Date("2017-09-06"),
        y_value=80
    )
    
    ranges <- reactiveValues(x = c(as.Date("2015-09-09"),as.Date("2020-09-09")), y = NULL )
    ranges_or <- reactiveValues(x = c(as.Date("2015-09-09"),as.Date("2020-09-09")), y = NULL )
    
    observeEvent(input$dateRange1, {
        ranges_or$x <-  c(as.Date(input$dateRange1[1]),as.Date(input$dateRange1[2]))
        ranges_or$y <- NULL
        ranges$x <-  c(as.Date(input$dateRange1[1]),as.Date(input$dateRange1[2]))
        ranges$y <- NULL
        }
        )
    
    # INICIALIZACION RANGO FECHAS MAPA
    
   
    # CUROSRES EN FUCNION DEL DBL CLICK
    observeEvent(
        input$plot_dblclick, {
        values$x_value <- input$plot_dblclick$x
        values$y_value <- input$plot_dblclick$y
        }
        
    )
    
    ## ZOOM
    observeEvent(input$plot_click, {
        brush <- input$plot1_brush
        if (!is.null(brush)) {
            ranges$x <- c(as.Date(brush$xmin), as.Date(brush$xmax))
            ranges$y <- c(brush$ymin, brush$ymax)
            
            
        } else {
            ranges$x <- ranges_or$x
            ranges$y <- NULL
        }
    })

    
    
    
    # SHOW del grafico
    output$distPlot <- renderPlot({
        
        # Nombre de la empresa
        empresa = input$empresa1
        # Hacemos una peticion a los datos
        datos <- pdfetch_YAHOO(empresa,
                               fields = c("open", "high", "low", "close", "adjclose", "volume"), from = as.Date(input$dateRange1[1]),
                               to = as.Date(input$dateRange1[2]), interval = "1d")
        
        # Lo transformamos a un DF para poder trabajar bien
        df = data.frame(date=as.Date(index(datos)), datos)
        # Renombramos las columnas dinamicamente para que se escalable
        df=df %>% 
            rename(
                high = paste(empresa,".high",sep=""),
                low = paste(empresa,".low",sep=""),
                close = paste(empresa,".close",sep=""),
                open = paste(empresa,".open",sep=""),
                adjClose = paste(empresa,".adjclose",sep=""),
                volume = paste(empresa,".volume",sep="")
            )
        assign("df_total", df, envir = .GlobalEnv)
        # Creamos los datos para las barras rojas y verdes. Este primer paso solo es el valor
        df$barras = df$high - df$low
        # Ahora si uq ele metemos la variable del color, que depende de si ha cerrado más arriba de lo que ha abierto
        df$color_barra = ifelse(sign(df$close - df$open)>0,"#10a326","#a31710")
        
        if(input$displayLines1)
        {
            HICP <- ggplot() +
                # Pintamos la linea de cierre
                
                geom_segment(data = df,aes(x=date, xend=date, y=low, yend=high), size=0.4, color="black") +
                geom_segment(data = df,aes(x=date, xend=date, y=close, yend=open), size=2, color=df$color_barra) +
                geom_line(data = df, aes(x=date, y = close), size = 0.5, alpha=0.7, color="#0af2ee") +
                geom_vline(xintercept = as.Date(values$x_value), linetype="longdash", color = "#d8b2ed", size=1) + 
                coord_cartesian(xlim = ranges$x, ylim = ranges$y, expand = FALSE) +
                theme_light()
            HICP   
        }else{
            HICP <- ggplot() +
                # Pintamos la linea de cierre
                
                geom_segment(data = df,aes(x=date, xend=date, y=low, yend=high), size=0.4, color="black") +
                geom_segment(data = df,aes(x=date, xend=date, y=close, yend=open), size=2, color=df$color_barra) +
                geom_vline(xintercept = as.Date(values$x_value), linetype="longdash", color = "#d8b2ed", size=1) +
                coord_cartesian(xlim = ranges$x, ylim = ranges$y, expand = FALSE) +
                theme_light()
            HICP
        }
        


        })
    
    
    output$textInfo1 <- renderText({
        
        seleccionado = df_total %>% filter(date==toString(as.Date(values$x_value)))
        
        paste0("<h4>Detalle: </h4>",
               "<p> <b> Fecha: </b>", seleccionado$date, "</p>",
               "<p> <b>Cierre: </b>",round(seleccionado$close,2), "</p>",
               "<p> <b>Apertura: </b>",round(seleccionado$open,2), "</p>",
               "<p> <b>Maximo: </b>",round(seleccionado$high,2),"</p>",
               "<p> <b>Minimo: </b>",round(seleccionado$low,2),"</p>",
               "<p> <b>Adj: </b>",round(seleccionado$adjClose,2),"</p>")

            
        
    })
    
    output$table1 <- renderTable({
        # Nombre de la empresa
        empresa = input$empresa1
        # Hacemos una peticion a los datos
        datos <- pdfetch_YAHOO(empresa,
                               fields = c("open", "high", "low", "close", "adjclose", "volume"), from = as.Date(input$dateRange1[1]),
                               to = as.Date(input$dateRange1[2]), interval = "1d")
        
        # Lo transformamos a un DF para poder trabajar bien
        df = data.frame(date=as.Date(index(datos)), datos)
        # Renombramos las columnas dinamicamente para que se escalable
        df=df %>% 
            rename(
                high = paste(empresa,".high",sep=""),
                low = paste(empresa,".low",sep=""),
                close = paste(empresa,".close",sep=""),
                open = paste(empresa,".open",sep=""),
                adjClose = paste(empresa,".adjclose",sep=""),
                volume = paste(empresa,".volume",sep="")
            )
        
        
        
        df
        
        
    })
    
    output$imagen <- renderImage({
        
            return(list(
                src = "velas.png",
                contentType = "image/png",
                alt = "Velas"
            ))
        
        
    }, deleteFile = FALSE)
    
    output$downloadData <- downloadHandler(
        filename = function() {
            paste(input$empresa1,"-", Sys.Date(), ".csv", sep="")
        },
        content = function(file) {
            write.csv(df_total, file)
        }
    )

    
    
     
    

})
