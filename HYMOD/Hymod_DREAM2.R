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
param <- read.table("/scratch/hk3sku/MCMC/Parameters/DREAMsamples2.txt")


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
 nparam <- 7

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
 
 Vec1 <- c(1,0.1,0.1,0,0.1,0,0)
 Vec2 <- c(500,2,0.99,0.1,0.99,3,40)
  
 matstart  <- matrix(NA, chains, nparam)
  
 for (j in 1:nparam) {
   matstart[,j] <- runif(chains, Vec1[j], Vec2[j])
 }



 if (pCRupdatev == 1){
   PCRstr = T
 } else {
   PCRstr = F
 }

 settings = list(iterations = iters, nCR = ncr, gamma =
  NULL, eps = epsv, e = ev, pCRupdate = PCRstr, updateInterval = updateIntervalv, burnin =
  burninv, adaptation = adaptationv, pSnooker = pSnookerv, DEpairs = DDEpairsv, ZupdateFrequency = ZupdateFrequencyv, startValue = matstart, message = FALSE)



#gibbsvector = c(0.2,0.4,0.1,0.9,0.24,0.11,0.43)
#iters <- strtoi(arg[1])
#chains <- strtoi(arg[2])

# Setup Problem
#settings = list(iterations = 5000, nrChains = 2, burnin = 100, optimize = T, adapt = T, adaptationInterval = 250, adaptationNotBefore = 1500, DRlevels = 1, gibbsProbabilities = gibbsvector, message = FALSE)
 setUp <- createBayesianSetup(likelihood = likelihood1, lower = c(1,0.1,0.1,0,0.1,0,0), upper  = c(500,2,0.99,0.1,0.99,3,40))


# Choose the Settings - 100 parallel chains each with 200 iterations with 

#settings = list(iterations = iters, nrChains = chains, message = FALSE)


 output <- runMCMC(bayesianSetup = setUp, sampler = "DREAMzs", settings = settings)
 outputFile <- paste("/scratch/hk3sku/MCMC/HYMOD/outdreamnewwithupdate3/HyperparameterSeed", i, "Param", index,  ".Rdata",sep="")
    save(output,file = outputFile)
    
}
#outputFile <- paste("/scratch/hk3sku/MCMC/HYMOD/Output/hyperparamtest3", ".Rdata",sep="")
   # save(output,file = outputFile)