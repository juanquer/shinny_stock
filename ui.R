#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyWidgets)

color1="#9bcfe8"

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("IBEX 35 Comparative"),
    
    ## PRIMER GRAFICO DE ARRIBA
    fluidRow(
        # Parametros el grafico
        column(3,
               wellPanel(
                   style = paste("background:",color1),
                   # Empresa del IBEX
                   selectInput(inputId ="empresa1",
                                   label="Selecciona una de las empresas del IBEX35",
                                   choices=c("ANA.MC","IBE.MC","ACX.MC","ACS.MC","AENA.MC","ALM.MC","ITX.MC","SAN.MC","BBVA.MC","AMS.MC","CLNX.MC","TEF.MC","FER.MC","CABK.MC","REP.MC","GRF.MC","ELE.MC","RED.MC","IAG.MC","SGRE.MC","NTGY.MC","ENG.MC","MTS.MC","BKT.MC","MRL.MC","MAP.MC"),
                                   selected="ANA.MC"
                   ),
                   # Rango de fechas
                   dateRangeInput("dateRange1","Enter Start and End Dates for the Display",
                                  start="2015-01-01",end=Sys.Date(), min="2015-01-01", max=Sys.Date(),
                                  format="yyyy-mm-dd",),
                   # Descargar datos
                   downloadButton("downloadData","Descargar datos"),
                   # Rerpesentar grafico de lineeas
                   checkboxInput("displayLines1",label = "Representar lineas"),
               )       
        ),
        column(6,
               
               withTags({
                   div(class="header", checked=NA,
                       p("Esta práctica tiene el objetivo de representar multiples gráficos y tablas que puedan ser útiles a la hora de decidir si invertir en 
               una determinada empresa del IBEX35. Desde el panel de la izquierda, se puede seleccionar cualquier empresa, y el rango de fechas que se
               pretende analizar."),
               p("La etiqueta Gráfico, representa uno de los gráficos más importantes que se emplean en este nicho. Es bastante
                parecido a un Boxplot, aquí en lineas negras se representa la variación entre el máximo y mínimo, y con líneas rojas o verdes la diferencia 
               entre la apertura y el cierre. (Si el cierre es más elevado que la apertura, será verde, y rojo en el caso contrario). Resumen gráfico en la siguiente imagen"),
               
               p("Haciendo doble click sobre un gráfico, pordemos obtener más información para el día seleccionado, apareciendo la información en más detalle en
               el margen derecho del gráfico. Para hacer Zoom, basta con seleccionar el área sobre el que se pretende ampliar y hacer click sobre ella. Para hacer
               Zoom Out, simplemente hay que hacer un click sobre cualquier punto del gráfico."),
               
               
                       a(href="https://github.com/juanquer/shiny_stock.git", "GitHub!")
                   )
               })
               
                   
        ),
        
        column(3,
                imageOutput("imagen"),
               
        ),
    ),
    
    fluidRow(
    column(10,
           
           tabsetPanel(
               tabPanel("Grafico", 
                        div(style='height:500px; overflow: scroll',plotOutput("distPlot",
                                                                              click = "plot_click",
                                                                              dblclick = "plot_dblclick",
                                                                              brush = brushOpts(
                                                                                  id = "plot1_brush",
                                                                                  resetOnNew = TRUE
                                                                              )))
               ),
               tabPanel("Tabla",div(style='height:300px; overflow: scroll',
                                    tableOutput("table1")
               ))
           ),
           
           
           
    ),
    column(2,
           div(style="height:50px;"),
           wellPanel(style = paste("background:",color1),
                     htmlOutput("textInfo1")
           )  
    ),
    )
    
    

 

   
    
))
