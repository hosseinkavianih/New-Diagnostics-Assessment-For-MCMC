arg=commandArgs(T)

library(BayesianTools)
library(coda)
library(mvtnorm)
library(lhs)


param <- read.table("/scratch/hk3sku/MCMC/Parameters/SMC_sample3.txt")

#hyperparam <- read.table("DREAMsamples.txt")

# synthetic truth
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
                             lower = lowervec[1:numparam,1], upper  = highervec[1:numparam,1])
listdata <- list()

for (i in 1:25) {

 set.seed(i)
 listofdfs <- list()

 index <- strtoi(arg[1]) + 1
 totalevalsv <- round(param$V1[index])
 initialParticlesv <- round(param$V2[index])
 resamplingStepsv <- round(param$V3[index])
 adaptivev <- round(param$V4[index])
 proposalScalev <- param$V5[index]

 
  if (adaptivev == 1){
   adaptivestr = T
 } else {
   adaptivestr = F
 }
 
 itersv = round(round(totalevalsv)/round(initialParticlesv)/round(resamplingStepsv))
 

 settings = list(initialParticles = initialParticlesv, iterations = itersv, resampling = T, resamplingSteps = resamplingStepsv, proposal = NULL, adaptive = T, proposalScale = proposalScalev)

 output <- runMCMC(bayesianSetup = setUp, sampler = "SMC", settings = settings)
 tryCatch({
  listdata[[i]] <- output
 }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
 
}

outputFile <- paste("/gpfs/gpfs0/project/quinnlab/hk3sku/MCMC/bimodal/SMC/Hyperparameter", index,  ".Rdata",sep="")
    save(listdata,file = outputFile)

