# This file run_analysis.R ihas the script for the "getting and cleaning data" Course project 
# For more detailed comments (input) please refer to README.md as requested in the Project Assighnment  

# STEP 0. Loading the data to hard drive.
# setting working directory 

filesPath <- "C:/Users/Andrey/Desktop/Coursera John Hopkins Big Data/3_Getting and Cleaning Data"
setwd(filesPath)
if(!file.exists("./dataset")){dir.create("./dataset")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./dataset/Data.zip")

# unzip file creates automatically new directory "UCI HAR Dataset"

unzip(zipfile="./dataset/Data.zip",exdir="./dataset")

# loading necessary packages

library(dplyr)
library(data.table)
library(tidyr)

# Read SUBJECT, ACTIVITY, DATA files 

filesPath <- "C:/Users/Andrey/Desktop/Coursera John Hopkins Big Data/3_Getting and Cleaning Data/dataset/UCI HAR Dataset"

# reading data Files

Train <- tbl_df(read.table(file.path(filesPath, "train", "X_train.txt" )))
Test  <- tbl_df(read.table(file.path(filesPath, "test" , "X_test.txt" )))

# reading activity files 

ActivityTrain <- tbl_df(read.table(file.path(filesPath, "train", "y_train.txt")))
ActivityTest  <- tbl_df(read.table(file.path(filesPath, "test" , "y_test.txt" )))

# reading subject files

SubjectTest  <- tbl_df(read.table(file.path(filesPath, "test" , "subject_test.txt" )))
SubjectTrain <- tbl_df(read.table(file.path(filesPath, "train", "subject_train.txt")))


# STEP 1. Merges the training and the test sets to create one data set.

#combine SUBJECT: train and test sets

MergedSubject <- rbind(SubjectTrain, SubjectTest)
setnames(MergedSubject, "V1", "subject")

#combine ACTIVITY: train and test sets

MergedActivity<- rbind(ActivityTrain, ActivityTest)
setnames(MergedActivity, "V1", "activityNum")

#combine DATA: train and test sets

MergedData <- rbind(Train, Test)

#assign variables according to features 

Features <- tbl_df(read.table(file.path(filesPath, "features.txt")))
setnames(Features, names(Features), c("featureNum", "featureName"))
colnames(MergedData) <- Features$featureName

#col names for activity tables

activityLabels <- tbl_df(read.table(file.path(filesPath, "activity_labels.txt")))
setnames(activityLabels, names(activityLabels), c("activityNum","activityName"))

# merging columns

MergedSubject <- cbind(MergedSubject, MergedActivity)
MergedData <- cbind(MergedSubject, MergedData)


# STEP 2. Extracts only the measurements on the mean and standard deviation for each measurement.

FeaturesMeanStd <- grep("mean\\(\\)|std\\(\\)",Features$featureName,value=TRUE)
FeaturesMeanStd <- union(c("subject","activityNum"), FeaturesMeanStd)
MergedData <- subset(MergedData, select = FeaturesMeanStd)

# STEP 3. Uses descriptive activity names to name the activities in the data set

MergedData <- merge(activityLabels, MergedData , by="activityNum", all.x=TRUE)
MergedData$activityName <- as.character(MergedData$activityName)
dataAggr<- aggregate(. ~ subject - activityName, data = MergedData, mean)
MergedData <- tbl_df(arrange(dataAggr,subject,activityName))


# STEP 4. Appropriately labels the data set with descriptive variable names. 

# we check what Names we had before

head(str(MergedData),2)

names(MergedData)<-gsub("std()", "SD", names(MergedData))
names(MergedData)<-gsub("mean()", "MEAN", names(MergedData))
names(MergedData)<-gsub("^t", "time", names(MergedData))
names(MergedData)<-gsub("^f", "frequency", names(MergedData))
names(MergedData)<-gsub("Acc", "Accelerometer", names(MergedData))
names(MergedData)<-gsub("Gyro", "Gyroscope", names(MergedData))
names(MergedData)<-gsub("Mag", "Magnitude", names(MergedData))
names(MergedData)<-gsub("BodyBody", "Body", names(MergedData))

# now we check Names after
head(str(MergedData),6)

# STEP 5. From the data set in step 4, creates a second, 
# independent tidy data set with the average of each variable 
# for each activity and each subject.

write.table(MergedData, "TidyDataSet.txt", row.name=FALSE)
