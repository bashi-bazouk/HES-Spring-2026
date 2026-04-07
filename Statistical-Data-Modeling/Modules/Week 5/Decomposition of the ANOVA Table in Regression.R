BodyFat <- read.csv("/cloud/project/Data/Body Fat.csv")
head(BodyFat)

f<-lm(Y~X1+X2+X3,data=BodyFat)
summary(f)
anova(f)

#getting SST
#1st way
var(BodyFat$Y)*(length(BodyFat$Y)-1)
#2nd way
b=anova(f)
sum(b$`Sum Sq`)
#Understanding ANOVA TABLE
#all SLRs
f.x1<-f<-lm(Y~X1,data=BodyFat)
f.x2<-f<-lm(Y~X2,data=BodyFat)
f.x3<-f<-lm(Y~X3,data=BodyFat)
anova(f.x1)
anova(f.x2)
anova(f.x3)

f.X12<-lm(Y~X1+X2,data=BodyFat)
anova(f.X12)