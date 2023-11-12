from matplotlib import pyplot as plt
import matplotlib as mpl
import seaborn as sns
import numpy as np
import pandas as pd

def BimodalThresholdMaps(problem, counts, KLDthres, WDthres, figname):
    algNames = []
    for alg in problem.algorithms:
        algNames.append(alg.name)
        
    sns.set_style("darkgrid")
    fig = plt.figure()
    norm = plt.Normalize(vmin=0, vmax=25)
    cmap = mpl.cm.YlGnBu
    
    # row for each metric
    for j in range(len(counts)):
        # control maps for each algorithm
        for i, alg in enumerate(problem.algorithms):
            ax = fig.add_subplot(3,len(problem.algorithms),j*len(problem.algorithms)+i+1)
            if j==0: # KLD
                df = pd.DataFrame(alg.KLD)
                nan_indices = df.index[df.isnull().all(1)]
            elif j==1: # WD
                df = pd.DataFrame(alg.WD)
                nan_indices = df.index[df.isnull().all(1)]
            elif j==2: # Both
                df1 = pd.DataFrame(alg.KLD)
                nan_indices1 = df1.index[df1.isnull().all(1)]
                df2 = pd.DataFrame(alg.WD)
                nan_indices2 = df2.index[df2.isnull().all(1)]
                nan_indices = np.union1d(nan_indices1, nan_indices2)
            
            chains_col = np.where(alg.params['Parameter']=='nChains')
            x = np.rint(np.delete(alg.LHsamples[:,chains_col],nan_indices)) # x axis = nChains where metric not NA
            y = np.rint(np.delete(alg.LHsamples[:,0],nan_indices)) # y-axis = evals where metric not NA
            z = np.rint(np.delete(counts[j][i],nan_indices)) # z contour = metric
            ax.tricontourf(x, y, z, cmap="YlGnBu", levels=26, norm=norm)#, vmin=metricMean_min, vmax=metricMean_max)
            #ax.scatter(x,y,c=z,cmap="YlGnBu",norm=norm)
            ax.tick_params(labelsize=14)
            ax.set_xlabel('# of Chains', fontsize=16)
            ax.set_title(algNames[i], fontsize=16)
            if i != 0: # don't repeat yticks and ylabels if not first control map
                ax.tick_params(labelleft='off')
                ax.set_yticks([])
            else:
                ax.set_ylabel('NFE', fontsize=14)
             
    fig.set_size_inches([12.3, 8.8])
    fig.tight_layout()
    fig.subplots_adjust(right=0.88)
    
    for j in range(len(counts)):
        cbar1_ax = fig.add_axes([0.9, 0.7-j*0.3, 0.02, 0.27])
        cbar1 = mpl.colorbar.ColorbarBase(cbar1_ax, cmap=cmap, norm=norm)
        cbar1.ax.tick_params(labelsize=14)
        #cbar1.ax.set_yticks(np.arange()) #TODO: put range for tick labels
        if j == 0: # KLD threshold
            cbar1.ax.set_ylabel('# of Seeds with\nKLD < ' + str(KLDthres), fontsize=16)
        elif j == 1: # WD threshold
            cbar1.ax.set_ylabel('# of Seeds with\nWD < ' + str(WDthres), fontsize=16)
        else:
            cbar1.ax.set_ylabel('# of Seeds with\nKLD < ' + str(KLDthres) + ' and WD < ' + str(WDthres), fontsize=16)
        
    fig.savefig(figname)
    fig.clf()
    
    return None
