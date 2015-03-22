## Reading the information on the elements of the feature vector.
FeatureList <- read.csv("features.txt", header=FALSE, sep=" ", stringsAsFactors = FALSE)
## Reading the activity code and the corresponding description.
ActivityLabel <- read.csv("activity_labels.txt", header=FALSE, sep=" ", stringsAsFactors=FALSE)

## Read the training data set together with the accompanying subject ID and activity type
TrainSet <- read.csv("./train/X_train.txt", header = FALSE, stringsAsFactors = FALSE)
SubjectTrain <- read.csv("./train/subject_train.txt", header = FALSE, stringsAsFactors = FALSE)
ActivityTrain <- read.csv("./train/y_train.txt", header = FALSE, stringsAsFactors = FALSE)

## Read the test data set together with the accompanying subject ID and activity type.
TestSet <- read.csv("./test/X_test.txt", header = FALSE, stringsAsFactors = FALSE)
SubjectTest <- read.csv("./test/subject_test.txt", header = FALSE, stringsAsFactors = FALSE)
ActivityTest <- read.csv("./test/y_test.txt", header = FALSE, stringsAsFactors = FALSE)

## Merges the training and the test sets to create one data set.
TotalSet <- rbind(TrainSet, TestSet)
SubjectID <- rbind(SubjectTrain, SubjectTest)
ActivityDesc <- rbind(ActivityTrain, ActivityTest)

## Use the descriptive activity names to name the activities in the data set
for(i in 1:nrow(ActivityDesc)){
  ActivityDesc[i,1] = ActivityLabel[as.numeric(ActivityDesc[i,1]), 2]
}

## Identify the location of the measurements on mean and standard deviations
ExtractMean = lapply(FeatureList[,2], grepl, pattern="-mean()", fixed=TRUE)
ExtractStd = lapply(FeatureList[,2], grepl, pattern="-std()", fixed=TRUE)
## Extract only the measurements on the mean and standard deviation for each measurement
Selector = (as.logical(ExtractMean) | as.logical(ExtractStd))
FeatureList = FeatureList[Selector,]

## A function to perform the cleaning up of the data.
## It takes in as input a string that contain multiple values of interest,
## together with the location indices of the values to be returned.
ExtractData <- function(MyString, Sel){
  ## Split the string into a list containing of substrings separated by " "
  MyString <- strsplit(MyString, " ")
  ## Convert the list into vector
  MyString <- MyString[[1]]
  ## For each element on the vector, calculate its number of characters
  CharNum <- lapply(MyString, nchar)
  ## Remove all entries that are empty
  MyString <- MyString[CharNum > 0]
  ## The return is a length 561 feature vector as described by MyString
  MyString[Sel]
}

## Create a data frame to store the result. Initialize the first entry with all zeros
ResultDF = data.frame(Volunteer_Index = 0, Activity = 0)
## Append the data frame with the columns specified in the extracted Feature List
for (i in 1:nrow(FeatureList)){
  ResultDF[[FeatureList[i, 2]]] = 0
}

print("Populating the data frame with the values from the input file. Please wait...")
## Populate the data frame with the desired information from the original data set
for (i in 1:nrow(TotalSet)){
  ResultDF[i, 1] = SubjectID[i,1]
  ResultDF[i, 2] = ActivityDesc[i,1]
  ## Extract all the measurement values from the source file
  tempList = ExtractData(TotalSet[i,1], Selector)
  ## Assign the measurement values to the respective location
  ResultDF[i, 3:ncol(ResultDF)] = tempList
}

## Create a data frame to store the final result. Initialize the first entry with all zeros
FinalDF = data.frame(Volunteer_Index = 0, Activity = 0)
## Append the data frame with the columns specified in the extracted Feature List
for (i in 1:nrow(FeatureList)){
  FinalDF[[paste("AverageOf-",FeatureList[i, 2], sep="")]] = 0
}

print("Processing the average of each variable for final data set generation. Please wait...")
## Maintain the running index to keep track of the number of entries written so far
RunningIdx = 1
## Populate the data frame with the final result, grouped by the user and the activity type
for (userIdx in sort(unique(ResultDF$Volunteer_Index))){
  for (ActType in ActivityLabel[,2]){
    FinalDF[RunningIdx, 1] = userIdx
    FinalDF[RunningIdx, 2] = ActType
    ## Create a temporary data frame for the currently selected user and activity type
    tempDF = subset(ResultDF, Volunteer_Index == userIdx & Activity == ActType)
    ## Remote the first two columns as they should be excluded from the averaging operation
    tempDF$Volunteer_Index = NULL
    tempDF$Activity = NULL
    ## Assign the values of the average measurements to the respective location
    FinalDF[RunningIdx, 3:ncol(FinalDF)] = sapply(tempDF, function(x) mean(as.numeric(x), na.rm=TRUE))
    ## Increment the running index
    RunningIdx = RunningIdx + 1
  }
}

## Save the final tidy data set into a text file.
write.table(FinalDF, file="TidyData.txt", row.name=FALSE)
