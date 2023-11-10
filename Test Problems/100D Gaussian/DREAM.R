
arg=commandArgs(T)

library(BayesianTools)
library(coda)
library(mvtnorm)

param <- read.table("/gpfs/gpfs0/project/quinnlab/hk3sku/Scratch-Old/hk3sku/MCMC/Parameters/DREAMsamples2.txt")

numparam = 100

Meanvec = matrix(0, numparam, 1)
Covariance = matrix(NA,numparam,numparam)
for (i in 1:numparam) {
  for (j in 1:numparam) {
    if (i==j) {
      Covariance[i,j] = i
    } else {
      Covariance[i,j] = 0.5 * sqrt(i*j)
    }
  }
}


likelihood1 <- function(param){
  
  Lfunction = dmvnorm(param, mean = Meanvec, sigma = Covariance, log = TRUE)
  return(Lfunction)  
}

lowervec = matrix(-30,numparam,1)
highervec = matrix(30,numparam,1)

setUp <- createBayesianSetup(likelihood = likelihood1, lower = lowervec, upper  = highervec)

listdata <- list()
index <- strtoi(arg[1]) + 1
evals <- round(param$V1[index])
ncr <- round(param$V2[index])
chains <- round(param$V3[index])
iters = round(evals/chains)
burninv <- round((param$V4[index])/100 * evals)
epsv <- param$V5[index]
ev <- param$V6[index]
pCRupdatev <- 1
updateIntervalv <- round(param$V8[index])
pSnookerv <- param$V9[index]
adaptationv <- param$V10[index]
DDEpairsv <- round(param$V11[index])
ZupdateFrequencyv <- round(param$V12[index])
 
matstart  <- matrix(NA, chains, numparam)
  
for (j in 1:numparam) {
  matstart[,j] <- runif(chains, lowervec, highervec)
}


if (pCRupdatev == 1){
  PCRstr = T
} else {
  PCRstr = F
}

settings = list(iterations = evals, nCR = ncr, gamma =
  NULL, eps = epsv, e = ev, pCRupdate = PCRstr, updateInterval = updateIntervalv, burnin =
  burninv, adaptation = adaptationv, pSnooker = pSnookerv, DEpairs = DDEpairsv, ZupdateFrequency = ZupdateFrequencyv, startValue = matstart, message = FALSE)

for (i in 1:25) {

 set.seed(i)

 tryCatch({
  output <- runMCMC(bayesianSetup = setUp, sampler = "DREAMzs", settings = settings)
  listdata[[i]] <- output
 }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})


}

outputFile <- paste("/gpfs/gpfs0/project/quinnlab/hk3sku/MCMC/200D/DREAM2/Hyperparameter", index,  ".Rdata",sep="")
    save(listdata,file = outputFile)
