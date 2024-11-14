##########################################################################
# Name of file - chart_functions.R
# Type - Reproducible Analytical Pipeline (RAP)
# Written/run on - RStudio Desktop
# Version of R - 4.2.2
#
# Description - 
##########################################################################


# 1. Indicator charts ----

create_indicator_charts <- function(data, indicator_name, output_dir = "Outputs") {

  # Loop through each disaggregation for the given indicator
  for (disaggregation in unique(data$disaggregation)) {
    
    # Subset data for the current disaggregation
    subset_data <- data %>% 
      filter(disaggregation == !!disaggregation)
    
    # Check if data exists, skip if no data
    if (nrow(subset_data) == 0) next

    # Create ggplot object
    p <- ggplot(subset_data, 
                aes(x = year, y = figure, color = breakdown, group = breakdown)) +
      
      # Add lines and points
      geom_line(size = 1) +
      geom_point(size = 1) +
      
      # Add data labels
      #geom_label(data = labels, aes(label = figure), nudge_y = 0.5) +
      
      # Add titles
      labs(title = paste0(indicator_name, ", ", disaggregation),
           x = "Year", y = "Figure", color = "Breakdown") +
      
      # Define colours
      scale_color_manual(values = chart_colours) +
      
      # Define theme
      theme_bw() +
      theme(axis.text.x = element_text(angle = 90))
    
    # Save chart
    ggsave(filename = paste0(output_dir, "/", tidy_string(indicator_name), 
                             "_", tidy_string(disaggregation), ".png"),
           plot = p, width = 8, height = 6)
    
  }
}