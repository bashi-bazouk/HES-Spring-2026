credit <- read.csv("/cloud/project/Data/credit.csv")
str(credit)
head(credit,10)
table(credit$checking_balance)
table(credit$savings_balance)
summary(credit$months_loan_duration)
summary(credit$amount)
table(credit$default)
#changing the default indicator to Yes and No
credit$default<- factor(credit$default, levels = c("1", "2"),labels = c("No", "Yes"))
table(credit$default)

#Data preparation – creating random training and test datasets
#We will use 90 percent of the data for training and 10 percent for testing, 
#which will provide us with 100 records to simulate new applicants.

nrow(credit)
set.seed(123)
train_sample <- sample(nrow(credit), 900)
str(train_sample)

credit_train <- credit[train_sample, ]
credit_test  <- credit[-train_sample, ]
#If randomization was done correctly, we should have about 30 percent of loans with default in each of the datasets
prop.table(table(credit_train$default))


#install.packages("C50")
library(C50)
credit_model <- C5.0(credit_train[-17], credit_train$default) #credit_train[-17] take out the dependent variable default
#The credit_model object now contains a C5.0 decision tree.
credit_model
summary(credit_model)

#The first three lines could be represented in plain language as:
#1.If the checking account balance is unknown or greater than 200 DM, then classify as "not likely to default."
#2.Otherwise, if the checking account balance is less than zero DM or between one and 200 DM…
#3… and the credit history is perfect or very good, then classify as "likely to default."

plot(credit_model)
#install.packages("partykit")
#library(partykit)

#evaluating model performance
#To apply our decision tree to the test dataset, we use the predict() function as shown in the following line of code:

credit_pred <- predict(credit_model, credit_test)

#This creates a vector of predicted class values, which we can compare to the actual class values using the CrossTable() function in the gmodels package. Setting the prop.c and prop.r parameters to FALSE removes the column and row percentages from the table. The remaining percentage (prop.t) indicates the proportion of records in the cell out of the total number of records:

library(gmodels)
CrossTable(credit_test$default, credit_pred,prop.chisq = FALSE, prop.c = FALSE, prop.r = FALSE, dnn = c('actual default', 'predicted default'))

# Create confusion matrix
library(caret)
confusion_matrix <- confusionMatrix(as.factor(credit_pred),as.factor(credit_test$default),mode="prec_recall", positive = "Yes")
confusion_matrix


#ROC Curve

prob<-predict(credit_model, credit_test,type="prob")
library(pROC)
par(mfrow=c(1,1))
credit_roc <- roc(credit_test$default,prob[,2],levels=c("Yes", "No"))
plot.roc(credit_roc,print.auc=TRUE,main = "Credit curve ", col = "blue", lwd = 2, legacy.axes = TRUE)
#auc
auc(credit_roc)
#confidence interval for auc
#ci(credit_roc, of = "auc")

############################
#improving model performance
############################

#Boosting
#The C5.0() function makes it easy to add boosting to our decision tree. We simply need to add an additional trials parameter indicating 
#the number of separate decision trees to use in the boosted team. The trials parameter sets an upper limit; the algorithm will stop adding 
#trees if it recognizes that additional trials do not seem to be improving the accuracy. We'll start with 10 trials, a number that has become 
#the de facto standard, as research suggests that this reduces error rates on test data by about 25 percent. Aside from the new parameter, 
#the command is similar to before:

credit_boost10 <- C5.0(credit_train[-17], credit_train$default,trials = 10)
summary(credit_boost10)

credit_boost_pred10 <- predict(credit_boost10, credit_test)

confusion_matrix_boost <- confusionMatrix(as.factor(credit_boost_pred10),as.factor(credit_test$default),mode="prec_recall", positive = "Yes")
confusion_matrix_boost

###########################################
#Making some mistakes cost more than others
############################################
#Giving a loan to an applicant who is likely to default can be an expensive mistake. One solution to reduce the number of false 
#negatives may be to reject a larger number of borderline applicants under the assumption that the interest that the bank would earn 
#from a risky loan is far outweighed by the massive loss it would incur if the money is not paid back at all.

#To begin constructing the cost matrix, we need to start by specifying the dimensions. Since the predicted and actual values can both 
#take two values, yes or no, we need to describe a 2x2 matrix using a list of two vectors, each with two values. At the same time, 
#we'll also name the matrix dimensions to avoid confusion later on:

matrix_dimensions <- list(c("No", "Yes"), c("No", "Yes"))
names(matrix_dimensions) <- c("predicted", "actual")
matrix_dimensions
#Examining the new object shows that our dimensions have been set up correctly:

error_cost <- matrix(c(0, 1, 4, 0), nrow = 2,dimnames = matrix_dimensions)
error_cost


credit_cost <- C5.0(credit_train[-17], credit_train$default,costs = error_cost)
credit_cost_pred <- predict(credit_cost, credit_test)

confusion_matrix_cost <- confusionMatrix(as.factor(credit_cost_pred ),as.factor(credit_test$default),mode="prec_recall", positive = "Yes")
confusion_matrix_cost

#Compared to our boosted model, this version makes more mistakes overall: 41 percent error here versus 18 percent in the boosted case.
#However, the types of mistakes are very different. Where the previous models classified only 42 and 61 percent of defaults correctly, 
#in this model, 26 / 33 = 79% of the actual defaults were correctly predicted to be defaults. This trade-off resulting in a reduction 
#of false negatives at the expense of increasing false positives may be acceptable if our cost estimates were accurate.


### Random Forest

library(randomForest)
RNGversion("3.5.2")
set.seed(300)
rf <- randomForest(default ~ ., data = credit)
rf

#The output shows that the random forest included 500 trees and tried four variables at each split, as expected. At first glance, you might be alarmed at the seemingly poor performance according to the confusion matrix—the error rate of 24.3 percent is far worse than the resubstitution error of any of the other ensemble methods so far. However, this confusion matrix does not show resubstitution error. Instead, it reflects the out-of-bag error rate (listed in the output as OOB estimate of error rate), which, unlike resubstitution error, is an unbiased estimate of the test set error. This means that it should be a fairly reasonable estimate of future performance.
#The out-of-bag estimate is computed during the construction of the random forest. Essentially, any example not selected for a single tree's bootstrap sample can be used to test the model's performance on unseen data. At the end of the forest construction, for each of the 1,000 examples in the dataset, the trees that did not use the example in training are allowed to make a prediction. These predictions are tallied for each example and a vote is taken to determine the single final prediction for the example. The total error rate of such predictions becomes the out-of-bag error rate.

credit_rf_pred <- predict(rf, credit_test)

confusion_matrix_rf <- confusionMatrix(as.factor(credit_rf_pred),as.factor(credit_test$default),mode="prec_recall", positive = "Yes")
confusion_matrix_rf


### Bagging

#Bagging is One of the first ensemble methods to gain widespread acceptance used a technique called bootstrap aggregating, or bagging for short. As described by Leo Breiman in 1994, bagging generates a number of training datasets by bootstrap sampling the original training data. These datasets are then used to generate a set of models using a single learning algorithm. The models' predictions are combined using voting (for classification) or averaging (for numeric prediction).
#Although bagging is a relatively simple ensemble, it can perform quite well as long as it is used with relatively unstable learners, that is, those generating models that tend to change substantially when the input data changes only slightly. Unstable models are essential in order to ensure the ensemble's diversity in spite of only minor variations between the bootstrap training datasets. For this reason, bagging is often used with decision trees, which have the tendency to vary dramatically given minor changes in input data.

#The ipred package offers a classic implementation of bagged decision trees. To train the model, the bagging() function works similarly to many of the models used previously. The nbagg parameter is used to control the number of decision trees voting in the ensemble (with a default value of 25). Depending on the difficulty of the learning task and the amount of training data, increasing this number may improve the model's performance, up to a limit. The downside is that this creates additional computational expense, and a large number of trees may take some time to train.

#After installing the ipred package, we can create the ensemble as follows. We'll stick to the default value of 25 decision trees:
  
  
library(ipred)
RNGversion("3.5.2")
set.seed(300)
mybag <- bagging(default ~ ., data = credit, nbagg = 25)

#The resulting model works as expected with the predict() function:
  
  
credit_pred <- predict(mybag, credit)
table(credit_pred, credit$default)

credit_rf_pred <- credit_pred

confusion_matrix_bagging <- confusionMatrix(as.factor(credit_rf_pred),as.factor(credit$default),mode="prec_recall", positive = "Yes")
confusion_matrix_bagging
#Given the preceding results, the model seems to have fit the training data extremely well. 
#To see how this translates into future performance, we can use the bagged trees with 10-fold CV using the train() function in the caret package. 
#Note that the method name for the ipred bagged trees function is treebag:
  
  
library(caret)
RNGversion("3.5.2")
set.seed(300)
ctrl <- trainControl(method = "cv", number = 10)
mybagcv<-train(default ~ ., data = credit, method = "treebag",trControl = ctrl)
mybagcv

credit_pred <- predict(mybagcv, credit)
confusion_matrix_bagging_cv <- confusionMatrix(as.factor(credit_pred),as.factor(credit$default),mode="prec_recall", positive = "Yes")
confusion_matrix_bagging_cv


# Calculating Shapley Values for Regression Tree
library(iml)
library(DALEX)

# Wrap in Predictor object
predictor <- Predictor$new(
  model = credit_cost,
  data = credit_train[-17],
  y = credit_train$default
)

# Compute Shapley values for one observation
shap <- Shapley$new(predictor, x.interest = credit_train[-17])

# View results
shap$results
plot(shap)

