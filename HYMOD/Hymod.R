arg=commandArgs(T)

library(BayesianTools)
library(coda)
library(mvtnorm)

source("/scratch/hk3sku/MCMC/HYMOD/Hyfunction.R")

Precipitation <- read.table("/scratch/hk3sku/MCMC/HYMOD/PR.txt")
Pr <- Precipitation$V1
Evaporation <- read.table("/scratch/hk3sku/MCMC/HYMOD/E.txt")
Ev <- Evaporation$V1
Data <- read.table("/scratch/hk3sku/MCMC/HYMOD/Data.txt")
y <- Data$V1
Data2 <- read.table("/scratch/hk3sku/MCMC/HYMOD/Data2.txt")
y2 <- Data2$V1
Time2 <- read.table("/scratch/hk3sku/MCMC/HYMOD/Time2.txt")
T2 <- Time2$V1
T1 <- c(seq(1,731))
param <- read.table("/scratch/hk3sku/MCMC/Parameters/MHsamples.txt")


# Define Likelihood Function

likelihood1 <- function(param){
 
  modelParams = param[1:5]
  discrepancyParams = param[6:7]
  
# Initialization
  
  # In site data
  measurements = y2
  times = T2
  
  sigma2 = discrepancyParams[1]
  theta = discrepancyParams[2]
  nOut = length(y2)
  nReal = length(modelParams)
  
  #Question
  
  # Simulation data from HYMOD
  modelRuns <- hymodr(param = modelParams, area = 1950, tdelta = 86400,
                     e = Ev, p = Pr, w_initial=0, wslow_initial=0
                     ,wquick_initial=0)
  modelRuns <- modelRuns$q_tot
  
  modelRuns <- modelRuns[seq(1, length(y), 10)]

# Construct h for correlation matrix
  
  h = matrix(0, nOut, nOut)
  
  for (i in 1:nOut) {
    for (j in 1:nOut) {
      h[i,j] = abs(times[i] - times[j])
    }
    
  }

    # Get correlation & covariance matrix
    
    R = exp(-h/theta)
    Covariance = R * sigma2
    
    logL = dmvnorm(log(measurements)/log(modelRuns), mean = log(modelRuns)/log(modelRuns), sigma = Covariance, log = TRUE)

  
  return(sum(logL))  
}

listofdfs <- list()

index <- strtoi(arg[1]) + 1
iters <- round(param$V1[index])
chains <- round(param$V2[index])
burninv <- round(param$V3[index])
Optimize <- round(param$V4[index])
adaptv <- round(param$V5[index])
adaptationIntervalv <- round(param$V6[index])
adaptationNotBeforev <- round(param$V7[index])
DRlevelsv <- round(param$V8[index])
gibbsvector <- c(param$V9[index],param$V10[index],param$V11[index],param$V12[index],param$V13[index])

if (Optimize == 1){
  optimizestr = T
} else {
  optimizestr = F
}

if (adaptv == 1){
  settings = list(iterations = iters, nrChains = chains, burnin = burninv, optimize = optimizestr, adapt = T, adaptationInterval = adaptationIntervalv, adaptationNotBefore = adaptationNotBeforev, DRlevels = DRlevelsv, gibbsProbabilities = gibbsvector, message = FALSE)
} else {
  settings = list(iterations = iters, nrChains = chains, burnin = burninv, optimize = optimizestr, adapt = F, DRlevels = DRlevelsv, gibbsProbabilities = gibbsvector, message = FALSE)
}




#iters <- strtoi(arg[1])
#chains <- strtoi(arg[2])

# Setup Problem

setUp <- createBayesianSetup(likelihood = likelihood1, lower = c(1,0.1,0.1,0,0.1,0,0), upper  = c(500,2,0.99,0.1,0.99,300,40))


# Choose the Settings - 100 parallel chains each with 200 iterations with 

settings = list(iterations = iters, nrChains = chains, message = FALSE)

output <- runMCMC(bayesianSetup = setUp, sampler = "Metropolis", settings = settings)

outputFile <- paste("/scratch/hk3sku/MCMC/HYMOD/Output/hyperparam", index, ".Rdata",sep="")
    save(output,file = outputFile)