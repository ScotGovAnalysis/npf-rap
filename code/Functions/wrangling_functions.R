##########################################################################
# Name of file - wrangling_functions.R
# Type - Reproducible Analytical Pipeline (RAP)
# Written/run on - RStudio Desktop
# Version of R - 4.2.2
#
# Description - 

##########################################################################


# 1. Single year ----

# Creates new single year variable where the year is a range. Extracts the last 
# two characters and transforms to year, accounting for different centuries
# Example - input: 2020-23, output: 2023.

single_year <- function(data) {
  
  data <- data %>%
    mutate(end_year = as.numeric(str_extract(year, "\\d{2}$")) + 
             ifelse(as.numeric(str_extract(year, "\\d{2}$")) < 50, 2000, 1900))
  
}


# 2. Tidy string ----

# Replace spaces, parenthesis, slashes and other characters with underscores, 
# and converts text to lower case.
# Example - input: Urban/Rural, output: urban_rural

tidy_string <- function(string) {
  
  string <- gsub(" ", "_", string)
  string <- gsub("[()/]", "_", string) 
  string <- tolower(string)
  return(string)
  
}