arg=commandArgs(T)



k <- strtoi(arg[1]) + 1


setwd("/sfs/lustre/bahamut/scratch/hk3sku/MCMC/200d/SMCpost2/")

true <- read.table("/sfs/lustre/bahamut/scratch/hk3sku/MCMC/200d/sampleSMC.txt") 

klmatrix <- matrix(NA,25,1)

Pattern <- paste("Posterior",k,".Rdata",sep="")
lofparam <- list.files(pattern = Pattern)
 
library(FNN)

if (length(lofparam) > 0) {
 
 load(Pattern)
 #lofparam <- list.files(pattern = Pattern)
 
 for (i in 1:length(listposterior)) {
  tryCatch({
  postq <- listposterior[[i]][,1:200]
  ktest <- KLx.divergence(true, postq, k = 10, algorithm="kd_tree")
  klmatrix[i] <- ktest[10]
  }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
 }
}

outputFile <- paste("/sfs/lustre/bahamut/scratch/hk3sku/MCMC/200d/KLSMC/KL", k,  ".Rdata",sep="")
    save(klmatrix,file = outputFile)
