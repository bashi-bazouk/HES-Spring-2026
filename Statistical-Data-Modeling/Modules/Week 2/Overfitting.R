#install and load caret library

library(caret)
data(mtcars)
str(mtcars)
summary(mtcars)

#split the data into two parts 70-30 split
DataSplit<-createDataPartition(y = mtcars$mpg, p = 0.7, list = FALSE)

#creating the train and test data set

TrainData<-mtcars[DataSplit,]
TestData<-mtcars[-DataSplit,]

#fitting the model on the train data set
LmFit1<-train(mpg~., data = TrainData, method = "lm")
summary(LmFit1)


#performance of the model on the TrainData
#get the predicted values
PredictedTrain<-predict(LmFit1,TrainData)
#create a data frame with 2 columns actual and predicted values
ModelTrain<-data.frame(obs = TrainData$mpg, pred=PredictedTrain)
#calculate performance statistics
defaultSummary(ModelTrain)

#Root mean squared error (RMSE) is calculated using sqrt(mean((pred - obs)^2
#R Square is SSR/SST
#Mean absolute error (MAE) is calculated using mean(abs(pred-obs))

#we will compare these 3 statistics with that of test data

#getting the predicted values for the test data
PredictedTest<-predict(LmFit1,TestData)
#At this point, we have to build data.frame with the values of the current and estimated mpg variable to compare them:

#seeing model performance on the test data
ModelTest<-data.frame(obs = TestData$mpg, pred=PredictedTest)
#To see model performance metrics on the TestData sample, you can use a defaultSummary() function that, given two numeric vectors of data, calculates the mean squared error (MSE), the mean absolute error (MAE), and R-squared.

defaultSummary(ModelTest)

out<-rbind(defaultSummary(ModelTrain),defaultSummary(ModelTest))
dimnames(out)[[1]]<-c("Train","Test")
out
