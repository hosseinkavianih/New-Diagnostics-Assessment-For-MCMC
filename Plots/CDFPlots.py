#!/usr/bin/env python
# coding: utf-8

# In[1]:


import os
from matplotlib import pyplot as plt
import matplotlib
import numpy as np
import pandas as pd
import seaborn as sns
#import xarray as xr
import matplotlib as mpl


# In[2]:


class Algorithm:
    def __init__(self):
        self.name = None
        self.LHsamples = None
        #self.Edist = None
        self.psrf = None

def getAlgorithms(name):
    algorithm = Algorithm()
    algorithm.name = name
    if algorithm.name == 'MHNo' or algorithm.name == 'MHUpdate':
        algorithm.LHsamples = np.loadtxt("MHsamples.txt")
    elif algorithm.name == 'DREAMNo' or algorithm.name == 'DREAMUpdate':
        algorithm.LHsamples = np.loadtxt("DREAMsamples.txt")
    elif algorithm.name == 'SMC':
        algorithm.LHsamples = np.loadtxt("SMC_sample.txt")
        
    #algorithm.Edist = np.loadtxt(name + "/" + name + "_Edist.txt")
    algorithm.psrf = []
    for i in range(1):
        algorithm.psrf.append(np.loadtxt(name + "/KL.txt",skiprows=1,usecols=np.arange(1,26)))
    
    return algorithm


# In[3]:


MHNo = getAlgorithms("MHNo")
MHUpdate = getAlgorithms("MHUpdate")
DREAMUpdate = getAlgorithms("DREAMUpdate")
SMC = getAlgorithms("SMC")


# In[4]:


algs = [SMC, DREAMUpdate, MHUpdate, MHNo]
#DREAMUpdate = getAlgorithms("DREAMUpdate")
#algs = [DREAMUpdate]


# In[7]:


s = 0
nLH = 1000
nsamples = 25

p = np.zeros([nsamples])
for i in range(nsamples):
    p[i] = 100*(i+1.0)/(nsamples+1.0)

titles = [r'$SMC$', r'$DREAM_{(ZS)}$', r'$AM$', r'$MH$']
sns.set_style("dark")
fig, plots = plt.subplots(nrows=1,ncols=len(algs), constrained_layout=True, figsize=[15.5,5])
cmap = matplotlib.cm.get_cmap('Blues')

count = 0

for j, alg in enumerate(algs):
    
    ax = plots[count]
    df = pd.DataFrame(alg.psrf[s])
    nan_indices = df.index[df.isnull().all(1)] # samples with NA for Gelman-Rubin diagnostic for all seeds
    
    NFEnorm = (np.round(algs[j].LHsamples[:,0]) - round(np.min(algs[j].LHsamples[:,0])))/ (round(np.max(algs[j].LHsamples[:,0])) - round(np.min(algs[j].LHsamples[:,0])))
    
    for k in range(nLH):
        x = np.sort(alg.psrf[s][k,:])
        l1, = ax.step(x,p, c = cmap(NFEnorm[k]))
        ax.set_xlim([0,psrf_max])
    
    
    #if j == 0:
    #    cntr = ax.tricontourf(x, y, z, 20, cmap="RdBu_r", vmin=psrfMean_min, vmax=psrfMean_max)
    #else:
    #    ax.tricontourf(x, y, z, 20, cmap="RdBu_r", vmin=psrfMean_min, vmax=psrfMean_max)
    
    ax.tick_params(labelsize=14)
    
    #if j == 0:
    #    ax.set_xlabel('# of Initial Particles',fontsize=16)
    #else:
    ax.set_xlabel('KLD',fontsize=16)
        
    ax.set_title(titles[count],fontsize=16)
    
    if j != 0:
        ax.tick_params(labelleft='off')
        ax.set_yticks([])
    else:
        ax.set_ylabel('Normalized NFE',fontsize=14)
        
    count += 1

norm = mpl.colors.Normalize(NFE_min,NFE_max)
cbar = fig.colorbar(mpl.cm.ScalarMappable(norm=norm, cmap="Blues"), ax=plots[-1])

cbar.ax.tick_params(labelsize=14)
cbar.ax.set_yticks(np.arange(0,22,3))
cbar.ax.set_ylabel('NFE',fontsize=16)

fig.savefig('KL_CDF_bimodal_new.png')
fig.clf()

