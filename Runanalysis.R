# First, determine if R have the dplyr and the data table packages installed or not.

library(dplyr)
library(data.table)

# Then, download the file and unzip the contents inside it
data.url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
data.dir <- "UCI HAR Dataset"
data.zip <- paste(data.dir, ".zip", sep="")

if(!file.exists(data.dir))
{
  if(!file.exists(data.zip))
  {
    cat("Downloading Data ...")
    download.file(data.url, data.zip)
  }
  cat("Unzipping Downloaded Data ...")
  unzip(data.zip)
  
}


# Now, read the test datasets, labels and subjects

test_x_file       <- paste(data.dir, "test", "X_test.txt", sep="/") 
test_y_file       <- paste(data.dir, "test", "y_test.txt", sep="/")
test_subject_file <- paste(data.dir, "test", "subject_test.txt", sep="/")

test_x        <- read.table(test_x_file, sep="", header=FALSE);
test_y        <- read.table(test_y_file, sep="", header=FALSE)
test_subject  <- read.table(test_subject_file, sep="", header=FALSE)

# Construct a dataframe of test data including the subjects and activities performed
test.frame  <- data.frame(test_subject, test_y, test_x)



# Read the train dataset, labels and subjects of each code unzipped

train_x_file       <- paste(data.dir, "train", "X_train.txt", sep="/") 
train_y_file       <- paste(data.dir, "train", "y_train.txt", sep="/")
train_subject_file <- paste(data.dir, "train", "subject_train.txt", sep="/")

train_x        <- read.table(train_x_file, sep="");
train_y        <- read.table(train_y_file, sep="")
train_subject  <- read.table(train_subject_file, sep="")

# Retrieve the dataframe on train data including the train subject and activity
train.frame  <- data.frame(train_subject, train_y, train_x)


# Combine the test and train data sets
Data.full <- rbind(test.frame,train.frame)

features <- read.table(paste(data.dir,"features.txt", sep="/"), stringsAsFactors=FALSE)[,2]

colnames(Data.full) <- c("subject", "activity", features)
Data.full <- Data.full[, !duplicated(colnames(Data.full))]

Data.new <- select(Data.full, contains("subject"), contains("activity"), contains("mean"), contains("std"), -contains("freq"), -contains("angle"))

# Read in the activity labels and load the activity codes in original data with their respective labels given from the data unpacked
labels   <- read.table(paste(data.dir,"activity_labels.txt", sep="/"), stringsAsFactors=FALSE)
Data.new$activity <- labels[match(Data.new$activity, labels$V1), 'V2']

# Tidy up the variable names  
setnames(Data.new, colnames(Data.new), gsub("\\(\\)", "", colnames(Data.new)))
setnames(Data.new, colnames(Data.new), gsub("-", "_", colnames(Data.new)))
setnames(Data.new, colnames(Data.new), gsub("BodyBody", "Body", colnames(Data.new)))

# Group the data by subject and activity and calculate the average for each group
Data.Summary <- Data.new %>%group_by(subject, activity) %>% summarise_each(funs(mean))

# Write the detailed and summary data to data files
write.table(Data.new, "full_data.txt", row.names=FALSE)
write.table(Data.Summary, "summary_data.txt", row.names=FALSE)