#!/usr/bin/env python
# coding: utf-8

# In[1]:


import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib
import matplotlib as mpl
import seaborn.apionly as sns


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
        algorithm.psrf.append(np.loadtxt(name + "/KL.txt",skiprows=1,usecols=np.arange(1,25)))
    
    return algorithm


# In[3]:


MHNo = getAlgorithms("MHNo")
MHUpdate = getAlgorithms("MHUpdate")
DREAMUpdate = getAlgorithms("DREAMUpdate")
SMC = getAlgorithms("SMC")


# In[4]:


algs = [SMC, DREAMUpdate, MHUpdate, MHNo]
#algs = [DREAMUpdate, MHUpdate, MHNo]


# In[6]:


# proposal figure
i=0
titles = ['Attainment Maps', r'$SMC$ Control Map', r'$DREAM_{(ZS)}$ Control Map', r'$AM$ Control Map', r'$MH$ Control Map']

#titles = ['Attainment Maps', r'$DREAM_{(ZS)}$ Control Map', r'$AM$ Control Map', r'$MH$ Control Map']

#titles = [r'$MH$ Control Map', r'$AM$ Control Map', r'$DREAM_{(ZS)}$ Control Map']

# overall psrf min and max to find range for attainment maps
# overall psrf min and max to find range for attainment maps
psrf_min = np.nanmin(np.array([np.nanmin(algs[0].psrf[i]), np.nanmin(algs[1].psrf[i]), 
                               np.nanmin(algs[2].psrf[i]), np.nanmin(algs[3].psrf[i])]))#, np.nanmin(algs[3].psrf[i])]))
psrf_max = np.nanmax(np.array([np.nanmax(algs[0].psrf[i]), np.nanmax(algs[1].psrf[i]), 
                               np.nanmax(algs[2].psrf[i]), np.nanmax(algs[3].psrf[i])]))#, np.nanmax(algs[3].psrf[i])]))

# mean psrf min and max to find range for control maps
psrfMean_min = np.nanmin(np.array([np.nanmin(np.nanmean(algs[0].psrf[i],1)), np.nanmin(np.nanmean(algs[1].psrf[i],1)), 
                               np.nanmin(np.nanmean(algs[2].psrf[i],1)), np.nanmin(np.nanmean(algs[3].psrf[i],1))]))#, np.nanmin(np.nanmean(algs[3].psrf[i],1))]))
psrfMean_max = np.nanmax(np.array([np.nanmax(np.nanmean(algs[0].psrf[i],1)), np.nanmax(np.nanmean(algs[1].psrf[i],1)), 
                               np.nanmax(np.nanmean(algs[2].psrf[i],1)), np.nanmax(np.nanmean(algs[3].psrf[i],1))]))#, np.nan


sns.set_style("dark")
fig, plots = plt.subplots(nrows=1,ncols=len(algs)+1, constrained_layout=True, figsize=[15.5,5])
# Gelman-Rubin attainment maps
ax = plots[0]
psrf_attain = np.zeros([100,len(algs)])
psrf_range = np.linspace(0,psrf_max,100)
for j in range(np.shape(psrf_range)[0]):
    for k in range(len(algs)):
        psrf_attain[j,k] = len(np.where(algs[k].psrf[i] < psrf_range[j])[0]) /         len(np.where(algs[k].psrf[i] < psrf_range[-1])[0])
        
attainmap = ax.pcolormesh(np.arange(len(algs)+1), psrf_range, psrf_attain, cmap="RdBu")

ax.set_ylabel('KL',fontsize=16)
ax.set_xticks([0.5,1.5,2.5,3.5])
ax.set_xticklabels([r'$SMC$', r'$DREAM_{(ZS)}$', r'$AM$', r'$MH$'])
#ax.set_xticklabels([r'$DREAM_{(ZS)}$', r'$AM$', r'$MH$'])
ax.tick_params(labelsize=8)
ax.set_title(titles[0], fontsize=16)

count = 1
for j, alg in enumerate(algs):
    # Gelman-Rubin control maps
    ax = plots[count]
    df = pd.DataFrame(alg.psrf[i])
    nan_indices = df.index[df.isnull().all(1)] # samples with NA for Gelman-Rubin diagnostic for all seeds
    if alg.name == 'MHNo' or alg.name == 'MHUpdate':
        x = np.rint(np.delete(alg.LHsamples[:,1],nan_indices)) # number of chains, remove samples with NA
    elif alg.name == 'SMC':
        x = np.round_(np.rint(np.delete(alg.LHsamples[:,1],nan_indices)))
        #x = np.round_(np.rint(np.delete(alg.LHsamples[:,0],nan_indices))/np.rint(np.delete(alg.LHsamples[:,1],nan_indices))/np.rint(np.delete(alg.LHsamples[:,2],nan_indices)))
    else:
        x = np.rint(np.delete(alg.LHsamples[:,2],nan_indices)) # number of chains, remove samples with NA
    y = np.rint(np.delete(alg.LHsamples[:,0],nan_indices)) # number of evals, remove samples with NA
    z = np.delete(np.nanmean(alg.psrf[i],1),nan_indices)
    
    if j == 0:
        cntr = ax.tricontourf(x, y, z, 20, cmap="RdBu_r", vmin=psrfMean_min, vmax=psrfMean_max)
    else:
        ax.tricontourf(x, y, z, 20, cmap="RdBu_r", vmin=psrfMean_min, vmax=psrfMean_max)
    
    ax.tick_params(labelsize=14)
    
    if j == 0:
        ax.set_xlabel('# of Initial Particles',fontsize=16)
    else:
        ax.set_xlabel('# of Chains',fontsize=16)
        
    ax.set_title(titles[count],fontsize=16)
    
    if j != 0:
        ax.tick_params(labelleft='off')
        ax.set_yticks([])
    else:
        ax.set_ylabel('NFE',fontsize=14)
        
    count += 1
    
norm = mpl.colors.Normalize(psrfMean_min,psrfMean_max)
cbar1 = fig.colorbar(mpl.cm.ScalarMappable(norm=norm, cmap="RdBu_r"), ax=plots[-1])
   
#cbar1 = fig.colorbar(cntr, ax=plots[-1])
cbar1.ax.tick_params(labelsize=14)
cbar1.ax.set_yticks(np.arange(0,18,3))
cbar1.ax.set_ylabel('Average KL',fontsize=16)

cbar2 = fig.colorbar(attainmap, ax=plots[0], location='left')
cbar2.ax.tick_params(labelsize=14)
cbar2.ax.set_ylabel('Probability of Attainment',fontsize=16)

fig.savefig('KL_bimodal_New.png')
fig.clf()

