from matplotlib import pyplot as plt
import matplotlib as mpl
import seaborn as sns
import numpy as np
import pandas as pd

def controlAttainMaps_100D(problem, metric, metric_name, figname):
    titles = []
    algNames = []
    for alg in problem.algorithms:
        titles.append(alg.name + ' Control Map')
        algNames.append(alg.name)
        
    titles.append('Attainment Maps')
        
    # replace infinities with nan
    for i in range(len(metric)):
        infIndices = np.where(metric[i]==np.inf)
        for j in range(len(infIndices[0])):
            metric[i][infIndices[0][j],infIndices[1][j]] = np.nan
            
    metric_min = np.nanmin(metric[0])
    metricMean_min = np.nanmin(np.nanmean(metric[0],1))
    metric_max = np.nanmax(metric[0])
    metricMean_max = np.nanmax(np.nanmean(metric[0],1))
    for i in range(1,len(metric)):
        metric_min = np.nanmin([metric_min, np.nanmin(metric[i])])
        metricMean_min = np.nanmin([metricMean_min,np.nanmin(np.nanmean(metric[i],1))])
        metric_max = np.nanmax([metric_max, np.nanmax(metric[i])])
        metricMean_max = np.nanmax([metricMean_max,np.nanmax(np.nanmean(metric[i],1))])
        
    sns.set_style("darkgrid")
    fig = plt.figure()
    norm = plt.Normalize(vmin=metricMean_min, vmax=metricMean_max)
    cmap1 = mpl.cm.RdBu_r
    cmap2 = mpl.cm.RdBu
       
    # control maps for each algorithm
    for i, alg in enumerate(problem.algorithms):
        print(alg.name)
        ax = fig.add_subplot(2,3,i+1)
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
        if i == 0 or i ==3: # don't repeat yticks and ylabels if not first control map
            ax.set_ylabel('NFE', fontsize=14)
        else:
            ax.tick_params(labelleft='off')
            ax.set_yticks([])
            
    # attainment maps
    ax = fig.add_subplot(2,3,i+2)
    attain = np.zeros([100,len(problem.algorithms)])
    metric_range = np.linspace(metric_min, metric_max,100)
    for j in range(100):
        for k in range(len(problem.algorithms)):
            attain[j,k] = len(np.where(metric[k] < metric_range[j])[0]) / \
                len(np.where(metric[k] < metric_range[-1])[0])
        
    ax.pcolormesh(np.arange(len(problem.algorithms)+1), metric_range, attain, cmap="RdBu")
    ax.set_ylabel(metric_name, fontsize=16)
    ax.set_xticks(np.arange(len(problem.algorithms)))
    ax.set_xticklabels(algNames,rotation=45)
    ax.tick_params(labelsize=14)
    ax.set_title(titles[-1], fontsize=16)
            
    fig.set_size_inches([11.4,7.1])
    fig.tight_layout()
    fig.subplots_adjust(right=0.85, left=0.12)
    cbar1_ax = fig.add_axes([0.9, 0.62, 0.02, 0.35])
    cbar1 = mpl.colorbar.ColorbarBase(cbar1_ax, cmap=cmap1, norm=norm)
    cbar1.ax.tick_params(labelsize=14)
    #cbar1.ax.set_yticks(np.arange()) #TODO: put range for tick labels
    cbar1.ax.set_ylabel('Average ' + metric_name, fontsize=16)
    
    cbar2_ax = fig.add_axes([0.9, 0.17, 0.02, 0.35])
    cbar2 = mpl.colorbar.ColorbarBase(cbar2_ax, cmap=cmap2, norm = plt.Normalize(0,1))
    cbar2.ax.tick_params(labelsize=14,direction='in')
    cbar2.ax.set_ylabel('Probability of Attainment', fontsize=16)
    
    fig.savefig('Figures/PaperFigures/Fig' + figname + "_" + problem.name + "_" + metric_name + "_maps.pdf")
    fig.clf()
    
    
    return None