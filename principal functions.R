

source("functions.R")


patron <- "[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}"

rename_files_gmail()
extract_data_mails()
join_uuid(pattern = patron)

