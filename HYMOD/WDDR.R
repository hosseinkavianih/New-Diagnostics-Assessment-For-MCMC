
#load("DistanceParam103.Rdata")
#DistanceDreamParam460.Rdata
#DistanceDreamParam1000.Rdata
setwd("/scratch/hk3sku/MCMC/HYMOD/WassersteinDREAM")
param <- read.table("/scratch/hk3sku/MCMC/Parameters/DREAMsamples.txt")
#iterations <- round(param$V1)
#chains <- round(param$V2)

library(BayesianTools)


matrixCDF <- matrix(NA, 1000, 25)

Pattern <- paste(".Rdata", sep="")
lofparam <- list.files(pattern = Pattern)

chainsmat <- matrix(0, length(lofparam), 1)
itersmat <- matrix(0, length(lofparam), 1)
numEVal <- matrix(0, length(lofparam), 1)
#load("HyperparameterSeed3Param2.Rdata")

#nchar(lofparam[1])

indexmat <- matrix(0, length(lofparam), 1)

for (j in 1:length(lofparam)) {
  
  if (nchar(lofparam[j]) == 25){
    
    str <- lofparam[j]
    indexS <- substr(str, 19,19)
    index<- strtoi(indexS)
  } else if (nchar(lofparam[j]) == 26) {
    
    str <- lofparam[j]
    indexS <- substr(str, 19,20)
    index<- strtoi(indexS)
    
  } else if (nchar(lofparam[j]) == 27) {
    
    str <- lofparam[j]
    indexS <- substr(str, 19,21)
    index<- strtoi(indexS)
    
    
  } else if (nchar(lofparam[j]) == 28) {
    
    str <- lofparam[j]
    indexS <- substr(str, 19,22)
    index<- strtoi(indexS)
  }
  indexmat[j] <- index
  chainsmat[j] <- round(param$V3[indexmat[j]])
  itersmat[j] <- round(param$V1[indexmat[j]])
  numEVal[j] <- chainsmat[j] * itersmat[j]
  
  load(lofparam[j])
  
  for (i in 1:length(matrixdistance)) {
    
    matrixCDF[j,i] <- matrixdistance[i,1]
    
  }

  
}

Numeval <- paste("/scratch/hk3sku/MCMC/HYMOD/WDDREAM/Numeval.Rdata",sep="")
save(numEVal,file = Numeval)

Chainsm <- paste("/scratch/hk3sku/MCMC/HYMOD/WDDREAM/Chainsm.Rdata",sep="")
save(chainsmat,file = Chainsm)

Itersm <- paste("/scratch/hk3sku/MCMC/HYMOD/WDDREAM/Itersm.Rdata",sep="")
save(itersmat,file = Itersm)


matCDF <- paste("/scratch/hk3sku/MCMC/HYMOD/WDDREAM/matCDF.Rdata",sep="")
save(matrixCDF,file = matCDF)
    
