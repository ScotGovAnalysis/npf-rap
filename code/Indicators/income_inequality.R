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

inc_ineq_data_clean <- inc_ineq_data_raw %>% 
  
  # Filter for rows after 53a table header and before 53b table header
  filter(row_number() > which(str_detect(inc_ineq_data_raw[[1]], "53a")) &
         row_number() < which(str_detect(inc_ineq_data_raw[[1]], "53b"))) %>% 
  
  # Use first row of data as column names
  row_to_names(row_number = 1) %>% 
  
  # Pivot data to long format
  pivot_longer(!Measure, names_to = "year", values_to = "figure") %>% 
  
  # Transform figure to numeric format and *100 to get percentage
  # (as reported in source publication)
  mutate(figure = as.numeric(figure) * 100) %>% 
  
  # Round Figure to 0 decimal places
  mutate(figure = round(figure, digits = 0),
         
         # Create indicator name variable
         indicator = "Income inequality",
         
         # Create disaggregation and breakdown variables
         disaggregation = "Total",
         breakdown = "Total",
         
         # Convert year variable to factor
         year = as.factor(year)) %>% 
  
  # Filter for before housing costs
  filter(Measure == "Before housing costs") %>% 
  
  # Remove measure column
  select(!Measure)



# 3. Prepare final data ----

# Filter data for most recent year
inc_ineq_data <- inc_ineq_data_clean %>% 
  
  # Apply function to create new single end year variable from year range
  single_year() %>% 
  
  # Filter for max year
  filter(end_year == max(end_year)) %>% 
  
  # Remove end_year variable
  select(!end_year)



# 4. Criteria for change ----

## Income inequality criteria for change:
# - Performance is improving if the indicator decreases for three periods 
#   in a row by at least 1 percentage point each period.
# - Performance is worsening if the indicator increases for three periods 
#   in a row by at least 1 percentage point each period.
# - Otherwise, performance is maintaining.

# Apply the one point change, three periods in a row function and save result
inc_ineq_perf <- three_1pp_changes(data = inc_ineq_data_clean)



# 5. Create QA files ----

# Create chart of time series for QA
create_indicator_charts(data = inc_ineq_data_clean, 
                        indicator = "Income inequality")




# 6. Remove data ----

# Remove data no longer needed from environment
rm(inc_ineq_data_raw, inc_ineq_change)


### END OF SCRIPT ###
