##########################################################################
# Name of file - 2_combine_data.R
# Type - Reproducible Analytical Pipeline (RAP)
# Written/run on - RStudio Desktop
# Version of R - 4.2.2
#
# Description - Combines all new data (received from lead analysts and scraped
# from publications), prepares new data and then appends to database file.
# No manual changes are required to this script before the process is run.
##########################################################################


# 1. Combine all data  ----

# Combine scraped data
new_data <- rbind(rel_pov_data,      # relative poverty
                  inc_ineq_data) %>% # income inequality
  
  # Create outcome variable
  left_join(outcome_mapping, by = "indicator") %>%
  
  # Create yearlab variable
  mutate(yearlab = year) %>% 
  
  # Append database file
  rbind(database) %>% 
  
  # Remove duplicate rows
  unique() %>% 
  
  # Arrange by indicator, disaggregation, breakdown and year
  arrange(indicator, disaggregation, breakdown, year) %>% 
  
  # Reorder columns
  select(outcome, indicator, disaggregation, breakdown, year, yearlab, figure)



# 2. Remove data ----

# Remove data no longer needed from environment
rm(rel_pov_data, 
   inc_ineq_data)



### END OF SCRIPT ###
