
library(shiny)
library(bslib)
library(shinybusy)
library(dplyr)
library(googledrive)
library(gmailr)
library(lubridate)
library(gargle)

source("functions.R")
patron <- "[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}"

gm_auth_configure(path = "key.json")
gm_auth(email = T, cache = ".secret")



shinyApp(
  ui = page_navbar(
    theme = bs_theme(
      base_font = font_google(
        "Open Sans", wght = c(300, 400, 500, 600, 700, 800),
        ital = c(0, 1)
      ),
      "primary" = "#0675DD",
    ),
    title = tags$span(
      tags$img(src = "https://www.rstudio.com/wp-content/uploads/2018/10/RStudio-Logo-White.png", width = "46px", height = "auto", class = "me-3"),
      "Example app to run the functions in a more interactive way"
    ),
    fillable = TRUE,
    br(),
    column(width = 4,
           card(full_screen = T, card_header(p("Main options")),
                actionButton("first", label = "Rename files (1)", icon = icon("file")),
                br(),br(),
                numericInput("mails_n",label ="Number of mails to read" , value = 10),
                actionButton("second", label = "Extract data from mails (2)", icon = icon("mailchimp")),
                br(),br(),
                actionButton("third", label = "Join patterns from PDF (3)", icon = icon("file-excel"))
           ),

    )
  ),
  server = function(input, output, session){

    observeEvent(input$first,{

      withProgress(message = "Renaming files, please waite",{

        tryCatch({

          incProgress(0.8)
          rename_files_gmail()
          incProgress(0.2)


          shinybusy::report_success(
            "Good!",
            "All data was updated",
            config_report(
              svgColor = "#0431B4",
              titleColor = "#0431B4"
            )
          )

        }, error = function(e){

          shinybusy::report_failure(
            "oh :(!",
            "There was a problem with the data",
            config_report(
              svgColor = "#0431B4",
              titleColor = "#0431B4"
            )
          )

        })

      })


    })

    observeEvent(input$second,{

      withProgress(message = "Extracting data from files, please waite",{

        tryCatch({

          incProgress(0.8)
          extract_data_mails(1)
          incProgress(0.2)


          shinybusy::report_success(
            "Good!",
            "All data was updated",
            config_report(
              svgColor = "#0431B4",
              titleColor = "#0431B4"
            )
          )

        }, error = function(e){

          shinybusy::report_failure(
            "oh :(!",
            "There was a problem with the data",
            config_report(
              svgColor = "#0431B4",
              titleColor = "#0431B4"
            )
          )

        })

      })


    })

    observeEvent(input$third,{

      withProgress(message = "Joining data from pdf to excel, please waite",{

      tryCatch({

        incProgress(0.8)
        join_uuid(pattern = patron)
        incProgress(0.2)


        shinybusy::report_success(
          "Good!",
          "All data was updated",
          config_report(
            svgColor = "#0431B4",
            titleColor = "#0431B4"
          )
        )

      }, error = function(e){

        shinybusy::report_failure(
          "oh :(!",
          "There was a problem with the data",
          config_report(
            svgColor = "#0431B4",
            titleColor = "#0431B4"
          )
        )

      })

      })


    })

  }
)


