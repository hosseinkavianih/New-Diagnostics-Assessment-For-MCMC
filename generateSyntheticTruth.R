source("E:/GoogleDrive/Advising/HosseinKavianiHamedani/HYMOD/Hyfunction.R")

library(mvtnorm)

# load input data (precipitation, temperature) and observations (streamflow)
Precipitation <- read.table("E:/GoogleDrive/Advising/HosseinKavianiHamedani/HYMOD/PR.txt")
Pr <- Precipitation$V1
Evaporation <- read.table("E:/GoogleDrive/Advising/HosseinKavianiHamedani/HYMOD/E.txt")
Ev <- Evaporation$V1
Streamflow <- read.table("E:/GoogleDrive/Advising/HosseinKavianiHamedani/HYMOD/Data.txt")
Qobs <- Streamflow$V1
t <- c(seq(1,length(Qobs)))
warmup <- (length(Pr)-length(Qobs))

# set synthetic truth
param <- c(420.0,0.18,0.93,0.053,0.46)

modelParams <- param[1:5]

modelRuns <- hymodr(param = modelParams, area = 1950, tdelta = 86400,
                    e = Ev, p = Pr, w_initial=0, wslow_initial=0,
                    wquick_initial=0)

# add 1 to simulated q_tot
Qsim <- modelRuns$q_tot + 1

# remove warm-up
Qsim <- Qsim[(warmup+1):length(Qsim)]

# plot predictions and simulations
plot(t,Qobs,type='l')
lines(t,Qsim,col="red")

# log-space residuals
par(mfrow=c(1,2))
eps <- log(Qobs) - log(Qsim)
qqnorm(eps,main="Log-Space Residuals")
qqline(eps)
acf(eps,main="Log-Space Residuals",lag.max=50)
par(mfrow=c(1,1))


# fit exponential decay to correlation coefficient, forcing intercept through 1 at lag 0
# i.e. fit linear decay to log(correlation coefficient), forcing intercept through 0 at lag 0
eps.acf <- acf(eps,lag.max=35)
rho <- eps.acf$acf
lag <- eps.acf$lag
rho.df <- data.frame(lag, rho)

# fit to 35 lags
rho.fitted <- lm(log(rho)~0+lag, data=rho.df)
lines(rho.df$lag,exp(rho.fitted$fitted.values),col='red')

# fit to 15 lags
rho.fitted2 <- lm(log(rho)~0+lag, data=rho.df[1:15,])
predictions <- predict(rho.fitted2, newdata = rho.df)
lines(rho.df$lag,exp(predictions),col='green')

# use second model fit to 15 lags, plotted in green
theta = -1/rho.fitted2$coefficients
sigma2 = var(eps)

# compute covariance matrix from correlation at each lag and variance of residuals
nOut <- length(Qobs)
h <- matrix(0, nOut, nOut)
for (i in 1:nOut) {
  for (j in 1:nOut) {
    h[i,j] <- abs(t[i] - t[j])
  }
}
discrepancyParams = c(round(sigma2,2),round(theta,1))
#sigma2 = 0.37, theta = 9.4
R <- exp(-h/theta)
Covariance <- R * sigma2

# generate synthetic truth by adding residuals to Qsim
set.seed(11042021)
eps.synthetic <- rmvnorm(1, mean=c(rep(0,nOut)), sigma=Covariance)

Qsyntrue <- exp(log(Qsim) + eps.synthetic)

# plot observations, simulations and synthetic truth
plot(t,Qobs,type='l')
lines(t,Qsim,col="red")
lines(t,Qsyntrue,col="green")

write.table(Qsyntrue, "E:/GoogleDrive/Advising/HosseinKavianiHamedani/HYMOD/Qsyntrue.txt")

# time model run
ptm <- proc.time()
for(i in 1:1000){
  hymodr(param = modelParams, area = 1950, tdelta = 86400,
         e = Ev, p = Pr, w_initial=0, wslow_initial=0,
         wquick_initial=0)
}
proc.time() - ptm
