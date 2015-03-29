# Data processing and model fitting ####

# Load in script that does the heavy lifting
source("./Scripts/modelling.R")

# Perform a round of data processing and model fitting on a subset of the data
model_bathymetry <- function(data_path, validation=F, threshold, first_pass_technique, ...){
    
    data_set <- read.csv(data_path)
    
    crude_residuals <- find_crude_local_residuals(data_set, method=first_pass_technique, ...)
    
    outlier_list <- detect_outliers(crude_residuals, threshold)
    
    cleaned_data_set <- data_set[-outlier_list,]
    
    point_weights <- weight_points(cleaned_data_set, crude_residuals)
    
    depth_model <- fit_depth_model(cleaned_data_set, point_weights)
    
    output <- list(depth_model=depth_model, weights=point_weights, outliers=data_set[outlier_list,])
    
    return(output)
}

# Experiment with different options

# Select and save final model and data

# Prediction ####

# Predict depth at prespecified points
predict_points <- function(points, model){
    return(NULL)
}

# Predict depth data in a grid
predict_griddded <- function(bounding_region, resolution, model){
    return(NULL)
}