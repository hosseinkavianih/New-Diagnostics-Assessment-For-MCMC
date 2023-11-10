# This is run by a slurm job array and arg is passing the job number as the LH number
arg=commandArgs(T)

library(BayesianTools)
library(coda)
library(mvtnorm)
library(lhs)

# Set path to the hyperparameter ranges

param <- read.table("/gpfs/gpfs0/project/quinnlab/hk3sku/Scratch-Old/hk3sku/MCMC/Parameters/DREAMsamples2.txt")


numparam = 10

M1 = c(rep(-5, numparam))
M2 = c(rep(5, numparam))
I = matrix(0,numparam,numparam)
for (i in 1:numparam) {
  I[i,i] = 1
}
p1 = 1/3
p2 = 1-p1

likelihood1 <- function(param){
  
  L = p1*dmvnorm(param, mean = M1, sigma = I) + 
    p2*dmvnorm(param, mean = M2, sigma = I)
  return(log(L))  
}



lowervec = matrix(-10,numparam,1)
highervec = matrix(10,numparam,1)

setUp <- createBayesianSetup(likelihood = likelihood1, 
                             lower = lowervec, upper  = highervec)
listdata <- list()

for (i in 1:25) {

 set.seed(i)
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
 
 startMat = randomLHS(chains, numparam)*20-10
 
 if (pCRupdatev == 1){
   PCRstr = T
 } else {
   PCRstr = F
 }

 settings = list(iterations = evals, nCR = ncr, gamma =
  NULL, eps = epsv, e = ev, pCRupdate = PCRstr, updateInterval = updateIntervalv, burnin =
  burninv, adaptation = adaptationv, pSnooker = pSnookerv, DEpairs = DDEpairsv, ZupdateFrequency = ZupdateFrequencyv, startValue = startMat, message = FALSE)

 output <- runMCMC(bayesianSetup = setUp, sampler = "DREAMzs", settings = settings)
 tryCatch({
  listdata[[i]] <- output
 }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
 
}

outputFile <- paste("/gpfs/gpfs0/project/quinnlab/hk3sku/MCMC/bimodal/DREAMNew/Hyperparameter", index,  ".Rdata",sep="")
    save(listdata,file = outputFile)

