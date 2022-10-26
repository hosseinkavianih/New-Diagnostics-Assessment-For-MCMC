arg=commandArgs(T)

library(BayesianTools)
#library(transport)

# Synthetic Truth Values
#param <- c(420.0,0.18,0.93,0.053,0.46,0.37,9.4)

setwd("/scratch/hk3sku/MCMC/200d/Update-Dream")

listposterior <- list()
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
     matrixdistance <- matrix(NA,length(lofparam),1)
    
    
     for (i in 1:length(lofparam)) {
      
      # Printing the LH and Seed numbers in case of debugging
       print(j)
       print(i)
       tryCatch({
       # Loading the output MCMC file
       load(lofparam[i])
      
       chainlength<- length(output$chain)
       Iterlength <- length(output$chain[[1]][,1])
       Iterlengthtot <- chainlength * Iterlength

# Calculating posterior matrix for each LH and random seed
       matrixposterior <- matrix(NA, Iterlengthtot, 200)


      # for (p in 1:200) {
  
        for (c in 1:chainlength) {
          
          if (c ==1) {
          
         #for (s in 1:Iterlength) {
          matrixposterior <- as.matrix(output$chain[[c]])
          
          } else {
          matchain <- as.matrix(output$chain[[c]])
          
          matrixposterior <- rbind(matchain,matrixposterior)
         
          #matrixposterior[s+Iterlength*(c-1),] <- matchain
  
         }
      
         #}
        }
  
       #}
       
       listposterior[[i]] <- matrixposterior
       
       #matrixdistance[i,1] <- wasserstein1d(matrixposterior, param)
      
     }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
     }

    }
    
Posterior <- paste("/scratch/hk3sku/MCMC/200d/DREAMpost/Posterior", j, ".Rdata",sep="")
       save(listposterior,file = Posterior)
    # Vector of Wasserstein Distance
    
  #} 
#}











