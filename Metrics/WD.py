import numpy as np
from geomloss import SamplesLoss
import scipy.stats as ss
import torch
import os
import sys
import random


k = int(float(sys.argv[1]) + 1)
Path =  "Set a path to posteriors of MH"

os.chdir(Path)

def WD(numparam, nseeds, likelihood_fun):

  if likelihood_fun == '100d':
      M = np.zeros(numparam)
      x = np.linspace(1, numparam, numparam)
      y = np.linspace(1, numparam, numparam)
      xv, yv = np.meshgrid(x, y)
      C = 0.5*np.sqrt(xv*yv)
      for i in range(numparam):
        C[i,i] = i+1
      

  # Define a Sinkhorn (~Wasserstein) loss between sampled measures
  loss = SamplesLoss(loss="sinkhorn")

  Lmatrix = []

  for j in range(nseeds):
  
    posterior = "PosteriorMH" + str(k) + "seed" + str(j+1) + ".txt"
    try:
      random.seed(j+1)
      #This file may not exist that's why we set try catch
      approx_posterior = np.loadtxt(posterior)
      true_posterior = ss.multivariate_normal.rvs(mean=M, cov=C, size=np.shape(approx_posterior)[0])
      x = torch.from_numpy(approx_posterior)
      y = torch.from_numpy(true_posterior)
      L = loss(x,y)
      Lmatrix.append(float(L))
      print("Hyperparameter %d seed %d completed" % (k,j+1))
    except:
      print("Hyperparameter %d seed %d does not exist" % (k,j+1))


  WD = np.array(Lmatrix)
  WDname = Path + "/WDMH/WD" + str(k) + ".txt"
  WDtext = np.savetxt(WDname, WD)


  return WDtext

