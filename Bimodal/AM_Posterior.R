arg=commandArgs(T)

setwd("/gpfs/gpfs0/project/quinnlab/hk3sku/MCMC/bimodal/AMNew")



j <- strtoi(arg[1]) + 1

listposterior <- list()

Pattern <- paste("HyperparameterSeedParam", j,  ".Rdata",sep="")
#lofparam <- list.files(pattern = Pattern)

if (length(Pattern) > 0) {
 
 load(Pattern)
 
  
 for (i in 1:length(listdata)) {
 
  tryCatch({
  chainlength = length(listdata[[1]])
  Iterlength = nrow(listdata[[1]][[1]]$chain)
  Iterlengthtot <- chainlength * Iterlength

  matrixposterior <- matrix(NA, Iterlengthtot, 10)

  for (p in 1:10) {
  
   for (c in 1:chainlength) {
    
     for (s in 1:Iterlength) {
      
       matrixposterior[s+Iterlength*(c-1), p] <- listdata[[i]][[c]]$chain[s,p]
      
      
      
     }
   }
  
  }
  
  listposterior[[i]] <- matrixposterior
    
 }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
 }
 
}

outputFile <- paste("/gpfs/gpfs0/project/quinnlab/hk3sku/MCMC/bimodal/Post-AMNew/Posterior", j,  ".Rdata",sep="")
    save(listposterior,file = outputFile)