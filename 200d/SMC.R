arg=commandArgs(T)

library(BayesianTools)
library(coda)
library(mvtnorm)

param <- read.table("/scratch/hk3sku/MCMC/Parameters/SMC_sample2.txt")

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

setUp <- createBayesianSetup(likelihood = likelihood1, lower = lowervec[1:numparam,1], upper  = highervec[1:numparam,1])

listdata <- list()


for (i in 1:25) {

 set.seed(i)
 listofdfs <- list()

 index <- strtoi(arg[1]) + 1
 totalevalsv <- round(param$V1[index])
 iterationsv <- round(param$V2[index])
 resamplingStepsv <- round(param$V3[index])
 adaptivev <- round(param$V4[index])
 proposalScalev <- param$V5[index]

 
  if (adaptivev == 1){
   adaptivestr = T
 } else {
   adaptivestr = F
 }
 
 initialParticlesv = round(round(totalevalsv)/round(iterationsv)/round(resamplingStepsv))
 

 settings = list(initialParticles = initialParticlesv, iterations = iterationsv, resampling = T, resamplingSteps = resamplingStepsv, proposal = NULL, adaptive = F, proposalScale = proposalScalev)

 output <- runMCMC(bayesianSetup = setUp, sampler = "SMC", settings = settings)
 tryCatch({
  listdata[[i]] <- output
 }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
 
}

outputFile <- paste("/scratch/hk3sku/MCMC/200d/SMC2/Hyperparameter", index,  ".Rdata",sep="")
    save(listdata,file = outputFile)

