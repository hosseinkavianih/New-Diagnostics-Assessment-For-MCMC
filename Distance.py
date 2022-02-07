#!/usr/bin/env python
# coding: utf-8

# In[1]:


import matplotlib.pyplot as plt
import matplotlib as mpl
import matplotlib.colors as colors
import matplotlib.tri as tri
import numpy as np
import pandas       # data analysis library
import seaborn as sns


# In[26]:


DREAM_no = pandas.read_table("DREAMNo.txt", 
                          sep=' ', header=0, 
                          names=["x", "y", "z"])
DREAM_yes = pandas.read_table("DREAMUpdate.txt", 
                          sep=' ', header=0, 
                          names=["x", "y", "z"])
MH_no = pandas.read_table("MHNo.txt", 
                          sep=' ', header=0, 
                          names=["x", "y", "z"])
MH_yes = pandas.read_table("MHUpdate.txt", 
                          sep=' ', header=0, 
                          names=["x", "y", "z"])

algs = [MH_no, MH_yes, DREAM_no, DREAM_yes]

vmin = np.nanmin(np.array([MH_no.z.values,MH_yes.z.values,DREAM_no.z.values,DREAM_yes.z.values]))
vmax = np.nanmax(np.array([MH_no.z.values,MH_yes.z.values,DREAM_no.z.values,DREAM_yes.z.values]))


sns.set_style("dark")
fig = plt.figure()
for i, alg in enumerate(algs):
    nan_indices = np.where(np.isnan(alg.z.values))[0]
    x = np.delete(alg.x.values, nan_indices)
    y = np.delete(alg.y.values, nan_indices)
    z = np.delete(alg.z.values, nan_indices)
    ax = fig.add_subplot(1,4,i+1)
    cntr = ax.tricontourf(x,y,z,20,cmap="RdBu_r", vmin=vmin, vmax=vmax)
    
fig.tight_layout()
cbar = fig.colorbar()
# 

# In[29]:


z=table.z.values
nan_indices = np.where(np.isnan(z))[0]

x = np.delete(table.x.values, nan_indices)
y = np.delete(table.y.values, nan_indices)
z = np.delete(z, nan_indices)

sns.set_style("dark")
fig, ax = plt.subplots(figsize=(6,6))

#cmap = mpl.colors.ListedColormap(['cornflowerblue', 'skyblue', 'oldlace', 'sandybrown', 'firebrick'])

#cmap = mpl.colors.ListedColormap(['cornflowerblue', 'skyblue'])

#cmap = mpl.colors.ListedColormap(['cornflowerblue', 'skyblue', 'oldlace'])

#cmap = mpl.colors.ListedColormap(['cornflowerblue'])
#cmap

cntr2 = ax.tricontourf(x, y, z, 20, cmap='RdBu_r', vmin=0.8, vmax=1.17)

#cbar = fig.colorbar(cntr2, ax = ax, ticks = [1.08,1.09,1.1,1.11,1.12,1.13,1.14,1.15,1.16,1.17])
#cbar = fig.colorbar(cntr2, ax = ax, ticks = [1.11,1.12,1.13,1.14,1.15,1.16])
cbar = fig.colorbar(cntr2, ax = ax, ticks = [0.8,0.85,0.9,0.95,1,1.15,1.17])

ax.set_title("DREAM Without Crossover Porbabilities Update",fontsize=18)

#Metropolis-Hastings Without Adaptive Algorithm
#C_Max
#\u03B1
#\u03C3^2
#\u03B8



ax.set_xlabel('Chains', fontsize=18)


xaxis = [2, 5, 10, 15, 20]
vector1 = np.array(xaxis)

ax.set_ylabel('Evals', fontsize=18)
#ax.set_yticklabels(['10000','60000','110000','160000','200000'], fontsize=16)
ax.set_yticklabels([], fontsize=16)
ax.set_xticklabels(['2', '5', '10', '15', '20'], fontsize=16)
#cbar.ax.set_yticklabels(['0.8','0.85','0.9','0.95','1','1.15','1.17'],fontsize=16)
#cbar.ax.set_yticklabels(['1.11','1.12','1.13','1.14','1.15','1.16'],fontsize=16)
ax.set_xticks(vector1)

#ax.tick_params(  axis='y',  which='both',     left=False,   top=False,  labelleft=False) 

#ax.tick_params(axis='y',labelleft='off')


fig.savefig("DREAMNo.png")

#ax2.plot(x, y, 'ko', ms=3)
#ax2.set(xlim=(-2, 2), ylim=(-2, 2))
#ax2.set_title('tricontour (%d points)' % npts)

