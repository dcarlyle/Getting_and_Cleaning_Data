# Getting and cleaning data
#
# URL: https://class.coursera.org/getdata-010
# 
# Course project
# load : source("run_analysis.R")
#
# Items to submit: 
# 1) a tidy data set as described below, 
# 2) a link to a Github repository with your script for performing the analysis, and 
# 3) a code book that describes the variables, 
# 
# The data, and any transformations or work that you performed to clean up the data called CodeBook.md. 
# 
# You should also include a README.md in the repo with your scripts. 
# 
# Data collected from the accelerometers from the Samsung Galaxy S smartphone, is located at:
#  http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 
#  
#  Here are the data for the project (needs to be in the same folder as the script): 
#  https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
# 
# Required to create one R script called run_analysis.R that does the following. 
# 1) Merges the training and the test sets to create one data set.
# 2)Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3) Uses descriptive activity names to name the activities in the data set
# 4) Appropriately labels the data set with descriptive variable names. 
# 5) From the data set in step 4, creates a second, independent tidy data set with the average of each variable  for each activity and each subject.
   
###############################################################################################

# To run the project
# 1) unpack data https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip into working dir (getwd())
# 2) run run_analysis.R from the working dir
   
###############################################################################################

# OUTPUT: "TidySmartPhoneData.txt" with tidy combined smartphone data

# use Data sets instead of data frames
#install.packages("dplyr")
#library("dplyr")
#install.packages("data.table")
#library("data.table")

# DOWNLOAD Data 
#  install.packages("downloader")
#  library("downloader")
#  url < - "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
#  download(url,dest="dataset.zip" mode = "wb") 
#  unzip ("dataset.zip",exdir = "./")

# Load data in a data.frame
# - 'features.txt': List of all features
allFeatures <- read.table("UCI HAR Dataset/features.txt")

# swap data.frame to a data.table
allFeatures <- data.table(allFeatures)

# Get the labels for rows with STD and MEAN 
# could use grep, but data.tables support Like and in. Note that %like% and like() use grepl (returns logical vector) rather than grep (returns integer locations). 
# ref: http://stackoverflow.com/questions/14630335/how-to-select-r-data-table-rows-based-on-substring-match-a-la-sql-like
# features <- subset(allFeatures, V2 %like% "mean()" & !(V2 %like% "meanFreq()") | V2 %like% "std()" & !(V2 %like% "stdFreq()") )
# Above allows us to exclude frequencies
features <- subset(allFeatures, V2 %like% "mean()" | V2 %like% "std()" )
# test - that sets below match
all.equal(key(features), key(allFeatures))

# This gives us pn looking at head:
# > head(features, 1)
#   V1                V2
#1:  1 tBodyAcc-mean()-X
#
# V1 shows the columns we want and V2 shows us the STD and Mean Labels (we have removed the other labels we are not interested in)
#
# Now we need to take the Data sets and remove the columns we don't want

# Get train & test data for SUBJECTS first  (then activity)
trainingX <- read.table("UCI HAR Dataset/train/X_train.txt")
trainingX <- data.table(trainingX)
# remove data columns that are not std & mean
# NOTE: As far as I can tell from ?data.table:, the argument is named "with" because it determines whether the column index should 
# be evaluated within the frame of the data.table, as it would be when using, e.g., base R's with() and within().
# could do a subset command - http://www.inside-r.org/packages/cran/data.table/docs/subset.data.table
# trainingX <- subset(trainingX, V1 = features$V1)
# old way of doing it - 
trainingX <- trainingX[, features$V1, with = FALSE]

# Same again for Test data as for training data
testX <- read.table("UCI HAR Dataset/test/X_test.txt")
testX <- data.table(testX)
# remove data that is not std & mean  
# check labels on testX with names(testX)
#testX <- subset(testX, V1 = features$V1)
testX <- testX[, features$V1, with = FALSE]


# Merge Training X set with Test X set 
# old way with rbind - combinedFeatures <- rbind(trainingX, testX)
# use rbindlist http://cran.r-project.org/web/packages/data.table/data.table.pdf
combinedFeaturesList = list(trainingX,testX)
combinedFeatures <- rbindlist(combinedFeaturesList, use.names = TRUE)

# Add labels to top of the combinedFeatures Data Table
# Features has just the labels, that we reduced down earlier, to select just the columns from combinedFeatures (X data)
setnames(combinedFeatures, names(combinedFeatures), as.character(features[,V2]))

# Now do the same for Y the training and test Activity data (not the SUBJECT)
trainingY <- read.table("UCI HAR Dataset/train/y_train.txt")
# swap data.frame to a data.table
#trainingY <- data.table(trainingY)
testY <- read.table("UCI HAR Dataset/test/y_test.txt")

# Combine the test and training activity
combinedActivityList = list(trainingY, testY)
combinedActivity <- rbindlist(combinedActivityList, use.names = TRUE)

# Attach to activity codes to the activity labels in activity_labels.txt
allActivity<- read.table("UCI HAR Dataset/activity_labels.txt")
combinedActivity$activity <- factor(combinedActivity$V1, levels = allActivity$V1, labels = allActivity$V2)

# Combine the train and test subject, do this on their "ids"
subjectsTrain <- read.table("UCI HAR Dataset/train/subject_train.txt")
subjectTest <- read.table("UCI HAR Dataset/test/subject_test.txt")
# combine the subject test & train
combinedSubjectsList = list(subjectsTrain, subjectTest)
combinedSubjects <- rbindlist(combinedSubjectsList, use.names = TRUE)

# Now combine subjects with activities using column bind
subjectActivity <- cbind(combinedSubjects, combinedActivity$activity)
# Label the totalSubjectActivity 
setnames(subjectActivity,names(subjectActivity), c("subject.id", "activity"))

# Postfix the measurements of the required features
allActivities <- cbind(subjectActivity, combinedFeatures)

#############################
# From the set produced for analysis, compute and report means of all measures, grouped by subject_id and by activity.
consummation <- aggregate(subset(allActivities, ,3:81), by = list(allActivities$subject.id, allActivities$activity), FUN = mean)

# Set the labels on the first two columns subject ID and activity
setnames(consummation,c("Group.1", "Group.2"), c("subject.id", "activity"))
# Save the output to disk
write.table(consummation, file="TidySmartPhoneData.txt", quote=FALSE, sep="\t" ,row.names = FALSE)
