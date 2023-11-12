# This is a prallel run for whatever number of parameters that there are

arg=commandArgs(T)

# K defines the number of parameters

k <- strtoi(arg[1]) + 1

# Set path to the MH output files
Path <- "Set the path here"

setwd(Path)

# Set the path to read the truth

true <- read.table("samplemhbimodal.txt") 

klmatrix <- matrix(NA,25,1)

Pattern <- paste("Posterior",k,".Rdata",sep="")
lofparam <- list.files(pattern = Pattern)
 
library(FNN)

if (length(lofparam) > 0) {
 
 load(Pattern)
 
 for (i in 1:length(listposterior)) {
  tryCatch({
  postq <- listposterior[[i]]
  ktest <- KLx.divergence(true, postq, k = 10, algorithm="kd_tree")
  klmatrix[i] <- ktest[10]
  }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
 }
}

outputFile <- paste(Path,"/KLAM/KL", k,  ".Rdata",sep="")
    save(klmatrix,file = outputFile)
