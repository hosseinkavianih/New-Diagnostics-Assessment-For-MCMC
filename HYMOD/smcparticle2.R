#library(BayesianTools)

setwd("/scratch/hk3sku/MCMC/HYMOD/outsmc2")

matidentity <- matrix(NA, 25, 1000)

for (j in 1:1000) {
  
  Pattern <- paste("Param", j,  ".Rdata",sep="")
  lofparam <- list.files(pattern = Pattern)
  psrfmatrix <-matrix(NA,25,1)
  for (i in 1:length(lofparam)) {
    tryCatch({
      print(j)
      print(i)
      load(lofparam[i])
      
      if (length(output$particles) > 0 ){
        
        matidentity[i,j] <- 1
        
      }else{
        
        matidentity[i,j] <- 0
        
        
      }
      
    }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
  }

}

PSRFparam1 <- paste("/scratch/hk3sku/MCMC/HYMOD/smcparticle2/matrix", ".txt",sep="")
write.table(matidentity,file = PSRFparam1)