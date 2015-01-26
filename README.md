Getting and Cleaning Data - Project
===================================

Task
----
Purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. 
 
You will be graded by your peers on a series of yes/no questions related to the project. 
 
You will be required to submit: 

1) a tidy data set as described below, 

2) a link to a Github repository with your script for performing the analysis, and 

3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. 

You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.  

Data
----
1) https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 


Packages required
-----------------
* install.packages("dplyr")
* library("dplyr")
* install.packages("data.table")
* library("data.table")


Running this script
-------------------
1) https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
```{r}
install.packages("downloader")
library("downloader")
url < - "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download(url,dest="dataset.zip" mode = "wb") 
unzip ("dataset.zip",exdir = "./")
```
2) install packages

3) source("run_analysis.R")



Data processing steps
---------------------

.1. Read in train & test data for SUBJECTS first  (then activity)
```{r}
trainingX <- read.table("UCI HAR Dataset/train/X_train.txt")
trainingX <- data.table(trainingX)
```

.2. Remove data columns that are not std & mean
```{r}
trainingX <- trainingX[, features$V1, with = FALSE]
```

.3. Same again for Test data as for training data
```{r}
testX <- read.table("UCI HAR Dataset/test/X_test.txt")
testX <- data.table(testX)
```

.4. Remove data that is not std & mean  
```{r}
testX <- testX[, features$V1, with = FALSE]
```

.5. Merge Training X set with Test X set 
```{r}
combinedFeaturesList = list(trainingX,testX)
combinedFeatures <- rbindlist(combinedFeaturesList, use.names = TRUE)
```

.6. Add labels to top of the combinedFeatures Data Table
   Features has just the labels, that we reduced down earlier, to select just the columns from combinedFeatures (X data)
```{r}
setnames(combinedFeatures, names(combinedFeatures), as.character(features[,V2]))
```

.7. Now do the same for Y the training and test Activity data (not the SUBJECT)
```{r}
trainingY <- read.table("UCI HAR Dataset/train/y_train.txt")
```

.8. Swap data.frame to a data.table
```{r}
testY <- read.table("UCI HAR Dataset/test/y_test.txt")
```

.9. Combine the test and training activity
```{r}
combinedActivityList = list(trainingY, testY)
combinedActivity <- rbindlist(combinedActivityList, use.names = TRUE)
```

.10. Attach to activity codes to the activity labels in activity_labels.txt
```{r}
allActivity<- read.table("UCI HAR Dataset/activity_labels.txt")
combinedActivity$activity <- factor(combinedActivity$V1, levels = allActivity$V1, labels = allActivity$V2)
```

.11. Combine the train and test subject, do this on their "ids"
```{r}
subjectsTrain <- read.table("UCI HAR Dataset/train/subject_train.txt")
subjectTest <- read.table("UCI HAR Dataset/test/subject_test.txt")
```

.12. Combine the subject test & train
```{r}
combinedSubjectsList = list(subjectsTrain, subjectTest)
combinedSubjects <- rbindlist(combinedSubjectsList, use.names = TRUE)
```

.13. Now combine subjects with activities using column bind
```{r}
subjectActivity <- cbind(combinedSubjects, combinedActivity$activity)
```

.14. Label the totalSubjectActivity 
```{r}
setnames(subjectActivity,names(subjectActivity), c("subject.id", "activity"))
```

.15. Postfix the measurements of the required features
```{r}
allActivities <- cbind(subjectActivity, combinedFeatures)
```

.16. Put it all together from the set produced for analysis, compute and report means of all measures, grouped by subject_id and by activity.
```{r}
consummation <- aggregate(subset(allActivities, ,3:81), by = list(allActivities$subject.id, allActivities$activity), FUN = mean)
```

.17. Set the labels on the first two columns subject ID and activity
```{r}
setnames(consummation,c("Group.1", "Group.2"), c("subject.id", "activity"))
```

.18. Save the output to disk
```{r}
write.table(consummation, file="TidySmartPhoneData.txt", quote=FALSE, sep="\t" ,row.names = FALSE)
```

Output
------
1) File in working dir (getwd()) called TidySmartPhoneData.txt
