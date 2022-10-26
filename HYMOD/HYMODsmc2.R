arg=commandArgs(T)

library(BayesianTools)
library(coda)
library(mvtnorm)

source("/scratch/hk3sku/MCMC/HYMOD/Hyfunction.R")

# load input data (precipitation, temperature) and observations (streamflow)
Precipitation <- read.table("/scratch/hk3sku/MCMC/HYMOD/PR.txt")
Pr <- Precipitation$V1
Evaporation <- read.table("/scratch/hk3sku/MCMC/HYMOD/E.txt")
Ev <- Evaporation$V1
Streamflow <- read.table("/scratch/hk3sku/MCMC/HYMOD/Qsyntrue.txt")
Qsyntrue <- Streamflow$V1
t <- c(seq(1,length(Qsyntrue)))
warmup <- (length(Pr)-length(Qsyntrue))
param <- read.table("/scratch/hk3sku/MCMC/Parameters/SMC_sample2.txt")


# Define Likelihood Function
##${SLURM_ARRAY_TASK_ID}
likelihood1 <- function(param){
 
  modelParams = param[1:5]
  discrepancyParams = param[6:7]
  
# Initialization
  
  # In site data
  measurements = Qsyntrue
  
  sigma2 = discrepancyParams[1]
  theta = discrepancyParams[2]
  nOut = length(Qsyntrue)
  nReal = length(modelParams)
  
  #Question
  
  # Simulation data from HYMOD
  modelRuns <- hymodr(param = modelParams, area = 1950, tdelta = 86400,
                     e = Ev, p = Pr, w_initial=0, wslow_initial=0
                     ,wquick_initial=0)
  
  # add 1 to simulated q_tot
  Qsim <- modelRuns$q_tot + 1
  
  # remove warm-up
  Qsim <- Qsim[(warmup+1):length(Qsim)]

# Construct h for correlation matrix
  
  h = matrix(0, nOut, nOut)
  
  for (i in 1:nOut) {
    for (j in 1:nOut) {
      h[i,j] = abs(t[i] - t[j])
    }
    
  }

    # Get correlation & covariance matrix
    
    R = exp(-h/theta)
    Covariance = R * sigma2
    
    logL = dmvnorm(log(Qsyntrue)-log(Qsim), mean = c(rep(0,nOut)), sigma = Covariance, log = TRUE)

  
  return(sum(logL))  
}

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
 
 initialParticlesv = round(totalevalsv)/round(iterationsv)/round(resamplingStepsv)
 

 settings = list(initialParticles = initialParticlesv, iterations = iterationsv, resampling = T, resamplingSteps = resamplingStepsv, proposal = NULL, adaptive = F, proposalScale = proposalScalev)

 setUp <- createBayesianSetup(likelihood = likelihood1, lower = c(1,0.1,0.1,0,0.1,0,0), upper  = c(500,2,0.99,0.1,0.99,3,40))


 output <- runMCMC(bayesianSetup = setUp, sampler = "SMC", settings = settings)
 outputFile <- paste("/scratch/hk3sku/MCMC/HYMOD/outsmc2/HyperparameterSeed", i, "Param", index,  ".Rdata",sep="")
    save(output,file = outputFile)
    
}