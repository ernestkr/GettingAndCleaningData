# Getting And Cleaning Data (Course Project Programming Assignment)

## General info:
* The script (run_analysis.R) reads the data set inside the folder "test" and "train", and combine them. 
* Then, all the variables (columns) that are relevant to the measurements on the mean and standard deviation for each measurement are extracted. 
* The script will then append two columns describing the identity of the volunteer from whom the measurements were taken as well as the description on the activity being performed during the measurement.
* Finally, an independent tidy data set with the average of each variable for each activity and each subject are generated and saved into "TidyData.txt".

## Usage:
* Place the script run_analysis.R into the directory contining the data to be processed (UCI HAR Dataset).
* Make sure that there exist two subfolders named "test" and "train", and contain the relevant necessary files.
* Run the script to generate "TidyData.txt" containing the desired output.
* Note: the script may take some time to execute (approximately 8 minutes), depending on the processor speed.
