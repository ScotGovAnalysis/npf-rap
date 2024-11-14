##########################################################################
# Name of file - 1_read_data.R
# Type - Reproducible Analytical Pipeline (RAP)
# Written/run on - RStudio Desktop
# Version of R - 4.2.2
#
# Description - Reads in existing database file and sources individual indicator 
# scripts by source publication month. Manual changes will be required to 
# individual scripts before running so should be checked separately!
##########################################################################


# 1. NPF database ----

# Read in existing database file from SQL server
database <- read_table_from_db(server = npf_server,
                               database = npf_database,
                               schema = npf_schema,
                               table_name = "Npfdatabase") %>% 
  
  # Remove capitals from column names
  clean_names() %>% 
  
  # Remove row ID column and additional columns imported from SQL
  select(!c(rowid, sys_start_time, sys_end_time, npfdatabase_version_key))



# 2. Source indicator scripts ----

## January ----



## February ----



## March ----
source("Code/Indicators/income_inequality.R")
source("Code/Indicators/relative_poverty.R")



## April ----



## May ----



## June ----



## July ----



## August ----



## September ----



## October ----



## November ----



## December ----





### END OF SCRIPT ###