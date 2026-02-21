#Least Square Example
y<-c(5,12,10)
x<-c(20,55,30)
f<-lm(y~x)
summary(f)
plot(x,y,xlab="Age",ylab="Number of Hours",main="Y=2.81 + 0.177X")
abline(f)
m1.y=rep(mean(y),3)
m2.y=rep(mean(y[c(1,3)],3))
m3.y=f$fitted.values

m1.e=y-m1.y
m2.e=y-m2.y
m3.e=f$residuals
output=round(cbind(m1.e,m2.e,m3.e),3)
apply(output, 2, sum) #Sum
apply(output, 2, mean) #Average
apply(abs(output), 2, sum) #Absolute sum
apply(output^2, 2, sum) #Sum of squares



######################
### Toluca Example ###
######################


toluca_data <- toluca_data <- read.csv("/cloud/project/Data/toluca_data.csv")
head(toluca_data)

attach(toluca_data)
# fitting the regression model 
toluca.reg <- lm(workhrs ~ lotsize)
# getting the summary regression output:
toluca.reg <- lm(workhrs ~ lotsize)
# getting the ANOVA table:
anova(toluca.reg)
# getting the fitted values:
fitted(toluca.reg)
# getting the residuals:
names(toluca.reg)
resid(toluca.reg)
toluca.reg$residuals
plot(lotsize, workhrs)
# overlaying the regression line on this scatter plot:
abline(toluca.reg)

#####################
##Antioxidant Data ##
#####################
lager_antioxidant_reg <- read.csv("/cloud/project/Data/lager_antioxidant_reg.csv .csv")

f1<-lm(tpc~ma,data=lager_antioxidant_reg)
f2<-lm(tpc~dsa,data=lager_antioxidant_reg)
f3<-lm(tpc~asa,data=lager_antioxidant_reg)
f4<-lm(tpc~orac,data=lager_antioxidant_reg)
f5<-lm(tpc~rp,data=lager_antioxidant_reg)
f6<-lm(tpc~mca,data=lager_antioxidant_reg)
attach(lager_antioxidant_reg)
par(mfrow=c(2,3))
plot(ma,tpc);abline(f1)
plot(dsa,tpc);abline(f2)
plot(asa,tpc);abline(f3)
plot(orac,tpc);abline(f4)
plot(rp,tpc);abline(f5)
plot(mca,tpc);abline(f6)

### CODE ####
prg1<-function(x){        
  out1<-list({})        
  out2<-data.frame(matrix(0,nrow=6,ncol=2))
  for (i in 1:6){                
    out1[[i]]<-lm(x[,2]~x[,2+i],data=x)                
    out2[i,]<-cbind(dimnames(x)[[2]][2+i],round(sum(out1[[i]]$residuals^2),2))
  }    
  dimnames(out2[[2]])[[2]]<c("X","SSE")    
  list(out1,out2)
}
prg1(lager_antioxidant_reg)
