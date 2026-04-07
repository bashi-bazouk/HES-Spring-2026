Blood.Pressure <- read.csv("/cloud/project/Data/Blood.Pressure.csv")
g<-lm(Y~X,data=Blood.Pressure)
summary(g)
par(mfrow=c(2,2))
plot(g)

#1st Iteration
ei<-g$residuals
abs.ei<-abs(ei)
g1<-lm(abs.ei~Blood.Pressure$X)
summary(g1)
s<-g1$fitted.values
wi=1/(s^2)

g2<-lm(Y~X,weights= wi, data=Blood.Pressure)
summary(g2)
par(mfrow=c(2,2))
plot(g2)

#2nd iteration - one more iteration
ei<-g2$residuals
abs.ei<-abs(ei)
g3<-lm(abs.ei~Blood.Pressure$X)
summary(g3)
s<-g3$fitted.values
wi=1/(s^2)
g4<-lm(Y~X,weights= wi, data=Blood.Pressure)
summary(g4)
plot(g4)

#Robust Regression

library(olsrr)
ols_plot_cooksd_chart(g)

#Studentized Residual Plot
ols_plot_resid_stud(g)

####Studentized Residuals vs Leverage Plot ####

ols_plot_resid_lev(g)

####Deleted Studentized Residual vs Fitted Values Plot####

ols_plot_resid_stud_fit(g)


rr.huber <- rlm(Y ~., data = Blood.Pressure)
summary(rr.huber)
hweights <- data.frame(Obs = c(1:54), resid = rr.huber$resid, weight = rr.huber$w)
hweights2 <- hweights[order(rr.huber$w), ]
hweights2[1:15, ]

#Next, let’s run the same model, but using the bisquare weighting function

rr.bisquare <- rlm(Y ~ X, data=Blood.Pressure, psi = psi.bisquare)
summary(rr.bisquare)

biweights <- data.frame(Obs = c(1:54), resid = rr.bisquare$resid, weight = rr.bisquare$w)
biweights2 <- biweights[order(rr.bisquare$w), ]
biweights2[1:15, ]

comp<-rbind(g$coefficients,rr.huber$coefficients,rr.bisquare$coefficients)
dimnames(comp)[[1]]<-c("Regression","Huber","Bisqure")
dimnames(comp)[[2]]<-c("Beta0","Beta1")
comp

#When comparing the results of a regular OLS regression and a robust regression, if the results are 
#very different, you will most likely want to use the results from the robust regression. 
#Large differences suggest that the model parameters are being highly influenced by outliers.
#Different functions have advantages and drawbacks. Huber weights can have difficulties with severe 
#outliers, and bisquare weights can have difficulties converging or may yield multiple solutions.



