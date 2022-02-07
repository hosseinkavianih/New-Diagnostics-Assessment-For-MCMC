import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns

class Algorithm:
    def __init__(self):
        self.name = None
        self.LHsamples = None
        self.Edist = None
        self.psrf = None

def getAlgorithms(name):
    algorithm = Algorithm()
    algorithm.name = name
    if algorithm.name == 'MHNo' or algorithm.name == 'MHUpdate':
        algorithm.LHsamples = np.loadtxt("MHsamples.txt")
    elif algorithm.name == 'DREAMNo' or algorithm.name == 'DREAMUpdate':
        algorithm.LHsamples = np.loadtxt("DREAMsamples.txt")
        
    algorithm.Edist = np.loadtxt(name + "/" + name + "_Edist.txt")
    algorithm.psrf = []
    for i in range(7):
        algorithm.psrf.append(np.loadtxt(name + "/GelmanParam" + str(i+1) + ".txt",skiprows=1,usecols=np.arange(1,25)))
    
    return algorithm

MHNo = getAlgorithms("MHNo")
MHUpdate = getAlgorithms("MHUpdate")
DREAMNo = getAlgorithms("DREAMNo")
DREAMUpdate = getAlgorithms("DREAMUpdate")

algs = [MHNo, MHUpdate, DREAMNo]#, DREAMUpdate]

# overall Edist min and max to find range for attainment maps
Edist_min = np.nanmin(np.array([np.nanmin(algs[0].Edist), np.nanmin(algs[1].Edist), 
                               np.nanmin(algs[2].Edist)]))#, np.nanmin(algs[3].Edist)]))
Edist_max = np.nanmax(np.array([np.nanmax(algs[0].Edist), np.nanmax(algs[1].Edist), 
                               np.nanmax(algs[2].Edist)]))#, np.nanmax(algs[3].Edist)]))

# mean Edist min and max to find range for control maps
EdistMean_min = np.nanmin(np.array([np.nanmin(np.nanmean(algs[0].Edist,1)), np.nanmin(np.nanmean(algs[1].Edist,1)), 
                               np.nanmin(np.nanmean(algs[2].Edist,1))]))#, np.nanmin(np.nanmean(algs[3].Edist,1))]))
EdistMean_max = np.nanmax(np.array([np.nanmax(np.nanmean(algs[0].Edist,1)), np.nanmax(np.nanmean(algs[1].Edist,1)), 
                               np.nanmax(np.nanmean(algs[2].Edist,1))]))#, np.nanmax(np.nanmean(algs[3].Edist,1))]))

Edist_attain = np.zeros([100,len(algs)])
Edist_range = np.linspace(Edist_min,Edist_max,100)
for j in range(np.shape(Edist_range)[0]):
    for k in range(len(algs)):
        Edist_attain[j,k] = len(np.where(algs[k].Edist < Edist_range[j])[0]) / len(np.where(algs[k].Edist < Edist_range[-1])[0])

# loop through parameters
for i in range(7):
    # overall psrf min and max to find range for attainment maps
    psrf_min = np.nanmin(np.array([np.nanmin(algs[0].psrf[i]), np.nanmin(algs[1].psrf[i]), 
                                   np.nanmin(algs[2].psrf[i])]))#, np.nanmin(algs[3].psrf[i])]))
    psrf_max = np.nanmax(np.array([np.nanmax(algs[0].psrf[i]), np.nanmax(algs[1].psrf[i]), 
                                   np.nanmax(algs[2].psrf[i])]))#, np.nanmax(algs[3].psrf[i])]))
    
    # mean psrf min and max to find range for control maps
    psrfMean_min = np.nanmin(np.array([np.nanmin(np.nanmean(algs[0].psrf[i],1)), np.nanmin(np.nanmean(algs[1].psrf[i],1)), 
                                   np.nanmin(np.nanmean(algs[2].psrf[i],1))]))#, np.nanmin(np.nanmean(algs[3].psrf[i],1))]))
    psrfMean_max = np.nanmax(np.array([np.nanmax(np.nanmean(algs[0].psrf[i],1)), np.nanmax(np.nanmean(algs[1].psrf[i],1)), 
                                   np.nanmax(np.nanmean(algs[2].psrf[i],1))]))#, np.nanmax(np.nanmean(algs[3].psrf[i],1))]))
    
    sns.set_style("dark")
    fig = plt.figure()
    # Gelman-Rubin attainment maps
    ax = fig.add_subplot(2,len(algs)+1,1)
    psrf_attain = np.zeros([100,len(algs)])
    psrf_range = np.linspace(0,np.log(psrf_max),100)
    for j in range(np.shape(psrf_range)[0]):
        for k in range(len(algs)):
            psrf_attain[j,k] = len(np.where(np.log(algs[k].psrf[i]) < psrf_range[j])[0]) / \
            len(np.where(np.log(algs[k].psrf[i]) < psrf_range[-1])[0])
            
    ax.pcolormesh(np.arange(len(algs)+1), psrf_range, psrf_attain, cmap="RdBu")
    
    # Euclidean distance attainment maps
    ax = fig.add_subplot(2,len(algs)+1,len(algs)+2)
    ax.pcolormesh(np.arange(len(algs)+1), Edist_range, Edist_attain, cmap="RdBu")
    
    for j, alg in enumerate(algs):
        # Gelman-Rubin control maps
        ax = fig.add_subplot(2,len(algs)+1,j+2)
        df = pd.DataFrame(alg.psrf[i])
        nan_indices = df.index[df.isnull().all(1)] # samples with NA for Gelman-Rubin diagnostic for all seeds
        if alg.name == 'MHNo' or alg.name == 'MHUpdate':
            x = np.rint(np.delete(alg.LHsamples[:,1],nan_indices)) # number of chains, remove samples with NA
        else:
            x = np.rint(np.delete(alg.LHsamples[:,2],nan_indices)) # number of chains, remove samples with NA
        y = np.rint(np.delete(alg.LHsamples[:,0],nan_indices)) # number of evals, remove samples with NA
        z = np.delete(np.nanmean(alg.psrf[i],1),nan_indices)
        cntr = ax.tricontourf(x, y, np.log(z), 20, cmap="RdBu_r", vmin=np.log(psrfMean_min), vmax=np.log(psrfMean_max))
        
        # Euclidean distance control maps
        ax = fig.add_subplot(2,len(algs)+1,j+len(algs)+3)
        df = pd.DataFrame(alg.Edist)
        nan_indices = df.index[df.isnull().all(1)] # samples with NA for Gelman-Rubin diagnostic for all seeds
        if alg.name == 'MHNo' or alg.name == 'MHUpdate':
            x = np.rint(np.delete(alg.LHsamples[:,1],nan_indices)) # number of chains, remove samples with NA
        else:
            x = np.rint(np.delete(alg.LHsamples[:,2],nan_indices)) # number of chains, remove samples with NA
        y = np.rint(np.delete(alg.LHsamples[:,0],nan_indices)) # number of evals, remove samples with NA
        z = np.delete(np.nanmean(alg.Edist,1),nan_indices)
        cntr = ax.tricontourf(x, y, z, 20, cmap="RdBu_r", vmin=EdistMean_min, vmax=EdistMean_max)
        
    fig.set_size_inches([19.2,9.8])
    fig.savefig('Diagnostics_Param' + str(i+1) + '.png')
    fig.clf()
    

# proposal figure
i=0
titles = ['Attainment Maps', r'$MH$ Control Map', r'$AM$ Control Map', r'$DREAM_{(ZS)}$ Control Map']

# overall psrf min and max to find range for attainment maps
psrf_min = np.nanmin(np.array([np.nanmin(algs[0].psrf[i]), np.nanmin(algs[1].psrf[i]), 
                               np.nanmin(algs[2].psrf[i])]))#, np.nanmin(algs[3].psrf[i])]))
psrf_max = np.nanmax(np.array([np.nanmax(algs[0].psrf[i]), np.nanmax(algs[1].psrf[i]), 
                               np.nanmax(algs[2].psrf[i])]))#, np.nanmax(algs[3].psrf[i])]))

# mean psrf min and max to find range for control maps
psrfMean_min = np.nanmin(np.array([np.nanmin(np.nanmean(algs[0].psrf[i],1)), np.nanmin(np.nanmean(algs[1].psrf[i],1)), 
                               np.nanmin(np.nanmean(algs[2].psrf[i],1))]))#, np.nanmin(np.nanmean(algs[3].psrf[i],1))]))
psrfMean_max = np.nanmax(np.array([np.nanmax(np.nanmean(algs[0].psrf[i],1)), np.nanmax(np.nanmean(algs[1].psrf[i],1)), 
                               np.nanmax(np.nanmean(algs[2].psrf[i],1))]))#, np.nanmax(np.nanmean(algs[3].psrf[i],1))]))

sns.set_style("dark")
fig, plots = plt.subplots(nrows=1,ncols=len(algs)+1, constrained_layout=True, figsize=[15.5,5])
# Gelman-Rubin attainment maps
ax = plots[0]
psrf_attain = np.zeros([100,len(algs)])
psrf_range = np.linspace(0,np.log(psrf_max),100)
for j in range(np.shape(psrf_range)[0]):
    for k in range(len(algs)):
        psrf_attain[j,k] = len(np.where(np.log(algs[k].psrf[i]) < psrf_range[j])[0]) / \
        len(np.where(np.log(algs[k].psrf[i]) < psrf_range[-1])[0])
        
attainmap = ax.pcolormesh(np.arange(len(algs)+1), psrf_range, psrf_attain, cmap="RdBu")

ax.set_ylabel('log(' + r'$\hat{R}$' + ')',fontsize=16)
ax.set_xticks([0.5,1.5,2.5])
ax.set_xticklabels([r'$MH$',r'$AM$',r'$DREAM_{(ZS)}$'])
ax.tick_params(labelsize=14)
ax.set_title(titles[0], fontsize=16)

count = 1
for j, alg in enumerate(algs):
    # Gelman-Rubin control maps
    ax = plots[count]
    df = pd.DataFrame(alg.psrf[i])
    nan_indices = df.index[df.isnull().all(1)] # samples with NA for Gelman-Rubin diagnostic for all seeds
    if alg.name == 'MHNo' or alg.name == 'MHUpdate':
        x = np.rint(np.delete(alg.LHsamples[:,1],nan_indices)) # number of chains, remove samples with NA
    else:
        x = np.rint(np.delete(alg.LHsamples[:,2],nan_indices)) # number of chains, remove samples with NA
    y = np.rint(np.delete(alg.LHsamples[:,0],nan_indices)) # number of evals, remove samples with NA
    z = np.delete(np.nanmean(alg.psrf[i],1),nan_indices)
    if j == 0:
        cntr = ax.tricontourf(x, y, np.log(z), 20, cmap="RdBu_r", vmin=np.log(psrfMean_min), vmax=np.log(psrfMean_max))
    else:
        ax.tricontourf(x, y, np.log(z), 20, cmap="RdBu_r", vmin=np.log(psrfMean_min), vmax=np.log(psrfMean_max))
    
    ax.tick_params(labelsize=14)
    ax.set_xlabel('# of Chains',fontsize=16)
    ax.set_title(titles[count],fontsize=16)
    if j != 0:
        ax.tick_params(labelleft='off')
        ax.set_yticks([])
    else:
        ax.set_ylabel('NFE',fontsize=14)
        
    count += 1
    
#fig.set_size_inches([14,5])
#fig.tight_layout()
#fig.subplots_adjust(left=0.25, right=0.8, wspace=0.5)

#cbar_ax1 = fig.add_axes([0.85, 0.15, 0.02, 0.7])
#cbar1 = plt.colorbar(cntr, cax = cbar_ax1)
cbar1 = fig.colorbar(cntr, ax=plots[-1])
cbar1.ax.tick_params(labelsize=14)
cbar1.ax.set_yticks(np.arange(0,43,5))
cbar1.ax.set_ylabel('Average log(' + r'$\hat{R}$' + ')',fontsize=16)

#cbar_ax2 = fig.add_axes([0.15, 0.15, 0.02, 0.7])
#cbar2 = plt.colorbar(attainmap, cax=cbar_ax2)
cbar2 = fig.colorbar(attainmap, ax=plots[0], location='left')
cbar2.ax.tick_params(labelsize=14)
cbar2.ax.set_ylabel('Probability of Attainment',fontsize=16)

fig.savefig('PrelimDiagnostics.png')
fig.clf()