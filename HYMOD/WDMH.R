
#load("DistanceParam103.Rdata")

setwd("/scratch/hk3sku/MCMC/HYMOD/WassersteinMH")
param <- read.table("/scratch/hk3sku/MCMC/Parameters/MHsamples.txt")
#iterations <- round(param$V1)
#chains <- round(param$V2)

library(BayesianTools)


matrixCDF <- matrix(NA, 1000, 25)

Pattern <- paste(".Rdata", sep="")
lofparam <- list.files(pattern = Pattern)

chainsmat <- matrix(0, length(lofparam), 1)
itersmat <- matrix(0, length(lofparam), 1)
numEVal <- matrix(0, length(lofparam), 1)
adapt <- matrix(0, length(lofparam), 1)
#load("HyperparameterSeed3Param2.Rdata")

#nchar(lofparam[1])

indexmat <- matrix(0, length(lofparam), 1)

for (j in 1:length(lofparam)) {
  
  if (nchar(lofparam[j]) == 20){
    
    str <- lofparam[j]
    indexS <- substr(str, 14,14)
    index<- strtoi(indexS)
  } else if (nchar(lofparam[j]) == 21) {
    
    str <- lofparam[j]
    indexS <- substr(str, 14,15)
    index<- strtoi(indexS)
    
  } else if (nchar(lofparam[j]) == 22) {
    
    str <- lofparam[j]
    indexS <- substr(str, 14,16)
    index<- strtoi(indexS)
    
    
  } else if (nchar(lofparam[j]) == 23) {
    
    str <- lofparam[j]
    indexS <- substr(str, 14,17)
    index<- strtoi(indexS)
  }
  indexmat[j] <- index
  chainsmat[j] <- round(param$V2[indexmat[j]])
  itersmat[j] <- round(param$V1[indexmat[j]])
  numEVal[j] <- chainsmat[j] * itersmat[j]
  adapt[j] <- round(param$V5[indexmat[j]])
  load(lofparam[j])
  
  for (i in 1:length(matrixdistance)) {
    
    matrixCDF[j,i] <- matrixdistance[i,1]
    
  }

  
}

Numeval <- paste("/scratch/hk3sku/MCMC/HYMOD/WDMH/Numeval.Rdata",sep="")
save(numEVal,file = Numeval)

Adapt <- paste("/scratch/hk3sku/MCMC/HYMOD/WDMH/Adapt.Rdata",sep="")
save(adapt,file = Adapt)

Chainsm <- paste("/scratch/hk3sku/MCMC/HYMOD/WDMH/Chainsm.Rdata",sep="")
save(chainsmat,file = Chainsm)

Itersm <- paste("/scratch/hk3sku/MCMC/HYMOD/WDMH/Itersm.Rdata",sep="")
save(itersmat,file = Itersm)


matCDF <- paste("/scratch/hk3sku/MCMC/HYMOD/WDMH/matCDF.Rdata",sep="")
save(matrixCDF,file = matCDF)
    
