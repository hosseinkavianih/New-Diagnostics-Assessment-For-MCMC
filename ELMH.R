arg=commandArgs(T)
setwd("/scratch/hk3sku/MCMC/HYMOD/PosteriorMHWithUpdate")

library(BayesianTools)



i <- strtoi(arg[1]) + 1

Pattern <- paste("Param", i,  ".Rdata",sep="")

lofparam <- list.files(pattern = Pattern)

maxvec = c(500,2,0.99,0.1,0.99,5,40)
minvec = c(1,0.1,0.1,0,0.1,-5,0)

if (length(lofparam) > 0) {


 ELtot <- matrix(NA, length(lofparam), 1)
 for (j in 1:length(lofparam)) {
 
 
  load(lofparam[j])

  synnormalized <- c((420.0 - minvec[1])/(maxvec[1]-minvec[1]),(0.18 - minvec[2])/(maxvec[2]-minvec[2]),(0.93 - minvec[3])/(maxvec[3]-minvec[3]),(0.053 - minvec[4])/(maxvec[4]-minvec[4]),(0.46 - minvec[5])/(maxvec[5]-minvec[5]),(0.37 - minvec[6])/(maxvec[6]-minvec[6]),(9.4 - minvec[7])/(maxvec[7]-minvec[7]))
  
  matnormalized <- matrix(NA, nrow(matrixposterior), 7)
  ELsum <- matrix(NA, nrow(matrixposterior), 1)
  for (s in 1:nrow(matrixposterior)) {
  
   matnormalized[s,] <- (matrixposterior[s,] - minvec)/ (maxvec-minvec)
   
   ELsum[s] = sqrt(sum((matnormalized[s,] - synnormalized)^2))
  
  }
  
  ELtot[j] <- sum(ELsum)/nrow(matrixposterior)

 }
 

 ELdistance <- paste("/scratch/hk3sku/MCMC/HYMOD/ELMH/ELdistance", i, ".Rdata",sep="")
 save(ELtot,file = ELdistance)
 
}

