setwd("~/Documents/data-sciences/Coursera/DataScienceJHU/Module3/final-assignment")

# load useful libraries 
library(dplyr)
library(reshape2)


# PART 1 : Merges the training and the test sets to create one data set. 
baseurl = "./rawdata/UCI HAR Dataset"

mapping_features_names <- read.table(paste0(baseurl,"/features.txt"))
mapping_features_names <- rename(mapping_features_names, feature_id = V1, feature_name = V2) 

# load and combine training data sets 
train_subject <- read.table(paste0(baseurl,"/train/subject_train.txt"))
train_X <- read.table(paste0(baseurl, "/train/X_train.txt"))
names(train_X) <- mapping_features_names$feature_name
train_y <- read.table(paste0(baseurl, "/train/y_train.txt"))

train_df <- cbind(
  rename(train_subject, subject_id = V1), 
  rename(train_y, activity_id = V1),
  train_X 
)


# load and combine test data sets 
test_subject <- read.table(paste0(baseurl,"/test/subject_test.txt"))
test_X <- read.table(paste0(baseurl, "/test/X_test.txt"))
names(test_X) <- mapping_features_names$feature_name
test_y <- read.table(paste0(baseurl, "/test/y_test.txt"))

test_df <- cbind(
  rename(test_subject, subject_id = V1), 
  rename(test_y, activity_id = V1), 
  test_X
)

# combine training and test datasets into one dataset 
df_combined <- rbind(train_df, test_df) 


# PART 2 : Extracts only the measurements on the mean and standard deviation for each measurement.

# find the features name that contains mean or std (including meanFreq features) 
features_to_keep <- mapping_features_names[grep("mean|std", mapping_features_names$feature_name), ]

# reduce the combined dataset with only the subject ID, the activity ID and the features that contains mean() or std()
df_combined <- df_combined[, c("subject_id", "activity_id", as.vector(features_to_keep$feature_name))]


# PART 3 : Uses descriptive activity names to name the activities in the data set

# load activity names into a activity_name factor variable 
mapping_activity_names <- read.table(paste0(baseurl,"/activity_labels.txt"))
activity_names_labels <- mapping_activity_names[order(mapping_activity_names$V1),]$V2
df_combined$activity_id <- factor(df_combined$activity_id, labels = activity_names_labels)
df_combined <- rename(df_combined, activity_name = activity_id)


# PART 4 : Appropriately labels the data set with descriptive variable names
# --> done in PART 1 


# PART 5 : From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
df_melted <- reshape2::melt(df_combined, id.vars = c("subject_id", "activity_name"))
# get the mean of all columns per subject_id and activity_name 
df_tidy <- reshape2::dcast(df_melted, subject_id + activity_name ~ variable, mean)


# Write the tidy data to submit 
if (!file.exists("tidydata")) {
  dir.create("tidydata")
}
write.table(df_tidy, file = "tidydata/df_tidy_data.txt", row.name=FALSE)



