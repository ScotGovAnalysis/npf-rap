##########################################################################
# Name of file - 0_setup.R
# Type - Reproducible Analytical Pipeline (RAP)
# Written/run on - RStudio Desktop
# Version of R - 4.2.2
#
# Description - Sets up environment required for running NPF RAP. 
# No manual changes are required to this script before the process is run.
##########################################################################


# 1. Load packages ----
library(RtoSQLServer)
library(tidyverse)
library(janitor)
library(readxl)



# 2. Set folder locations ----

# Downloaded data

# Received data



# 3. SQL connection ----

# Set SQL database connection details
npf_server <- "s0196a\\ADM"
npf_database <- "CorporateAnalyticalServicesNationalPerformanceFramework"
npf_schema <- "nationalindicators"

# Show tables in the SQL server
# show_schema_tables(
#   server = npf_server,
#   database = npf_database,
#   schema = npf_schema,
#   include_views = TRUE)



# 4. Read in lookups ----

# PLACEHOLDER: Indicators mapped to outcomes
outcome_mapping <- read_excel("Outcome mapping.xlsx")



# 5. Functions ----

# Source function scripts
source("Code/Functions/wrangling_functions.R")
source("Code/Functions/chart_functions.R")
source("Code/Functions/change_criteria_functions.R")



# 6. Chart theme ----

# Define chart colours (extended from sgplot package)
chart_colours <- c("#002d54", "#2b9c93", "#6a2063", "#e5682a", "#0b4c0b", 
                   "#a80860", "#0065bd", "#5d9f3c", "#592c20", "#ca72a2")



### END OF SCRIPT ###
