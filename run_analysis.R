##You should create one R script called run_analysis.R that does the following.

##clear workspace before beginning exercise
rm(list=ls())

##set working directory
setwd("~/GitHub/JHDS-GetClean-Peer")

##create a data directoring in the
##current working directory
if(!file.exists("data")) {dir.create("data")}

##load library for getting file from website, 
##Curl is not working on my Windows install
library(httr)

##move to data directory

setwd("~/GitHub/JHDS-GetClean-Peer/data")

##set a variable for the URL where are we getting
##the dataset
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

##download the data using GET and 
GET(fileURL,write_disk("./data_compress.zip", overwrite = TRUE))

##unzip the files
unzip("./data_compress.zip")

##Get the features and activities FIRST. since the "subject_train.txt'
##and "subject_test.txt" contain all the potential measures (using the 
##features.txt) we want to filter down the specific type first
##read in the list of all features from the source file
featData <- read.table("UCI HAR Dataset/features.txt")

##keep only the name of the features
featData[,2] <- as.character(featData[,2])

## Subset the data to only the mean and standard deviation
featDataFilter <- grep(".*mean.*|.*std.*", featData[,2])

##Assign to a character vector, the feature names previously 
##sub-set into featData (for mean or std)
featDataFilter.names <- featData[featDataFilter,2]

##Replace sub-text within feature name with "Mean" when name contains "-mean"
featDataFilter.names = gsub('-mean', 'Mean', featDataFilter.names)

##Replace sub-text within feature name with "Std" when name contains "-std"
featDataFilter.names = gsub('-std', 'Std', featDataFilter.names)

##Replace sub-text within feature name with "Std" when name contains "-std"
featDataFilter.names = gsub('-std', 'Std', featDataFilter.names)

##remove the -() end found in the feature name
featDataFilter.names <- gsub('[-()]', '', featDataFilter.names)

##Load the training datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")

##load the training activity
trainActRaw <- read.table("UCI HAR Dataset/train/Y_train.txt")

##loads the subject that performed the activity
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")

##since each row in the "x_train.txt" is an observation, each
##row in the "subject_train.txt" represents the subject for that 
##observation, and each row in "y_train.txt" represents the 
##activity performed, use a column bind function to join the 
##datasets (a merge function is not applicable because the 
##datasets do not share columns)
train <- cbind(trainSubjects, trainActRaw, train)
train$source <- c("train")

##perform same functions for test datasets; we could refactor
##this an provide just a "test" or "train" variable and a quick sapply
##function but....

## Load the testing datasets
test <- read.table("UCI HAR Dataset/test/X_test.txt")
testActRaw <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActRaw, test)
test$source <- c("test")

#combine train and test using row bind function
testTrainData <- rbind(train, test)

##since the subject dataset was first, the first column is the subject id
##the second column is the activity
##the third column is the features
colnames(testTrainData) <- c("subject", "activity", featDataFilter.names)

##3. Uses descriptive activity names to name the activities in the data set
##Load activity labels
actLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
actLabels[,2] <- as.character(actLabels[,2])

##4. Appropriately labels the data set with descriptive variable names.
library(reshape2)
testTrainMeltData <- melt(testTrainData, id = c("subject", "activity"))
testTrainMeltData.mean <- dcast(testTrainMeltData, subject + activity ~ variable, mean)

##5. From the data set in step 4, creates a second, independent tidy data 
##set with the average of each variable for each activity and each subject.
write.table(testTrainMeltData.mean, "././tidy.txt", row.names = FALSE, quote = FALSE)

##create a codebook 
##library(memisc)
##tiTxt <- as.data.frame(readLines("././tidy.txt"))
##description(tiTxt) <- "Measures and activities for subjects "
##wording(tiTxt) <- "Testing"
##annotation(tiTxt)
##annotation(tiTxt)["Remark"] <- "This is not a real questionnaire item, of course ..."
##show_html(x, output = NULL, ...)
##write_html(tiTxt)
##codebook(tiTxt)
