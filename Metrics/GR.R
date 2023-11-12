
# This is a prallel run for whatever number of parameters that are

arg=commandArgs(T)
library(BayesianTools)

# K defines the number of parameters
k <- strtoi(arg[1]) + 1

# Set path to the MH output files

Path <- "Set the path here"
setwd(Path)

psrffinal <- matrix(NA,1000,25)

for (j in 1:1000) {

 Pattern <- paste("HyperparameterSeedParam",j,".Rdata",sep="")
 lofparam <- list.files(pattern = Pattern)
 if (length(lofparam) > 0) {
 
 load(Pattern)
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

# Write the output in the desired path
PSRFparam1 <- paste(Path, "GelmanParam", k, ".txt",sep="")
write.table(psrffinal,file = PSRFparam1)
