arg=commandArgs(T)

setwd("/sfs/lustre/bahamut/scratch/hk3sku/MCMC/200d/SMC")



j <- strtoi(arg[1]) + 1

listposterior <- list()

Pattern <- paste("Hyperparameter", j,  ".Rdata",sep="")
#lofparam <- list.files(pattern = Pattern)

if (length(Pattern) > 0) {
 
 load(Pattern)
 
  
 for (i in 1:length(listdata)) {
 
  tryCatch({
  
  matrixposterior <- listdata[[i]]$particles
  
  listposterior[[i]] <- matrixposterior
    
 }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
 }
 
}

outputFile <- paste("/sfs/lustre/bahamut/scratch/hk3sku/MCMC/200d/SMCpost2/Posterior", j,  ".Rdata",sep="")
    save(listposterior,file = outputFile)