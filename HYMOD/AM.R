arg=commandArgs(T)

library(BayesianTools)
library(coda)
library(mvtnorm)

# Loading the model function for generating the flow output
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
param <- read.table("/scratch/hk3sku/MCMC/Parameters/MHsamples2.txt")


# Define Likelihood Function

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

setUp <- createBayesianSetup(likelihood = likelihood1, lower = c(1,0.1,0.1,0,0.1,0,0), upper  = c(500,2,0.99,0.1,0.99,3,40))
 
listdata <- list()

for (i in 1:25) {

 set.seed(i)
 index <- strtoi(arg[1]) + 1
 evals <- round(param$V1[index])
 chains <- round(param$V2[index])
 iters = round(evals/chains)
 burninv <- round(param$V3[index])
 Optimize <- round(param$V4[index])
 #adaptv <- round(param$V5[index])
 adaptv <- 1
 adaptationIntervalv <- round(param$V6[index])
 adaptationNotBeforev <- round(param$V7[index])
 DRlevelsv <- round(param$V8[index])
 gibbsvector <- c(param$V9[index],param$V10[index],param$V11[index],param$V12[index],param$V13[index],param$V14[index],param$V15[index])

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
 outputFile <- paste("/scratch/hk3sku/MCMC/HYMOD/AM/HyperparameterSeed", "Param", index,  ".Rdata",sep="")
    save(listdata,file = outputFile)

