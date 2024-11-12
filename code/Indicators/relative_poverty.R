##########################################################################
# Name of file - relative_poverty
# Type - Reproducible Analytical Pipeline (RAP)
# Written/run on - RStudio Desktop
# Version of R - 4.2.2
#
# Description - Reads in new data for the relative poverty indicator.
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
rel_pov_func <- function(data, sheet){
  
  data <- data %>% 
    
    # Filter for rows after table a header and before table b header
    filter(row_number() > which(str_detect(data[[1]], paste0(sheet,"a"))) & 
           row_number() < which(str_detect(data[[1]], paste0(sheet,"b")))) %>% 
    
    # Use first row of data as column headers
    row_to_names(row_number = 1) %>% 
    
    # Pivot data to long format
    pivot_longer(!Group, names_to = "Year", values_to = "Figure") %>% 
    
    # Transform estimate to numeric format and round to 2 dp
    mutate(Figure = round(as.numeric(Figure), digits = 2),
           
           # Create indicator name column
           Indicator = "Relative poverty",
           
           # Create new year label variable
           Yearlab = Year) %>% 
    
    # Rename group variable
    rename(Breakdown = Group)
  
}


## Headline and age ----

# Apply function to wrangle data
rel_pov_age <- rel_pov_func(data = rel_pov_age_raw, sheet = "1") %>% 
  
  # Create new disaggregation variable
  mutate(Disaggregation = case_when(Breakdown == "All people" ~ "Total",
                                    Breakdown != "All people" ~ "Age"),
         
         # Rename total breakdown category
         Breakdown = str_replace_all(Breakdown, "All people", "Total"))


## Disability ----

# Apply function to wrangle data
rel_pov_dis <- rel_pov_func(data = rel_pov_dis_raw, sheet = "10") %>%
  
  # Create new disaggregation variable
  mutate(Disaggregation = "Disability of household member(s)") %>% 
  
  # Filter for two groups of interest:
  # - In household with no disabled person(s)
  # - In household with disabled person(s)
  filter(grepl("person", Breakdown)) %>% 
  
  # Rename breakdowns
  # fixed() tells stringr to treat the patterns as literal strings which
  # bypasses issues with parentheses
  mutate(Breakdown = str_replace_all(Breakdown,
                                     fixed("In household with no disabled person(s)"),
                                     "No one disabled"),
         Breakdown = str_replace_all(Breakdown,
                                     fixed("In household with disabled person(s)"),
                                     "Someone disabled"))

## Ethnicity ----

# Apply function to wrangle data
rel_pov_eth <- rel_pov_func(data = rel_pov_eth_raw, sheet = "12") %>%
  
  # Create new disaggregation variable
  mutate(Disaggregation = "Ethnicity") 


## Urban/rural ----

# Apply function to wrangle data
rel_pov_rur <- rel_pov_func(data = rel_pov_rur_raw, sheet = "15") %>%
  
  # Create new disaggregation variable
  mutate(Disaggregation = "Urban/Rural") 


## SIMD ----

# Apply function to wrangle data
rel_pov_simd <- rel_pov_func(data = rel_pov_simd_raw, sheet = "16") %>%
  
  # Create new disaggregation variable
  mutate(Disaggregation = "SIMD decile",
         
         # Rename breakdowns
         Breakdown = str_replace_all(Breakdown, c("1 - Most deprived" = "1",
                                                  "10 - Least deprived" = "10")))

## Gender ----

# Apply function to wrangle data
rel_pov_sex <- rel_pov_func(data = rel_pov_sex_raw, sheet = "34") %>%
  
  # Create new disaggregation variable
  mutate(Disaggregation = "Gender") 


## Sexual orientation ----

# Apply function to wrangle data
rel_pov_sexor <- rel_pov_func(data = rel_pov_sexor_raw, sheet = "36") %>%
  
  # Create new disaggregation variable
  mutate(Disaggregation = "Sexual orientation") %>% 
  
  # Remove rows where sexual orientation is missing
  filter(Breakdown != "(Missing)")


## Religion ----

# Apply function to wrangle data
rel_pov_rel <- rel_pov_func(data = rel_pov_rel_raw, sheet = "38") %>%
  
  # Create new disaggregation variable
  mutate(Disaggregation = "Religion") 


## Combine data ----
rel_pov_data <- rel_pov_age %>% 
  
  # Join dataframes
  bind_rows(rel_pov_dis, rel_pov_eth, rel_pov_rur, rel_pov_simd, 
            rel_pov_sex, rel_pov_sexor, rel_pov_rel) %>% 
  
  # Create outcome variable
  mutate(Outcome = "Poverty",
         
         # Times figure by 100 to match database figures
         Figure = Figure * 100) %>% 
  
  # Remove duplicate total categories
  filter(Breakdown != "All")


## As a ONE-OFF: save urban/rural data separately to add full time series
# to database This is because urban/rural is a new breakdown being added.
rel_pov_rur_full <- rel_pov_data %>% 
  
         filter(Disaggregation == "Urban/Rural")


# 3. Prepare final files ----

database <- rel_pov_data %>% 
  
  # Filter relative poverty data for most recent year
  filter(Year == max(Year)) %>% 
  
  # Append database and full urban/rural timeseries (as a one-off)
  rbind(database, rel_pov_rur_full) %>% 
  
  # Remove any duplicate rows
  unique() %>% 
  
  # Arrange by indicator name, breakdown and year
  arrange(Indicator, Disaggregation, Breakdown, Year)


# Remove data no longer needed from environment
rm(rel_pov_age_raw, rel_pov_dis_raw, rel_pov_eth_raw,
   rel_pov_rur_raw, rel_pov_simd_raw, rel_pov_sex_raw,
   rel_pov_sexor_raw, rel_pov_rel_raw, rel_pov_age,
   rel_pov_dis, rel_pov_eth, rel_pov_rur, rel_pov_simd, 
   rel_pov_sex, rel_pov_sexor, rel_pov_rel, table_list)
