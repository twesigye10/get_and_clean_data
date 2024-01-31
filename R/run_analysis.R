library(tidyverse)


# download data -----------------------------------------------------------

filename <- "inputs/UCI_HAR_Dataset.zip"

# Checking if archieve already exists.
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, filename, method="curl")
}  

# Checking if folder exists
if (!file.exists("inputs/UCI HAR Dataset")) { 
  unzip(zipfile = filename, exdir = "inputs/") 
}


# reading data ------------------------------------------------------------

df_features <- read.table("inputs/UCI HAR Dataset/features.txt", col.names = c("n","functions"))
df_activities <- read.table("inputs/UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity"))
df_subject_test <- read.table("inputs/UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
df_x_test <- read.table("inputs/UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
df_y_test <- read.table("inputs/UCI HAR Dataset/test/y_test.txt", col.names = "code")
df_subject_train <- read.table("inputs/UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
df_x_train <- read.table("inputs/UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
df_y_train <- read.table("inputs/UCI HAR Dataset/train/y_train.txt", col.names = "code")



# Step 1: -----------------------------------------------------------------
# Merging the training and the test data sets to create one data set.

df_x_combined <- rbind(df_x_train, df_x_test)
df_y_combined <- rbind(df_y_train, df_y_test)
df_subject_combined <- rbind(subject_train, subject_test)
df_merged <- cbind(df_subject_combined, df_y_combined, df_x_combined)
# colnames(df_merged)

# Step 2: -----------------------------------------------------------------
# Extracting only the measurements on the mean and standard deviation for each measurement.
df_extract <- df_merged %>% 
  select(subject, code, contains("mean"), contains("std"))

# Step 3: -----------------------------------------------------------------
# Uses descriptive activity names to name the activities in the data set.

df_extract$code <- df_activities[df_extract$code, 2]

# Step 4: -----------------------------------------------------------------
# Appropriately labels the data set with descriptive variable names.

names(df_extract)[2] = "activity"
names(df_extract)<-gsub("Acc", "Accelerometer", names(df_extract))
names(df_extract)<-gsub("Gyro", "Gyroscope", names(df_extract))
names(df_extract)<-gsub("BodyBody", "Body", names(df_extract))
names(df_extract)<-gsub("Mag", "Magnitude", names(df_extract))
names(df_extract)<-gsub("^t", "Time", names(df_extract))
names(df_extract)<-gsub("^f", "Frequency", names(df_extract))
names(df_extract)<-gsub("tBody", "TimeBody", names(df_extract))
names(df_extract)<-gsub("-mean()", "Mean", names(df_extract), ignore.case = TRUE)
names(df_extract)<-gsub("-std()", "STD", names(df_extract), ignore.case = TRUE)
names(df_extract)<-gsub("-freq()", "Frequency", names(df_extract), ignore.case = TRUE)
names(df_extract)<-gsub("angle", "Angle", names(df_extract))
names(df_extract)<-gsub("gravity", "Gravity", names(df_extract))

write.table(df_extract, "outputs/extracted_data.txt", row.name=FALSE)

# Step 5: -----------------------------------------------------------------
# From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

df_extract_means <- df_extract %>%
  group_by(subject, activity) %>%
  summarise_all(funs(mean))

write.table(df_extract_means, "outputs/extract_means.txt", row.name=FALSE)
