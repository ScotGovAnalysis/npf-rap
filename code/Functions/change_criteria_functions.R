##########################################################################
# Name of file - change_criteria_functions.R
# Type - Reproducible Analytical Pipeline (RAP)
# Written/run on - RStudio Desktop
# Version of R - 4.2.2
#
# Description - functions to calculate different criteria for change. 
# No manual changes are required to this script before the process is run.
##########################################################################


# 1. One point change, three periods in a row ----

## Criteria for change function:
# - Performance is improving if the indicator decreases for three periods 
#   in a row by at least 1 percentage point each period.
# - Performance is worsening if the indicator increases for three periods 
#   in a row by at least 1 percentage point each period.
# - Otherwise, performance is maintaining. 

three_1pp_changes <- function(data) {
  
  # Calculate changes
  changes <- data %>% 
    
    # Filter for headline data
    filter(disaggregation == "Total") %>% 
    
    # Arrange data by year
    arrange(year) %>% 
    
    # Filter for last four years of data
    slice_tail(n = 4) %>% 
    
    # Calculate change for the last three periods
    mutate(change = figure - lag(figure)) %>% 
    
    # Extract the change column
    pull(change)
  
  
  for (i in 1:(length(changes) - 2)) {
    
    # Check if there are 3 consecutive changes >= 1
    if (all(!is.na(changes[i:(i+2)])) && all(changes[i:(i+2)] >= 1)) {
      return("Worsening")
    }
    
    # Check if there are 3 consecutive changes <= -1
    if (all(!is.na(changes[i:(i+2)])) && all(changes[i:(i+2)] <= -1)) {
      return("Improving")
    }
  }
  
  return("Maintaining")
}
