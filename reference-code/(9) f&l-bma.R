library(BMA)
library(foreign)

### replace path
setwd("/Users/bnyhan/Documents/Research/BMA/Montgomery and Nyhan replication/")

fldata<-read.dta("data/fl-merged.dta")

attach(fldata)

y<-onset

x<-cbind(warl,gdpenl,lpopl1,lmtnest,ncontig,Oil,nwstate,instab,polity2l,ethfrac,relfrac,anocl,deml,
nwarsl,plural,plurrel,muslim,loglang,colfra,eeurop,lamerica,ssafrica,asia,nafrme,second)

## keep warl in all models; either the polity or regime type variables can be included

memory.limit(4000) # comment this line out if you are not on Windows

bicfl<-bic.glmMN(x, y, glm.family="binomial", strict=FALSE, factor.type=TRUE, occam.window=FALSE, keep.list=list(c(1)),
                 either.or.list=list(c(9,12)) , all.none.list=list(c(12,13)), OR.fix=200, nbest=100000)
                 
#posterior probability of inclusion
summary(bicfl)

#conditional mean
bicfl$condpostmean

#conditional sd
bicfl$condpostsd

### You will probably want to stop and save here, and then
## rm(bicfl)

aicfl<-aic.glmMN(x, y, glm.family="binomial", strict=FALSE, factor.type=TRUE, occam.window=FALSE, keep.list=list(c(1)),
                 either.or.list=list(c(9,12)),  all.none.list=list(c(12,13)), OR.fix=200, nbest=100000)
                 
#posterior probability of inclusion
summary(aicfl)

#conditional mean
aicfl$condpostmean

#conditional sd
aicfl$condpostsd

##This plot replicates Figure 3 in Montgomery and Nyhan (variable names were corrected by hand in Postscript to make final figure). 

#postscript(file="newfl3.ps",paper="letter")
par(mar=c(2,2,2,2),mgp=c(.75,.75,0))
plot(aicfl,mfrow=c(5,5))
#dev.off()