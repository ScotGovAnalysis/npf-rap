##########################################################################
# Name of file - income_inequality
# Type - Reproducible Analytical Pipeline (RAP)
# Written/run on - RStudio Desktop
# Version of R - 4.2.2
#
# Description - Reads in new data for the income inequality indicator and
# appends to database file.
# Data source is table 53a: Palma ratio (before housing), income 
# inequality measures, from Poverty and Income Inequality in Scotland.
#
# Dependencies - TO CHECK BEFORE RUNNING!
# - Name of data file
# - Sheet/table numbers
# - Table headers (i.e. contain "a" and "b")
##########################################################################


# 1. Read in data ----

inc_ineq_data_raw <- read_excel("poverty_and_income_inequality_in_scotland_2020_23.xlsx", sheet = "53")


# 2. Prepare data ----

inc_ineq_data <- income_data_raw %>% 
  
  # Filter for rows after 53a table header and before 53b table header
  filter(row_number() > which(str_detect(income_data_raw[[1]], "53a")) &
           row_number() < which(str_detect(income_data_raw[[1]], "53b"))) %>% 
  
  # Use first row of data as column names
  row_to_names(row_number = 1) %>% 
  
  # Pivot data to long format
  pivot_longer(!Measure, names_to = "Year", values_to = "Figure") %>% 
  
  # Transform figure to numeric format and *100 to get percentage
  # (as reported in source publication)
  mutate(Figure = as.numeric(Figure) * 100) %>% 
  
  # Round Figure to 0 decimal places
  mutate(Figure = round(Figure, digits = 0),
         
         # Create indicator name variable
         Indicator = "Income inequality",
         
         # Create outcome variable
         Outcome = "Economy",
         
         # Create year label variable
         Yearlab = Year,
         
         # Create disaggregation and breakdown variables
         Disaggregation = "Total",
         Breakdown = "Total") %>% 
  
  # Filter for before housing costs
  filter(Measure == "Before housing costs") %>% 
  
  # Remove measure column
  select(!Measure)


# 3. Prepare final files ----

database <- inc_ineq_data %>% 
  
  # Filter relative poverty data for most recent year
  filter(Year == max(Year)) %>% 
  
  # Append database
  rbind(database) %>% 
  
  # Remove any duplicate rows
  unique() %>% 
  
  # Arrange by indicator name, breakdown and year
  arrange(Indicator, Disaggregation, Breakdown, Year)


# Remove data no longer needed from environment
rm(inc_ineq_data_raw, inc_ineq_data)
