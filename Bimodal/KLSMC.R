arg=commandArgs(T)



k <- strtoi(arg[1]) + 1


setwd("/gpfs/gpfs0/project/quinnlab/hk3sku/MCMC/bimodal/SMCpost/")

true <- read.table("/gpfs/gpfs0/project/quinnlab/hk3sku/MCMC/bimodal/samplesmcbimodal.txt") 

klmatrix <- matrix(NA,25,1)

Pattern <- paste("Posterior",k,".Rdata",sep="")
lofparam <- list.files(pattern = Pattern)
 
library(FNN)

if (length(lofparam) > 0) {
 
 load(Pattern)
 #lofparam <- list.files(pattern = Pattern)
 
 for (i in 1:length(listposterior)) {
  tryCatch({
  postq <- listposterior[[i]]
  ktest <- KLx.divergence(true, postq, k = 10, algorithm="kd_tree")
  klmatrix[i] <- ktest[10]
  }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
 }
}

outputFile <- paste("/gpfs/gpfs0/project/quinnlab/hk3sku/MCMC/bimodal/KLSMC2/KL", k,  ".Rdata",sep="")
    save(klmatrix,file = outputFile)
