# Libraries ####
library(FNN)

# True outlier detection ####
find_crude_local_residuals <- function(data_set, method="knn", ...){
    # Fit a simple local model to the data
    
    if (method=="knn"){
        # Use k-nearest neighbours regression
        crude_model <- knn.reg(data_set[c("x", "y")], y=data_set$z, ...)
        
        resids <- crude_model$residuals
        
    } else{
        return (NULL)
    }
    
    # Return approximate residuals for each data point
    
    return(resids)
} 


detect_outliers <- function(resids, threshold=4){
    
    # Standardize the residuals
    std_resids <- resids / sd(resids)
    
    # Flag all points with an absolute standardized residual > threshold
    outlier_flags <- abs(std_resids) > threshold
    
    outlier_proportion <- sum(outlier_flags) / length(outlier_flags)
    
    print(paste(signif(outlier_proportion*100,3), "% of points were flagged as outliers."))
    
    return(outlier_flags)
}

# Weighting remaining points ####
find_ship_path(tract){
    return(NULL)
}

weight_points <- function(data_set, resids){
    
    # Find path of ship in each tract
    
    # Compute distance of each point to the path
    # This is the horizontal distance it was measured from
        
    # Regress square of residuals vs. the distance to the path
    
    # Weight each point according to 1 / predicted error (squared residual) for that distance
    
    return(NULL)
}

# Model fitting ####
fit_depth_model <- function(data_set, weights=NA){
    
    # Fit a smooth depth model, using the determined weights
    
    return(NULL)
}