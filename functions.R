



rename_files_gmail <- function(number_of_mails = 10){

  ## Packages
  library(dplyr)
  library(googledrive)
  library(gmailr)
  library(lubridate)
  library(gargle)
  library(stringr)


  # Config auth with gmail account
  gm_auth_configure(path = "key.json")
  gm_auth(email = T, cache = ".secret")

  Archivo_excel <- readxl::read_excel("data/factura.xlsx") |>
    janitor::clean_names()

  ## Thread
  my_threads <- gm_threads(num_results = number_of_mails)

  # Sub-Thread
  x <-gm_thread(gm_id(my_threads)[1])



  # Loop to rename mails and save in local folder
  for (i in 1:number_of_mails ){

    case <- gm_thread(gm_id(my_threads)[i])$messages[[1]]
    subject <- gm_subject(case)

    if (nrow(filter(Archivo_excel, vrid == subject )) ==1){

      print("Procesando archivo")
      filtered_data <- filter(Archivo_excel, vrid == subject)

      print("Renombrando archivo")
      gm_save_attachments(case, path = "facturas/")

      print("Enviando correos")
      #file.rename()

    }else{
      print("Archivo no referente a AMAZON")
    }



  }


}


extract_data_mails <- function(num_correos = 10){

  ## Packages
  library(dplyr)
  library(googledrive)
  library(gmailr)
  library(lubridate)
  library(gargle)
  library(stringr)

  # Config auth with gmail account
  gm_auth_configure(path = "key.json")
  gm_auth(email = T, cache = ".secret")

  contenedor <- tibble(
    id_vrid = c(),
    id_factura = c()
  )


  # Load PDF and create columne
  vrid_excel <- readxl::read_excel(paste0("data/",list.files("data")[1]))
  if (is.null(vrid_excel$`Nombre del proveedor`) == T){
    vrid_excel$`Nombre del proveedor` <- "Company México"}

  if (is.null(vrid_excel$UUID) == T){
    vrid_excel$UUID <- NA}

  my_threads <- gm_threads(num_results = num_correos)


  # Loop to get data from mails
  for (i in 1:num_correos){

    case <- gm_thread(gm_id(my_threads)[[i]])$messages[[1]]
    if (gm_subject(case) == "Fwd: Acknowledgement: Receipt Of Documents"){
      x <-
        tibble(
          id_vrid = regmatches(gm_body(case), gregexpr("\\d{14}", gm_body(case)))[[1]],
          id_factura = regmatches(gm_body(case), gregexpr("\\b[A-Z0-9]{9}\\b", gm_body(case)))[[1]]
        )
      contenedor <- contenedor |>
        bind_rows(x)
    }

  }



  x <- contenedor[!duplicated(contenedor),]


  # Write data in excel
  vrid_excel <-
    vrid_excel |>
    left_join(x, by = c("VRID" = "id_factura"))


  writexl::write_xlsx(vrid_excel,"excel_SOA.xlsx")
  vrid_excel <<-vrid_excel

}


join_uuid <- function(pattern){

  ## Packages
  library(dplyr)
  library(googledrive)
  library(gmailr)
  library(lubridate)
  library(gargle)
  library(stringr)


  # Loop to get data from pdf files
  for (i in 1:nrow(vrid_excel)){
    cadena<-
      list.files("facturas procesadas") |>
      as.data.frame() |>
      setNames("val") |>
      mutate(cadena = str_detect(val, paste0(vrid_excel$VRID[i],".pdf")))

    if (length(cadena$cadena[cadena$cadena == T]) == 1){
      data_pdf <- pdftools::pdf_text(paste0("facturas procesadas/",cadena$val[cadena$cadena == T]))
      vrid_excel$UUID[vrid_excel$VRID == vrid_excel$VRID[i]] <- str_extract(data_pdf, pattern)
    }else{print("No se encontró el archivo PDF")}
  }


  writexl::write_xlsx(vrid_excel,"excel_SOA.xlsx")
}

