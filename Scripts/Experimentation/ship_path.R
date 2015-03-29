# Libraries ####
library(ggplot2) # plotting
library(MethComp) # Deming regression
library(mgcv) # GAMs

# Set up ####

# Load data
master_data <- read.csv("./Data/Master/bathymetry_master.csv")

# Settings
tract_name <- "really_bad"
use_train <- TRUE
threshold <- 4.4

# Subset data
tract_data <- master_data[master_data$Tract_ID==tract_name & master_data$Training==use_train, ]

# Fit ship path ####

# Linear total least squares approach
# Ratio of errors is 1
ship_path_model <- Deming(tract_data$x, tract_data$y)

# Find distance to ship path ####

# Euclidean distance function
euclidean_distance <- function(x, y, slope, intercept){
    # Distance formula:
    # abs(Ax + By + C) / sqrt(A^2 + B^2)
    
    # Need to convert linear equation form
    # y=mx+b
    # Ax + By + C = 0
    # A = -m
    # B = 1
    # C = -b
    
    A = -slope
    B = 1
    C = -intercept
    
    distance <- abs(A*x + B*y + C) / sqrt(A^2 + A^2)
    
    return(distance)
}

# Finding Euclidean distance
slope <- ship_path_model[["Slope"]]
intercept <- ship_path_model[["Intercept"]]

tract_data$Distance <- euclidean_distance(tract_data$x, tract_data$y, slope, intercept)

# Visualizing the distance
ggplot(tract_data, aes(x=x, y=y, colour=Distance)) + geom_point()

# Remove outliers ####
crude_residuals <- find_crude_local_residuals(tract_data)

tract_data$residuals <- crude_residuals

outlier_list <- detect_outliers(crude_residuals, threshold)
cleaned_data <- tract_data[-outlier_list,]


# Determine point weights ####

# visualisation of residuals vs. distance
ggplot(cleaned_data, aes(y=residuals, x=Distance)) + geom_point() + geom_smooth()

ggplot(cleaned_data, aes(y=residuals^2, x=Distance)) + geom_point() + geom_smooth()

# Estimate variance (residuals squared) vs. distance from boat
cleaned_data$resids_sq <- cleaned_data$residuals^2

# Need to use a strictly positive error distribution
weight_model <- gam(resids_sq ~ s(Distance), family=gaussian(link="log"), data=cleaned_data)
#weight_model <- gam(resids_sq ~ s(Distance), family=gaussian(link="identity"), data=cleaned_data)

summary(weight_model)
plot(weight_model)

# Record estimated weights for each data point
# Points are weighted according to 1 / expected variance
cleaned_data$weights <- 1/weight_model$fitted.values

# Plot weights of data points
ggplot(cleaned_data, aes(x=x, y=y, colour=weights)) + geom_point()
