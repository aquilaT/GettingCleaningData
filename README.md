This file README.md is describing content of 3 submitted files 
for the "getting and cleaning data" Course project 
overall I submitted 3 files to github:

(1) run_analysis.R The file has the code for the Course Project 
(2) README.md includes assignment description and additional explanation how the script works 
(3) CODEBOOK.md describes the variables

also I uploaded "Tidy_data_set.txt" created in step 5 of the instructions using write.table() using row.name=FALSE

I also uploaded a link to a Github repo containing 3 files

Assignment: Getting and Cleaning Data Course Project
Instructions

The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set.
Review criterialess 

(1) The submitted data set is tidy.
(2) The Github repo contains the required scripts.
(3) GitHub contains a code book that modifies and updates the available codebooks with the data to indicate all the variables and summaries calculated, along with units, and any other relevant information.
(4) The README that explains the analysis files is clear and understandable.
(5) The work submitted for this project is the work of the student who submitted it.

Getting and Cleaning Data Course Projectless 
The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 

1) a tidy data set as described below, 
2) a link to a Github repository with your script for performing the analysis, 
3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. 

You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Here are the data for the project:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

You should create one R script called run_analysis.R that does the following.

(1) Merges the training and the test sets to create one data set.
(2) Extracts only the measurements on the mean and standard deviation for each measurement.
(3) Uses descriptive activity names to name the activities in the data set
(4) Appropriately labels the data set with descriptive variable names.
(5) From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

STEP 0. Loading the data to hard drive.
setting working directory 

filesPath <- "C:/Users/Andrey/Desktop/Coursera John Hopkins Big Data/3_Getting and Cleaning Data"
setwd(filesPath)
if(!file.exists("./dataset")){dir.create("./dataset")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./dataset/Data.zip")

unzip file creates automatically new directory "UCI HAR Dataset"

unzip(zipfile="./dataset/Data.zip",exdir="./dataset")

loading necessary packages

library(dplyr)
library(data.table)
library(tidyr)

Read SUBJECT, ACTIVITY, DATA files 

filesPath <- "C:/Users/Andrey/Desktop/Coursera John Hopkins Big Data/3_Getting and Cleaning Data/dataset/UCI HAR Dataset"

reading data Files

Train <- tbl_df(read.table(file.path(filesPath, "train", "X_train.txt" )))
Test  <- tbl_df(read.table(file.path(filesPath, "test" , "X_test.txt" )))

reading activity files 

ActivityTrain <- tbl_df(read.table(file.path(filesPath, "train", "y_train.txt")))
ActivityTest  <- tbl_df(read.table(file.path(filesPath, "test" , "y_test.txt" )))

reading subject files

SubjectTest  <- tbl_df(read.table(file.path(filesPath, "test" , "subject_test.txt" )))
SubjectTrain <- tbl_df(read.table(file.path(filesPath, "train", "subject_train.txt")))


STEP 1. Merges the training and the test sets to create one data set.

combine SUBJECT: train and test sets

MergedSubject <- rbind(SubjectTrain, SubjectTest)
setnames(MergedSubject, "V1", "subject")

combine ACTIVITY: train and test sets

MergedActivity<- rbind(ActivityTrain, ActivityTest)
setnames(MergedActivity, "V1", "activityNum")

combine DATA: train and test sets

MergedData <- rbind(Train, Test)

#assign variables according to features 

Features <- tbl_df(read.table(file.path(filesPath, "features.txt")))
setnames(Features, names(Features), c("featureNum", "featureName"))
colnames(MergedData) <- Features$featureName

col names for activity tables

activityLabels <- tbl_df(read.table(file.path(filesPath, "activity_labels.txt")))
setnames(activityLabels, names(activityLabels), c("activityNum","activityName"))

merging columns

MergedSubject <- cbind(MergedSubject, MergedActivity)
MergedData <- cbind(MergedSubject, MergedData)


STEP 2. Extracts only the measurements on the mean and standard deviation for each measurement.

FeaturesMeanStd <- grep("mean\\(\\)|std\\(\\)",Features$featureName,value=TRUE)
FeaturesMeanStd <- union(c("subject","activityNum"), FeaturesMeanStd)
MergedData <- subset(MergedData, select = FeaturesMeanStd)

STEP 3. Uses descriptive activity names to name the activities in the data set

MergedData <- merge(activityLabels, MergedData , by="activityNum", all.x=TRUE)
MergedData$activityName <- as.character(MergedData$activityName)
dataAggr<- aggregate(. ~ subject - activityName, data = MergedData, mean)
MergedData <- tbl_df(arrange(dataAggr,subject,activityName))


STEP 4. Appropriately labels the data set with descriptive variable names. 

we check what Names we had before

head(str(MergedData),2)

names(MergedData)<-gsub("std()", "SD", names(MergedData))
names(MergedData)<-gsub("mean()", "MEAN", names(MergedData))
names(MergedData)<-gsub("^t", "time", names(MergedData))
names(MergedData)<-gsub("^f", "frequency", names(MergedData))
names(MergedData)<-gsub("Acc", "Accelerometer", names(MergedData))
names(MergedData)<-gsub("Gyro", "Gyroscope", names(MergedData))
names(MergedData)<-gsub("Mag", "Magnitude", names(MergedData))
names(MergedData)<-gsub("BodyBody", "Body", names(MergedData))

now we check Names after
head(str(MergedData),6)

STEP 5. From the data set in step 4, creates a second, 
independent tidy data set with the average of each variable 
for each activity and each subject.

write.table(MergedData, "TidyDataSet.txt", row.name=FALSE)