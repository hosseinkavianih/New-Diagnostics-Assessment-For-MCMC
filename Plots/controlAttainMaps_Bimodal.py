from matplotlib import pyplot as plt
import matplotlib as mpl
import seaborn as sns
import numpy as np
import pandas as pd

def controlAttainMaps_Bimodal(problem, metrics, metric_names, figname):
    algNames = []
    titles = []
    for alg in problem.algorithms:
        titles.append(alg.name + ' Control Maps')
        algNames.append(alg.name)
        
    titles.append('Attainment Maps')
        
    sns.set_style("dark")
    fig = plt.figure()
    cmap1 = mpl.cm.RdBu_r
    cmap2 = mpl.cm.RdBu
    
    norms = []
    for j in range(len(metrics)):
        metric = metrics[j]
        metric_name = metric_names[j]
        metric_min = np.nanmin(metric[0])
        metricMean_min = np.nanmin(np.nanmean(metric[0],1))
        metric_max = np.nanmax(metric[0])
        metricMean_max = np.nanmax(np.nanmean(metric[0],1))
        for i in range(1,len(metric)):
            metric_min = np.nanmin([metric_min, np.nanmin(metric[i])])
            metricMean_min = np.nanmin([metricMean_min,np.nanmin(np.nanmean(metric[i],1))])
            metric_max = np.nanmax([metric_max, np.nanmax(metric[i])])
            metricMean_max = np.nanmax([metricMean_max,np.nanmax(np.nanmean(metric[i],1))])
            
        norm = plt.Normalize(vmin=metricMean_min, vmax=metricMean_max)
        norms.append(norm)
        
        # attainment maps
        ax = fig.add_subplot(3,4,j*4+1)
        attain = np.zeros([100,len(problem.algorithms)])
        metric_range = np.linspace(metric_min, metric_max,100)
        for i in range(100):
            for k in range(len(problem.algorithms)):
                attain[i,k] = len(np.where(metric[k] < metric_range[i])[0]) / \
                    len(np.where(metric[k] < metric_range[-1])[0])
            
        ax.pcolormesh(np.arange(len(problem.algorithms)+1), metric_range, attain, cmap="RdBu")
        if len(metric_names[j]) <= 3:
            ax.set_ylabel(metric_name, fontsize=16)
        else:
            ax.set_ylabel(metric_name[0:2], fontsize=16)
        ax.set_xticks(np.arange(len(problem.algorithms))+0.5)
        ax.set_xticklabels(algNames,rotation=45)
        ax.tick_params(labelsize=14)
        ax.set_title(titles[-1], fontsize=16)
    
        # control maps for each algorithm
        for i, alg in enumerate(problem.algorithms):
            ax = fig.add_subplot(3,4,j*4+i+2)
            df = pd.DataFrame(metric[i])
            nan_indices = df.index[df.isnull().all(1)]
            chains_col = np.where(alg.params['Parameter']=='nChains')
            x = np.rint(np.delete(alg.LHsamples[:,chains_col],nan_indices)) # x axis = nChains where metric not NA
            y = np.rint(np.delete(alg.LHsamples[:,0],nan_indices)) # y-axis = evals where metric not NA
            z = np.delete(np.nanmean(metric[i],1),nan_indices) # z contour = metric
            ax.tricontourf(x, y, z, 20, cmap="RdBu_r", levels=100, norm=norm)#, vmin=metricMean_min, vmax=metricMean_max)
            ax.tick_params(labelsize=14)
            ax.set_xlabel('# of Chains', fontsize=16)
            ax.set_title(titles[i], fontsize=16)
            if i != 0: # don't repeat yticks and ylabels if not first control map
                ax.tick_params(labelleft='off')
                ax.set_yticks([])
            else:
                ax.set_ylabel('NFE', fontsize=14)
            
    fig.set_size_inches([13.4,8.4])
    fig.tight_layout()
    fig.subplots_adjust(right=0.88, left=0.12)
    fig.set_size_inches([19.2,9.8])
    
    for j in range(len(metrics)):
        cbar1_ax = fig.add_axes([0.9, 0.7-j*0.3, 0.02, 0.27])
        cbar1 = mpl.colorbar.ColorbarBase(cbar1_ax, cmap=cmap1, norm=norms[j])
        cbar1.ax.tick_params(labelsize=14)
        #cbar1.ax.set_yticks(np.arange()) #TODO: put range for tick labels
        if len(metric_names[j]) <= 3:
            cbar1.ax.set_ylabel('Average ' + metric_names[j], fontsize=16)
        else:
            cbar1.ax.set_ylabel('Average ' + metric_names[j][0:2], fontsize=16)
    
    cbar2_ax = fig.add_axes([0.02, 0.1, 0.02, 0.87])
    cbar2 = mpl.colorbar.ColorbarBase(cbar2_ax, cmap=cmap2, norm = plt.Normalize(0,1))
    cbar2.ax.tick_params(labelsize=14,direction='in')
    cbar2.ax.set_ylabel('Probability of Attainment', fontsize=16)
    
    fig.savefig(figname)
    fig.clf()
    
    return None