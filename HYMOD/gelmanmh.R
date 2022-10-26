arg=commandArgs(T)
library(BayesianTools)

k <- strtoi(arg[1]) + 1

setwd("/scratch/hk3sku/MCMC/HYMOD/MH")

psrffinal <- matrix(NA,1000,25)

for (j in 1:1000) {

 Pattern <- paste("HyperparameterSeed25Param",j,".Rdata",sep="")
 lofparam <- list.files(pattern = Pattern)
 if (length(lofparam) > 0) {
 
 load(Pattern)
 #lofparam <- list.files(pattern = Pattern)
 psrfmatrix <-matrix(NA,25,1)
 
 for (i in 1:length(listdata)) {
 
  tryCatch({
  print(j)
  print(i)
  psrfmatrix[i] <- gelmanDiagnostics(listdata[[i]])$psrf[k,1]
  print(psrfmatrix[i])
  }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
  }
  tryCatch({
  psrffinal[j,] <- psrfmatrix
  print(psrffinal[j,])
  }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
 }
}
PSRFparam1 <- paste("/scratch/hk3sku/MCMC/HYMOD/gelmanmh/GelmanParam", k, ".txt",sep="")
write.table(psrffinal,file = PSRFparam1)