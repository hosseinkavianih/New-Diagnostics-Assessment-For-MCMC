# Bayesian

In this repository, you can find scripts for genereating new diagnostics of different MCMC algorithms. 

## Description

MCMC algorithms can quantify parameter uncertainties in hydrological models, but this is rarely done because it is computationally expensive. Diagnostics from Multi Objective Evolutionary Algorithms (MOEA) were adapted to compare MCMC algorithms’ effectiveness, efficiency, reliability, and controllability to inform which algorithms to use for which types of problems. This can also inform the design of MCMC algorithms that converge faster. We find benefits of using adaptive proposal hyper-parameters and multiple proposal operators on a hydrological model calibration problem.

## Getting Started

### Test Problems

We have three case studies here. HYMOD which is simple hydrological model with 7 parameters, 10-D bimodal mixed Gaussian distribution, and High-dimensional (100-D) multivariate normal distribution. 

### MCMC Algorithms

In each problem, four different algorithms of Metropolis Hastings (MH), Adaptive Metroplis (AM), Differential Evolution Adaptive Metropolis (DREAM), and Sequential Monte Carlo (SMC) were applied. 

### Hyperparameters

We generated a 1000 Latin Hypercube samples of each MCMC algorithms’ hyperparameters. Algorithms were run for 25 random seeds.

### Metrics

Metrics to analyze the performance of MCMC algorithms are:

* **Gelman-Rubin diagnostic**: ratio of within chain variance to across chain variance. A value of 1 suggests convergence to the same variance across chains.
* **Kullback–Leibler divergence (KL)**: measure of how the synthetic truth is different than the posterior values.
* **Euclidean distance (EU)**: measure the point to point distance between the synthetic truth and posterior values.


### Packages

Main packages that were used for this study are BayesianTools, PYMC3, and PYHMC. 

### Scripts

The main four MCMC algorithms were developed in R. You can find the R scripts and the shell scripts that are calling those in each directory. 

### Plots

In this directory, you can generate Attainment and control maps, and CDF of specific metric values through different random seeds.

* **Attainment and control maps of KL values for Bimodal problem**

![image](https://user-images.githubusercontent.com/54559577/198050022-834ddc9f-1434-4990-87a6-8f57eabefffc.png)


* **CDF of  KL values for Bimodal problem**


![image](https://user-images.githubusercontent.com/54559577/198050266-ff67b9c8-220e-485c-a6a9-31d9e6a4df09.png)


## Authors

* Hossein Kavianihamedani
* Julianne Quinn


## Acknowledgments

* [BayesianTools](https://github.com/florianhartig/BayesianTools)
* [PYMC3](https://github.com/pymc-devs/pymc)
* [PYHMC](https://github.com/rmcgibbo/pyhmc)
* [MOEA](https://www.sciencedirect.com/science/article/pii/S0309170816300896)
