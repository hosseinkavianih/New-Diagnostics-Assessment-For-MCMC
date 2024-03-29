arg=commandArgs(T)

library(BayesianTools)
library(coda)
library(mvtnorm)

param <- read.table("/gpfs/gpfs0/project/quinnlab/hk3sku/MCMC/bimodal/MHsample3.txt")

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

setUp <- createBayesianSetup(likelihood = likelihood1, lower = lowervec[1:numparam,1], upper  = highervec[1:numparam,1])

listdata <- list()

# Setting Gibbs probabilities

set.seed(100)

gibbsvector <- runif(numparam)

for (i in 1:25) {
 
 
 
 set.seed(i)
 index <- strtoi(arg[1]) + 1
 print(index)
 evals <- round(param$V1[index])
 chains <- round(param$V2[index])
 iters = round(evals/chains)
 burninv <- round((param$V3[index])/100 * iters)
 Optimize <- round(param$V4[index])
 adaptv <- 1
 adaptationNotBeforev <- burninv + round(param$V7[index]/100 * (iters-burninv))
 adaptationIntervalv <- round(param$V6[index]/100 * (iters-adaptationNotBeforev))
 DRlevelsv <- round(param$V8[index])


 if (Optimize == 1){
   optimizestr = T
 } else {
   optimizestr = F
 }

 
if (adaptv == 1){
   settings = list(iterations = iters, nrChains = chains, burnin = burninv, optimize = optimizestr, adapt = T, adaptationInterval = adaptationIntervalv, adaptationNotBefore =  adaptationNotBeforev, DRlevels = DRlevelsv,   gibbsProbabilities = gibbsvector, message = FALSE)
 } else {
   settings = list(iterations = iters, nrChains = chains, burnin = burninv, optimize = optimizestr, adapt = F, DRlevels = DRlevelsv, gibbsProbabilities = gibbsvector, message =   FALSE)
 }
 
 output <- runMCMC(bayesianSetup = setUp, sampler = "Metropolis", settings = settings)
 tryCatch({
  listdata[[i]] <- output
 }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
 
}
 outputFile <- paste("/gpfs/gpfs0/project/quinnlab/hk3sku/MCMC/200D/AM/HyperparameterSeed", "Param", index,  ".Rdata",sep="")
    save(listdata,file = outputFile)
    
    
