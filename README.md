# Kaggle-Competition-1-Bike-Sharing

The purpose of this project is to practice different data science methods to predict the number of bike shares, based on data collected about the number of bike shares per day. 

The "BikeSharingRCode" file contains my R code used to clean the data, feature engineer, run models, and predict new variables. 

The "boosting_submission" file contains the Kaggle submission based on my predictions from the first gradient boosting model I used.

The "boosting_submission2" file contains the Kaggle submission based on my predictions from the second gradient boostind model I used.

The "Submission_2" file contains the Kaggle submission based on a random forest model I used.

The "test" file contains the test dataset (provided by Kaggle).

The "train" file contains the training dataset (provided by Kaggle).

For data cleaning and feature engineering, I created new variables that I thought would be helpful in predicting new responses. These include "hour", "weekday", "month", and "season". I used target-encoding for each of these categorical variables.

I used random forest and gradient boosting to generate predictions about bike share counts.

