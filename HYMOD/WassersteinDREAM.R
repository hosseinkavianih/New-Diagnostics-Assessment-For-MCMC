arg=commandArgs(T)

library(BayesianTools)
library(transport)

# Synthetic Truth Values
param <- c(420.0,0.18,0.93,0.053,0.46,0.37,9.4)

setwd("/scratch/hk3sku/MCMC/HYMOD/outdream")

#paramDREAM <- read.table("/scratch/hk3sku/MCMC/Parameters/DREAMsamples.txt")

#for (j in 1:1000) {
  
  # J would be the LH index
   j <- strtoi(arg[1]) + 1
  # Calculate number of chains
  #chains <- round(paramDREAM$V2[j])
  
  # Just LHs with chains >2
  #if (chains > 1){
    
    # Get the all random seeds for each LH
    Pattern <- paste("Param", j,  ".Rdata",sep="")
    lofparam <- list.files(pattern = Pattern)
    
    if (length(lofparam) > 0) {
     matrixdistance <- matrix(0,length(lofparam),1)
    
    
     for (i in 1:length(lofparam)) {
      
      # Printing the LH and Seed numbers in case of debugging
       print(j)
       print(i)
       tryCatch({
       # Loading the output MCMC file
       load(lofparam[i])
      
       chainlength<- length(output)
       Iterlength <- length(output[[1]]$chain[[1]][,1])
       Iterlengthtot <- 3 * length(output[[1]]$chain[[1]][,1])
      
      # Calculating posterior matrix for each LH and random seed
       matrixposterior <- matrix(0, chainlength * Iterlengthtot, 7)
       
      
       for (p in 1:7) {
        
         for (c in 1:chainlength) {
          
           for (s in 1:Iterlength) {
            
             matrixposterior[s+Iterlengthtot*(c-1), p] <- output[[c]]$chain[[1]][s,p]
             matrixposterior[s+Iterlength+Iterlengthtot*(c-1), p] <- output[[c]]$chain[[2]][s,p]
             matrixposterior[s+2*Iterlength+Iterlengthtot*(c-1), p] <- output[[c]]$chain[[3]][s,p]
             
            
           }
         }
        
       }
      
       matrixdistance[i,1] <- wasserstein1d(matrixposterior, param)
      
     }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
     }
     Distanceparam <- paste("/scratch/hk3sku/MCMC/HYMOD/WassersteinDREAM/DistanceDreamParam", j, ".Rdata",sep="")
     save(matrixdistance,file = Distanceparam)
    }
    # Vector of Wasserstein Distance
    
  #} 
#}











