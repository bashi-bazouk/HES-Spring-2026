---
  title: "R Notebook"
output: html_notebook
---
  
library(olsrr)  
  
###### Hat values for each observation ######

Dataset10TA01 <- read.csv("/cloud/project/Data/Dataset_10TA01.csv")
f1<-lm(Y~X1+X2,data=Dataset10TA01)
hii <- hatvalues(f1)
hii

X<-model.matrix(f1)
XXInv<-solve(t(X)%*%X)
Hat.Matrix<-X%*%XXInv%*%t(X)
influence.measures(f1)

## 1-Heteroscedasticity

#Breusch Pagan Test
ols_test_breusch_pagan(f1)

## 2- Multicollinearity
ols_vif_tol(f1)


## 3-Normality

## QQ Plot
ols_plot_resid_qq(f1)

###Normality test

ols_test_normality(f1)
#kolmogorv smirnov statistic
#shapiro wilk statistic
#cramer von mises statistic
#anderson darling statistic

###4-Residual vs Fitted Values 

#The residuals spread randomly around the 0 line indicating that the relationship is linear.
#The residuals form an approximate horizontal band around the 0 line indicating homogeneity of error variance.
#No one residual is visibly away from the random pattern of the residuals indicating that there are no outliers.

## Residual vs Fitted Plot
ols_plot_resid_fit(f1)

#Residual Histogram
#Histogram of residuals for detecting violation of normality assumption.

ols_plot_resid_hist(f1)

### Studentized Residual Plot ####
ols_plot_resid_stud(f1)

### Standardized Residual Chart ####
ols_plot_resid_stand(f1)

####Deleted Studentized Residual vs Fitted Values Plot####
#Graph for detecting outliers.

ols_plot_resid_stud_fit(f1)

### 5-Infuential Points

### Cooks distance plot####
library(olsrr)
ols_plot_cooksd_bar(f1)
ols_plot_cooksd_chart(f1)
ols_leverage(f1)

####Studentized Residuals vs Leverage Plot ####
#Graph for detecting influential observations.

#Studentized residuals vs leverage plot
ols_plot_resid_lev(f1)

#Deleted studentized residual vs fitted values plot
ols_plot_resid_stud_fit(f1)

#Potential residual plot
#Plot to aid in classifying unusual observations as high-leverage points, outliers, #or a combination of both.
ols_plot_resid_pot(f1)

### CDFBETAs####
n=dim(Dataset10TA01)[1]
cutoff= 2/sqrt(n)
ols_plot_dfbetas(f1)

### DFFITS Plots####
p=3
cutoff= 2*sqrt((p+1)/(n-p-1))
ols_plot_dffits(f1)
