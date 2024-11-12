##########################################################################
# Name of file - 0_setup.R
# Type - Reproducible Analytical Pipeline (RAP)
# Written/run on - RStudio Desktop
# Version of R - 4.2.2
#
# Description - Sets up environment required for running NPF RAP. 
# No manual changes are required to this script before the process is run.
##########################################################################


### 1. Load packages ----
library(RtoSQLServer)
library(tidyverse)
library(janitor)
library(readxl)


### 2. Set folder locations ----

# Downloaded data

# Received data


### 3. Read in data from SQL server ----

# Set SQL database connection details
server <- "s0196a\\ADM"
database <- "CorporateAnalyticalServicesNationalPerformanceFramework"
schema <- "nationalindicators"

# Show tables in the SQL server
show_schema_tables(
  server = server,
  database = database,
  schema = schema,
  include_views = TRUE)

# Read in existing NPF database file
database <- read_table_from_db(server = server,
                               database = database,
                               schema = schema,
                               table_name = "Npfdatabase") %>% 
  
  # Remove row ID column and additional columns imported from SQL
  select(!c(Rowid, SysStartTime, SysEndTime, NpfdatabaseVersionKey))


### 4. Create functions ----




### END OF SCRIPT ###
