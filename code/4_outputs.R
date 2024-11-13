##########################################################################
# Name of file - 4_create_outputs.R
# Type - Reproducible Analytical Pipeline (RAP)
# Written/run on - RStudio Desktop
# Version of R - 4.2.2
#
# Description - Creates required outputs:
# - NPF website database file
# - NPF website arrow direction file
# - Equality Evidence Finder file
# - One page summary file
##########################################################################


# 1. Prepare NPF website database file ----

# Format final database file
updated_database <- database %>% 
  
  # Add row ID
  mutate(rowid = seq(1:nrow(database)))

# Capitalise column names
colnames(updated_database) <- str_to_title(colnames(updated_database))


# 2. Prepare NPF website arrow direction file ----







### END OF SCRIPT ###