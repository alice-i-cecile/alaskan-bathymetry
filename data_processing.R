# Libraries ####
library(stringr)

# Configuration ####
source_directory <- "./Data/Original"
save_directory <- "./Data/Master"

# What fraction of the points should be used for training the model
training_proportion <- 0.7

# What fraction of the tracts should be used for validation
validation_proportion <- 0.3

# Merge the data ####

# Find all the files to merge
source_files <- list.files(source_directory)

# Read in all of the data files
data_list <- lapply(paste(source_directory, source_files, sep="/"), read.csv, header=T)

# Clean column names
# Some column names appear to be capitalized
for (i in 1:length(data_list)){
    names(data_list[[i]]) <- tolower(names(data_list[[i]]))
}

# Record the tract ID
for (i in 1:length(data_list)){
    # Tract ID becomes everything left of the "." in the file name
    data_list[[i]]$Tract_ID <- unlist(str_split(source_files[[i]], "[.]"))[1]
}

# Merge the data files
merged_data <- Reduce(rbind, data_list)

# Mark training, test and validation cases ####

# Set a random number seed to ensure reproducible assignment
set.seed(2)

# Assign data to training vs. test cases
merged_data$Training <- sample(c(TRUE, FALSE), nrow(merged_data), replace=TRUE, prob=c(training_proportion, 1 - training_proportion))

# Assign tracts to original vs. validation cases
tract_df <- data.frame(Tract_ID=unique(merged_data$Tract_ID))
tract_df$Validation <- sample(c(TRUE, FALSE), nrow(tract_df), replace=TRUE, prob=c(validation_proportion, 1 - validation_proportion)) 

merged_data <- merge(merged_data, tract_df, by = "Tract_ID")

# Saving cleaned and tagged data ####

# Save full master dataframe
write.csv(merged_data, file=paste(save_directory, "bathymetry_master.csv", sep="/"))

# Save training cases for initial run
write.csv(merged_data[merged_data$Training & !merged_data$Validation, ], file=paste(save_directory, "bathymetry_training_1.csv", sep="/"))

# Save test cases for initial run
write.csv(merged_data[!merged_data$Training & !merged_data$Validation, ], file=paste(save_directory, "bathymetry_test_1.csv", sep="/"))
          
# Save training cases for validation run
write.csv(merged_data[merged_data$Training & merged_data$Validation, ], file=paste(save_directory, "bathymetry_training_2.csv", sep="/"))

# Save test cases for validation run
write.csv(merged_data[!merged_data$Training & merged_data$Validation, ], file=paste(save_directory, "bathymetry_test_2.csv", sep="/"))
