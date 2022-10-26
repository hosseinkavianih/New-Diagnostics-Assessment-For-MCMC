arg=commandArgs(T)

library(BayesianTools)
library(coda)
library(mvtnorm)

param <- read.table("/scratch/hk3sku/MCMC/Parameters/DREAMsamples2.txt")
#hyperparam <- read.table("DREAMsamples2.txt")

# generate data from synthetic truth
numparam = 200

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

for (i in 1:25) {

 set.seed(i)
 listofdfs <- list()
 index <- strtoi(arg[1]) + 1
 evals <- round(param$V1[index])
 ncr <- round(param$V2[index])
 chains <- round(param$V3[index])
 iters = round(evals/chains)
 burninv <- round((param$V4[index])/100 * iters)
 epsv <- param$V5[index]
 ev <- param$V6[index]
 #pCRupdatev <- round(param$V7[index])
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

 settings = list(iterations = iters, nCR = ncr, gamma =
  NULL, eps = epsv, e = ev, pCRupdate = PCRstr, updateInterval = updateIntervalv, burnin =
  burninv, adaptation = adaptationv, pSnooker = pSnookerv, DEpairs = DDEpairsv, ZupdateFrequency = ZupdateFrequencyv, startValue = matstart, message = FALSE)

 output <- runMCMC(bayesianSetup = setUp, sampler = "DREAMzs", settings = settings)
 outputFile <- paste("/scratch/hk3sku/MCMC/200d/Update-Dream/HyperparameterSeed", i, "Param", index,  ".Rdata",sep="")
    save(output,file = outputFile)

}


# get posterior estimates and compare with true posterior
#vec1 = c(output$chain[[1]][,1],output$chain[[1]][,1],output$chain[[1]][,1])
#vecn = c(output$chain[[1]][,numparam],output$chain[[1]][,numparam],output$chain[[1]][,numparam])

#x = c(seq(-30,30,0.003))
#y1 = dnorm(x,0,1)
#yn = dnorm(x,0,sqrt(numparam))

#plot(density(na.omit(vec1)))
#lines(x,y1,col="red")

#plot(density(na.omit(vecn)))
#lines(x,yn,col="red")
