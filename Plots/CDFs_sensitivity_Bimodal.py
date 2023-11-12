from matplotlib import pyplot as plt
import seaborn as sns
import matplotlib
import numpy as np
import pandas as pd

def CDFs_sensitivity_Bimodal(problem, metric, metric_name, figname):
    titles = []
    algNames = []
    for alg in problem.algorithms:
        titles.append(alg.name + ' CDF')
        algNames.append(alg.name)
        
    # replace infinities with nan
    for i in range(len(metric)):
        infIndices = np.where(metric[i]==np.inf)
        for j in range(len(infIndices[0])):
            metric[i][infIndices[0][j],infIndices[1][j]] = np.nan
        
    metric_max = np.nanmax(metric[0])
    for i in range(1,len(metric)):
        metric_max = np.nanmax([metric_max, np.nanmax(metric[i])])
        
    S1_NFE = np.zeros(len(algNames))
    S1_nChains = np.zeros(len(algNames))
    S1_Other = np.zeros(len(algNames))
    S1_Interactions = np.zeros(len(algNames))
    for i, alg in enumerate(problem.algorithms):
        if metric_name[0:2] == 'GR':
            if problem.name != '100D':
                SA = pd.read_csv(problem.name + '/' + metric_name[0:2] + '/' + alg.name + '_' +
                                 metric_name[3::] + '_SA.csv')
            else:
                SA = pd.read_csv(problem.name + '/' + problem.name + '/' + metric_name[0:2] + '/' + alg.name + '_' +
                                 metric_name[3::] + '_SA.csv')
        else:
            if problem.name != '100D':
                SA = pd.read_csv(problem.name + '/' + metric_name + '/' + alg.name + '_SA.csv')
            else:
                SA = pd.read_csv(problem.name + '/' + problem.name + '/' + metric_name + '/' + alg.name + '_SA.csv')
        
        S1_NFE[i] = SA['S1'].iloc[np.where(SA['Parameter']=='NFE')]
        S1_nChains[i] = SA['S1'].iloc[np.where(SA['Parameter']=='nChains')]
        S1_Other[i] = np.sum(SA['S1']) - S1_NFE[i] - S1_nChains[i]
        S1_Interactions[i] = 1 - np.sum(SA['S1'])
        
    df = pd.DataFrame({'Algorithm': algNames, 'NFE': S1_NFE, 'nChains': S1_nChains, 
                       'Other': S1_Other, 'Interactions': S1_Interactions})
    
    sns.set_style("darkgrid")
    fig = plt.figure()
    cmap = matplotlib.cm.get_cmap('plasma_r')
    
    for j, alg in enumerate(problem.algorithms):
        ax = fig.add_subplot(1,4,j+1)
        nSamples = np.shape(alg.LHsamples)[0]
        nSeeds = np.shape(metric[j])[1]
        # find whether NFE or nChains explains more variability in performance and shade CDF by that hyperparameter
        if df['NFE'].iloc[j] > df['nChains'].iloc[j]:
            variable = 'NFE'
        else:
            variable = 'nChains'
        
        vmin = int(problem.algorithms[0].params['Min'].iloc[np.where(problem.algorithms[0].params['Parameter']==variable)[0]])
        vmax = int(problem.algorithms[0].params['Max'].iloc[np.where(problem.algorithms[0].params['Parameter']==variable)[0]])
        norm = plt.Normalize(vmin=vmin, vmax=vmax)
        
        p = np.zeros([nSeeds])
        for k in range(nSeeds):
            p[k] = (k+1)/(nSeeds+1)
            
        colorValues = np.round(alg.LHsamples[:,np.where(problem.algorithms[0].params['Parameter']==variable)[0]])
        
        normValues = (colorValues - vmin) / (vmax - vmin)
        for k in range(nSamples):
            x = np.sort(metric[j][k,:])
            l1, = ax.step(x, p, color=cmap(normValues[k])[0].tolist())
            
        ax.set_xlim([0,metric_max])
        ax.tick_params(labelsize=14)
        ax.set_xlabel(metric_name, fontsize=16)
        ax.set_title(titles[j], fontsize=16)
        if j == 0 or j==3:
            ax.set_ylabel('Cumulative Probability', fontsize=16)
        else:
            ax.tick_params(labelleft='off')
            ax.set_yticks([])
            
    ax = fig.add_subplot(1,4,j+2)
    df.plot(x = 'Algorithm', kind = 'bar', stacked = True, ax=ax, legend=False)
    ax.tick_params(axis='both',labelsize=14)
    ax.set_ylabel('Portion of Variance Explained', fontsize=16)
    ax.set_xticklabels(algNames, rotation=45)
    ax.set_title('Sensitivity of ' + metric_name + ' on ' + problem.name, fontsize=16)
    ax.set_xlabel('')
    
    fig.set_size_inches([15,5])
    fig.tight_layout()
    fig.subplots_adjust(right=0.85, left=0.15)
    handles, labels = ax.get_legend_handles_labels()
    ax.legend(handles, labels, loc='upper right', fontsize=16, ncol=1, bbox_to_anchor=(1.9,1))
    fig.set_size_inches([17.5,5])
                
    norm = matplotlib.colors.Normalize(vmin, vmax)
    cbar_ax = fig.add_axes([0.05, 0.1, 0.02, 0.8])
    cbar = matplotlib.colorbar.ColorbarBase(cbar_ax, cmap=cmap, norm=norm)
    cbar.ax.tick_params(labelsize=14)
    cbar.set_ticks([vmin,vmax])
    cbar.set_ticklabels(['Min','Max'])
    cbar.ax.set_ylabel('Most Explanatory Hyperparameter',fontsize=16)
    cbar.ax.yaxis.set_label_position("left")
        
    fig.savefig('Fig' + figname + "_" + problem.name + "_" + metric_name + "_CDFs_SA.pdf")
    fig.clf()        
        
    return None
