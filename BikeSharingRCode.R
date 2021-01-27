##
## Code for Analyzing Bike Sharing Dataset
##

## Libraries I need
library(tidyverse)
library(DataExplorer)
library(caret)
library(vroom)
library(lubridate)

## Read in the data
system.time(bike.train <- read.csv("C:\\Users\\Matt\\Documents\\School\\Kaggle Class\\competition 1\\KaggleBikeSharing-main\\KaggleBikeSharing-main\\train.csv"))
system.time(bike.train <- vroom("C:\\Users\\Matt\\Documents\\School\\Kaggle Class\\competition 1\\KaggleBikeSharing-main\\KaggleBikeSharing-main\\train.csv"))
bike.test <- vroom("C:\\Users\\Matt\\Documents\\School\\Kaggle Class\\competition 1\\KaggleBikeSharing-main\\KaggleBikeSharing-main\\test.csv")
bike <- bind_rows(train=bike.train, test=bike.test, .id="id")

## Drop casual and registered
bike <- bike %>% select(-casual, -registered)

## Feature Engineering
bike$month <- month(bike$datetime) %>% as.factor()
bike$season <- as.factor(bike$season)
bike$day <- day(bike$datetime) %>% as.factor()

## Exploratory Plots
ggplot(data=bike, aes(x=datetime, y=count, color=as.factor(month))) +
  geom_point()
plot_missing(bike)
plot_correlation(bike, type="continuous",
                 cor_args=list(use='pairwise.complete.obs'))
ggplot(data=bike, aes(x=season, y=count)) + 
  geom_boxplot()

# create log of 'count'
bike$count_log <- log1p(bike$count)


## Dummy variable encoding - one-hot encoding
dummyVars(count_log ~ month, data=bike, sep="_") %>% 
  predict(bike) %>% as.data.frame() %>%
  bind_cols(bike %>% select(-month), .)

## Target encoding
bike$month <- lm(count_log ~ month, data=bike) %>% 
  predict(., newdata=bike %>% select(-count_log))

bike$season <- lm(count_log ~ season, data=bike) %>% 
  predict(., newdata=bike %>% select(-count_log))



## Fit some models 
## try season and then month
bike.model <- train(form = count ~ month + holiday + atemp + humidity,
                    data=bike %>% filter(id=='train'),
                    method="ranger",
                    tuneGrid= expand.grid(mtry = 1:4,
                                          splitrule = c('variance', 'extratrees'),
                                          min.node.size = c(1,3)),
                    trControl=trainControl(
                      method="repeatedcv",
                      number=10,
                      repeats=2)
)
plot(bike.model)
preds <- predict(bike.model, newdata=bike %>% filter(id=="test"))
submission2 <- data.frame(datetime=bike %>% filter(id=="test") %>% pull(datetime),
                         count=preds)

write.csv(x=submission2, file="C:\\Users\\Matt\\Documents\\School\\Kaggle Class\\KaggleBikeSharing-main\\KaggleBikeSharing-main\\Submission_2.csv", row.names=FALSE)                   



### try gradient boositng and log of response variable
library(gbm)


bike.boost = gbm(formula = count_log ~ month + holiday + atemp + humidity, 
                 data = bike %>% filter(id=='train'),
                  distribution = "gaussian", n.trees = 10000,
                  shrinkage = 0.01, interaction.depth = 4)
summary(bike.boost)

plot(bike.boost)

# predict new variables
boost.preds <- predict(bike.boost, newdata=bike %>% filter(id=="test"))

# exponentiate predictions
boost.preds.clean <- expm1(boost.preds)

# create submission 
boosting_submission <- data.frame(datetime = bike %>% 
                                    filter(id=="test") %>% 
                                    pull(datetime),
                         count = boost.preds.clean)

# create .csv of submission
write.csv(x=boosting_submission, 
          file="C:\\Users\\Matt\\Documents\\School\\Kaggle Class\\competition 1\\KaggleBikeSharing-main\\KaggleBikeSharing-main\\boosting_submission.csv", 
          row.names=FALSE)                   

## the following code is derived from a notebook I referenced on Kaggle
## create hour and weekday variable 

bike$hour <- hour(bike$datetime)
bike$weekday <- weekdays(bike$datetime)

# target encode for the new variables
bike$hour <- lm(count_log ~ hour, data=bike) %>% 
  predict(., newdata = bike %>% select(-count_log))

bike$weekday <- lm(count_log ~ hour, data=bike) %>% 
  predict(., newdata = bike %>% select(-count_log))


## use gradient boosting model

# use hour, weekday, month, season, holiday, atemp, humidity
bike.boost2 = gbm(formula = count_log ~ hour + weekday + season + month + holiday + atemp + humidity, 
                 data = bike %>% filter(id=='train'),
                  distribution = "gaussian", n.trees = 10000,
                  shrinkage = 0.01, interaction.depth = 4)

summary(bike.boost2)

plot(bike.boost2)

# predict new variables
boost.preds2 <- predict(bike.boost2, newdata=bike %>% filter(id=="test"))

# exponentiate predictions
boost.preds2.clean <- expm1(boost.preds2)

# create submission 
boosting_submission2 <- data.frame(datetime = bike %>% 
                                    filter(id=="test") %>% 
                                    pull(datetime),
                         count = boost.preds2.clean)

# create .csv of submission
write.csv(x=boosting_submission2, 
          file="C:\\Users\\Matt\\Documents\\School\\Kaggle Class\\competition 1\\KaggleBikeSharing-main\\KaggleBikeSharing-main\\boosting_submission2.csv", 
          row.names=FALSE)             
