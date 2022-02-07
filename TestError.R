library(BayesianTools)
library(coda)
library(mvtnorm)

setwd("C:/Bayesian")
source("Hyfunction.R")

# load input data (precipitation, temperature) and observations (streamflow)
Precipitation <- read.table("PR.txt")
Pr <- Precipitation$V1
Evaporation <- read.table("E.txt")
Ev <- Evaporation$V1
Streamflow <- read.table("Qsyntrue.txt")
Qsyntrue <- Streamflow$V1
t <- c(seq(1,length(Qsyntrue)))
warmup <- (length(Pr)-length(Qsyntrue))
param <- read.table("DREAMsamples2.txt")


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
  
  logL = dmvnorm(log(Qsyntrue)-log(Qsim), mean = c(rep(0,nOut)), sigma = Covariance)
  
  
  return(sum(logL))  
}

  set.seed(1)
  #listofdfs <- list()
  
  index <- 17
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
  
  
  
  if (pCRupdatev == 1){
    PCRstr = T
  } else {
    PCRstr = F
  }
  
  settings = list(iterations = iters, nCR = ncr, nrChains = chains, gamma =
                    NULL, eps = epsv, e = ev, pCRupdate = PCRstr, updateInterval = updateIntervalv, burnin =
                    burninv, adaptation = adaptationv, pSnooker = pSnookerv, DEpairs = DDEpairsv, ZupdateFrequency = ZupdateFrequencyv, message = FALSE)
  
  
  
  setUp <- createBayesianSetup(likelihood = likelihood1, lower = c(1,0.1,0.1,0,0.1,0,0), upper  = c(500,2,0.99,0.1,0.99,5,40))
  
  

  
  output <- runMCMC(bayesianSetup = setUp, sampler = "DREAMzs", settings = settings)
