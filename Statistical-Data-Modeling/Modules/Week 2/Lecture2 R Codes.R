#install library caret
#install.packages("caret")
library(caret)
toluca_data <- read.csv("/cloud/project/Data/toluca_data.csv")
head(toluca_data)

# fitting the regression model 
toluca.reg <- lm(workhrs ~ lotsize,data=toluca_data)
# getting the summary regression output:
summary(toluca.reg)
# getting the ANOVA table:
anova(toluca.reg)
# getting the fitted values:
fitted(toluca.reg)
# getting the residuals:
names(toluca.reg)
resid(toluca.reg)
toluca.reg$residuals
plot(toluca_data$lotsize, toluca_data$workhrs)
# overlaying the regression line on this scatter plot:
abline(toluca.reg)

#ANOVA Table
anova(toluca.reg)

#prediction intervals for the reg coefficients
confint(toluca.reg,level=0.95)

#lets predict worhours for lotsize of 100
predict(toluca.reg,data.frame(lotsize=100))

#Lets calculate the confidence 90% interval for our prediction
predict(toluca.reg,data.frame(lotsize=100),interval = "confidence",level = 0.90)

#Lets calculate the confidence 90% interval for our prediction for a NEW OBSERVATION
predict(toluca.reg,data.frame(lotsize=100),interval = "prediction",level = 0.90)

#Regression Bands
#let get the prediction variances and predictions
bd<-predict(toluca.reg,toluca_data,se.fit=TRUE)
#examine bd, it has 3 outputs, fits, se.fit, and degree of freedom

CB_lower<-bd$fit-sqrt(qf(1-0.05,2,bd$df))*bd$se.fit
CB_upper<-bd$fit+sqrt(qf(1-0.05,2,bd$df))*bd$se.fit

plot(toluca_data$lotsize, toluca_data$workhrs)
abline(toluca.reg)
d1<-data.frame(lotsize=toluca_data$lotsize,CB_lower,CB_upper)            
lines(d1$lotsize,d1$CB_lower,lty=2,lwd=2,col="green")
lines(d1$lotsize,d1$CB_upper,lty=2,lwd=2,col="red")

#GLM Test
#lets fit a model without X

#Ho:B1=0
#Ha:B1 not equal to 0

#model without lotsize
toluca.reg.red <- lm(workhrs ~ 1,data=toluca_data)
summary(toluca.reg.red)
toluca.reg.red$fitted.values
summary(toluca_data)

#GLM TEST
anova(toluca.reg.red,toluca.reg)
#P value is 4.449e-10 < 0.05, Reject Ho. Accept Ha. Lotsize is significant
