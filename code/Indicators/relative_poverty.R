##########################################################################
# Name of file - relative_poverty
# Type - Reproducible Analytical Pipeline (RAP)
# Written/run on - RStudio Desktop
# Version of R - 4.2.2
#
# Description - Reads in new data for the relative poverty indicator and 
# appends to database file.
# Data source - poverty and income inequality in Scotland.
# Tables from 2020-23 publication are as follows: 
# - 1: age breakdowns (and headline estimates)
# - 10: disability breakdowns 
# - 12: ethnicity breakdowns 
# - 15: urban/rural breakdowns 
# - 16: SIMD breakdowns 
# - 34: sex/gender breakdowns
# - 36: sexual orientation breakdowns
# - 38: religion breakdowns
#
# Dependencies - TO CHECK BEFORE RUNNING!
# - Name of data file
# - Sheet/table numbers
# - Table headers (i.e. contain "a" and "b")
# - Row 204 will need amended for next update as full urban/rural
#   time series won't be required
##########################################################################


# 1. Read in data ----

# Identify latest poverty and income inequality file
source_file <- c("poverty_and_income_inequality_in_scotland_2020_23.xlsx")

# Define the relevant sheet names - TO BE CHECKED BEFORE RUNNING!
sheet_names <- c("1", "10", "12", "15", "16", "34", "36", "38")

# Create list of tables
table_list <- lapply(sheet_names, read_excel, path = source_file)

# Give each table relevant name
names(table_list) <- c("rel_pov_age_raw", "rel_pov_dis_raw", "rel_pov_eth_raw",
                       "rel_pov_rur_raw", "rel_pov_simd_raw", "rel_pov_sex_raw",
                       "rel_pov_sexor_raw", "rel_pov_rel_raw")

# Bring dataframes into global environment
list2env(table_list, .GlobalEnv)



# 2. Prepare data ----

# Create function to wrangle relative poverty data
rel_pov_func <- function(data, sheet, disagg){
  
  data <- data %>% 
    
    # Filter for rows after table a header and before table b header
    filter(row_number() > which(str_detect(data[[1]], paste0(sheet,"a"))) & 
           row_number() < which(str_detect(data[[1]], paste0(sheet,"b")))) %>% 
    
    # Use first row of data as column headers
    row_to_names(row_number = 1) %>% 
    
    # Pivot data to long format
    pivot_longer(!Group, names_to = "year", values_to = "figure") %>% 
    
    # Transform estimate to numeric format and round to 2 dp
    mutate(figure = round(as.numeric(figure), digits = 2),
           
           # Create indicator name column
           indicator = "Relative poverty",
           
           # Convert year variable from character to factor
           year = as.factor(year),
           
           # Create new disaggregation variable
           disaggregation = disagg) %>% 
    
    # Rename group variable
    rename(breakdown = Group)
  
}


## Headline and age ----

# Apply function to wrangle data
rel_pov_age <- rel_pov_func(data = rel_pov_age_raw, sheet = "1",
                            disagg = "Age") %>% 
  
  # Rename disaggregation for total
  mutate(disaggregation = case_when(str_detect(breakdown, "All people") ~ "Total",
                                    .default = disaggregation),
         
         # Rename total breakdown category
         breakdown = str_replace_all(breakdown, "All people", "Total"))


## Disability ----

# Apply function to wrangle data
rel_pov_dis <- rel_pov_func(data = rel_pov_dis_raw, sheet = "10",
                            disagg = "Disability of household member(s)") %>%
  
  # Filter for two groups of interest:
  # - In household with no disabled person(s)
  # - In household with disabled person(s)
  filter(grepl("person", breakdown)) %>% 
  
  # Rename breakdowns
  # fixed() tells stringr to treat the patterns as literal strings which
  # bypasses issues with parentheses
  mutate(breakdown = str_replace_all(breakdown,
                              fixed("In household with no disabled person(s)"),
                              "No one disabled"),
         breakdown = str_replace_all(breakdown,
                              fixed("In household with disabled person(s)"),
                              "Someone disabled"))

## Ethnicity ----

# Apply function to wrangle data
rel_pov_eth <- rel_pov_func(data = rel_pov_eth_raw, sheet = "12",
                            disagg = "Ethnicity")


## Urban/rural ----

# Apply function to wrangle data
rel_pov_rur <- rel_pov_func(data = rel_pov_rur_raw, sheet = "15",
                            disagg = "Urban/Rural")


## SIMD ----

# Apply function to wrangle data
rel_pov_simd <- rel_pov_func(data = rel_pov_simd_raw, sheet = "16",
                             disagg = "SIMD decile") %>%
  
  # Rename breakdowns
  mutate(breakdown = str_replace_all(breakdown, c("1 - Most deprived" = "1",
                                                  "10 - Least deprived" = "10")),
         
         # Set levels of factor so deciles are in order
         breakdown = factor(breakdown, levels = c("All", "1", "2", "3",
                                                  "4", "5", "6", "7",
                                                  "8", "9", "10")))

## Gender ----

# Apply function to wrangle data
rel_pov_sex <- rel_pov_func(data = rel_pov_sex_raw, sheet = "34",
                            disagg = "Gender")


## Sexual orientation ----

# Apply function to wrangle data
rel_pov_sexor <- rel_pov_func(data = rel_pov_sexor_raw, sheet = "36",
                              disagg = "Sexual orientation") %>% 
  
  # Remove rows where sexual orientation is missing
  filter(breakdown != "(Missing)")


## Religion ----

# Apply function to wrangle data
rel_pov_rel <- rel_pov_func(data = rel_pov_rel_raw, sheet = "38",
                            disagg = "Religion")


## Combine data ----
rel_pov_data_combined <- rel_pov_age %>% 
  
  # Join dataframes
  bind_rows(rel_pov_dis, rel_pov_eth, rel_pov_rur, rel_pov_simd, 
            rel_pov_sex, rel_pov_sexor, rel_pov_rel) %>% 
  
  # Times figure by 100 to match database figures
  mutate(figure = figure * 100) %>% 
  
  # Remove duplicate total categories
  filter(breakdown != "All")



# 3. Prepare final data ----

# Filter data for most recent year
rel_pov_data_recent <- rel_pov_data_combined %>% 
  
  # Apply function to create new single end year variable from year range
  single_year() %>% 

  # Filter for max year
  filter(end_year == max(end_year)) %>% 
  
  # Remove end_year variable 
  select(!end_year)


## As a ONE-OFF: save urban/rural data separately to add full time series
# to database This is because urban/rural is a new breakdown being added.
rel_pov_rur_full <- rel_pov_data_combined %>%
  filter(disaggregation == "Urban/Rural")

# Append full urban/rural time series to recent data
rel_pov_data <- rbind(rel_pov_data_recent, rel_pov_rur_full) %>% 
  
  # Remove duplicate urban/rural rows
  unique()



# 4. Criteria for change ----

## Relative poverty criteria for change:
# - Performance is improving if the indicator decreases for three periods 
#   in a row by at least 1 percentage point each period.
# - Performance is worsening if the indicator increases for three periods 
#   in a row by at least 1 percentage point each period.
# - Otherwise, performance is maintaining.


# Apply the one point change, three periods in a row function to the change 
# column and save result
rel_pov_perf <- three_1pp_changes(data = rel_pov_data_combined)



# 5. Create QA files ----

# Create chart of time series for QA
create_indicator_charts(data = rel_pov_data_combined, 
                        indicator = "Relative poverty")



# 6. Remove data ----

# Remove data no longer needed from environment
rm(rel_pov_age_raw, rel_pov_dis_raw, rel_pov_eth_raw,
   rel_pov_rur_raw, rel_pov_simd_raw, rel_pov_sex_raw,
   rel_pov_sexor_raw, rel_pov_rel_raw, rel_pov_age,
   rel_pov_dis, rel_pov_eth, rel_pov_rur, rel_pov_simd, 
   rel_pov_sex, rel_pov_sexor, rel_pov_rel, table_list,
   rel_pov_rur_full, rel_pov_change, rel_pov_data_recent,
   rel_pov_data_combined)


### END OF SCRIPT ###
