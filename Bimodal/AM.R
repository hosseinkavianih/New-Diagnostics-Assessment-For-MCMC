arg=commandArgs(T)

library(BayesianTools)
library(coda)
library(mvtnorm)
library(lhs)


param <- read.table("/gpfs/gpfs0/project/quinnlab/hk3sku/MCMC/bimodal/MHsample3.txt")

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

set.seed(100)

gibbsvector <- runif(numparam)
                             
listdata <- list()

for (i in 1:25) {

 set.seed(i)
 index <- strtoi(arg[1]) + 1
 evals <- round(param$V1[index])
 chains <- round(param$V2[index])
 iters = round(evals/chains)
 burninv <- round((param$V3[index])/100 * iters)
 Optimize <- round(param$V4[index])
 adaptv <- round(param$V5[index])
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
 outputFile <- paste("/gpfs/gpfs0/project/quinnlab/hk3sku/MCMC/bimodal/AMNew/HyperparameterSeed", "Param", index,  ".Rdata",sep="")
    save(listdata,file = outputFile)

