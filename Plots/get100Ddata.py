import numpy as np
import pandas as pd

class Algorithm:
    def __init__(self):
        self.name = None
        self.params = None
        self.LHsamples = None
        self.WD = None
        self.GR = None
        self.KLD = None
        self.samplePts = None
        self.KLDpts = None

class Problem:
    def __init__(self):
        self.name = None
        self.nParam = None
        self.MH_opt = Algorithm()
        self.MH_noOpt = Algorithm()
        self.AM_opt = Algorithm()
        self.AM_noOpt = Algorithm()
        self.DREAM = Algorithm()
        self.algorithms = None

def getAlgorithm(algName, problem):
    algorithm = Algorithm()
    algorithm.name = algName
    if algorithm.name[0:2] == 'AM' or algorithm.name[0:2] == 'MH':
        algorithm.params = pd.read_csv("../Data/Parameters/MH_Param.txt",header=None,
                                       names=["Parameter","Min","Max"],delimiter=" ")
        algorithm.LHsamples = np.loadtxt("../Data/Parameters/MHsample.txt")
        
        # remove last 7 parameters for Gibbs probabilities because they were not used
        algorithm.params = algorithm.params.drop(np.arange(7,len(algorithm.params)).tolist())
        algorithm.LHsamples = algorithm.LHsamples[:,0:-8]
        
        if algorithm.name[0:2] == 'MH':
            # remove adaptInterval and adaptStart because not applicable
            algorithm.params = algorithm.params.drop([5,6])
            algorithm.LHsamples = np.delete(algorithm.LHsamples,[5,6],1)
        
        # only use indices associated with whether or not opt = T/F
        if algorithm.name[2::] == '_opt':
            indices = np.where(algorithm.LHsamples[:,3]>0.5)[0] # get indices where optimize = T for AM or MH
        else:
            indices = np.where(algorithm.LHsamples[:,3]<=0.5)[0]
        algorithm.LHsamples = algorithm.LHsamples[indices,:]
        
        # drop optimize and adapt parameter from params and LH samples because separating T and F cases
        algorithm.params = algorithm.params.drop([3,4])
        algorithm.LHsamples = np.delete(algorithm.LHsamples,[3,4],1)
            
        algorithm.WD = np.loadtxt("../Data/" +problem.name + "/" + problem.name + '/' + algorithm.name[0:2] + '/WD/WD.txt')
        algorithm.WD = algorithm.WD[indices,:] # only use the opt = T/F indices
        if problem.name != '200D':
            algorithm.GR = []
            for i in range(problem.nParam):
                tempGR = np.loadtxt("../Data/" +problem.name + "/" + problem.name + '/' + algorithm.name[0:2]+ '/GR/GR-Param' +
                        str(i+1) + ".txt",skiprows=1,usecols=np.arange(1,26))
                tempGR = tempGR[indices,:] # only use the opt = T/F indices
                algorithm.GR.append(tempGR)
        if problem.name == '100D' or problem.name == 'Bimodal':
            algorithm.KLD = np.loadtxt("../Data/" +problem.name + "/" + problem.name + '/' + algorithm.name[0:2] + '/KLD/KLD.txt', 
                                       skiprows=1, usecols = np.arange(1,26))
            algorithm.KLD = algorithm.KLD[indices,:] # only use the opt = T/F indices
    elif algorithm.name == 'DREAM':
        algorithm.params = pd.read_csv("../Data/Parameters/DREAM_Param.txt",header=None,
                                       names=["Parameter","Min","Max"],delimiter=" ")
        algorithm.LHsamples = np.loadtxt("../Data/Parameters/DREAMsamples.txt")
        
        # drop update parameter because always used T
        algorithm.params = algorithm.params.drop([6])
        algorithm.LHsamples = np.delete(algorithm.LHsamples,6,1)
        
        algorithm.WD = np.loadtxt("../Data/" + problem.name + "/" + problem.name + '/' + algorithm.name + "/WD/WD.txt")
        if problem.name != '200D':
            algorithm.GR = []
            for i in range(problem.nParam):
                algorithm.GR.append(np.loadtxt("../Data/" + problem.name + "/" + problem.name + '/' + algorithm.name + '/GR/GR-Param' +
                                               str(i+1) + ".txt",skiprows=1,usecols=np.arange(1,26)))
        if problem.name == '100D' or problem.name == 'Bimodal':
            algorithm.KLD = np.loadtxt("../Data/" +problem.name + "/" + problem.name + '/' + algorithm.name + '/KLD/' + 'KLD.txt', skiprows=1,
                                       usecols = np.arange(1,26))
    
    return algorithm


def getProblem(name, nParam):
    problem = Problem()
    problem.name = name
    problem.nParam = nParam
    problem.MH_opt = getAlgorithm('MH_opt', problem)
    problem.MH_noOpt = getAlgorithm('MH_noOpt', problem)
    problem.AM_opt = getAlgorithm('AM_opt', problem)
    problem.AM_noOpt = getAlgorithm('AM_noOpt', problem)
    problem.DREAM = getAlgorithm('DREAM', problem)
    problem.algorithms = [problem.MH_noOpt, problem.AM_noOpt, problem.DREAM, 
                          problem.MH_opt, problem.AM_opt]
    
    return problem


def getMetrics(problem):
    # get Wasserstein distances, which we have for all problems
    metrics = []
    first_metric = []
    for i in range(len(problem.algorithms)):
        first_metric.append(problem.algorithms[i].WD)
    metrics.append(first_metric)
    metric_names = ['WD']
    
    # get Gelman-Rubin values for each parameter of Bimodal and HYMOD
    if problem.name != '200D':
        for j in range(problem.nParam):
            next_metric = []
            for i in range(len(problem.algorithms)):
                next_metric.append(problem.algorithms[i].GR[j])
            metrics.append(next_metric)
            metric_names.append('GR-Param' + str(j+1))
    
    # get KLD, which we have for bimodal
    if problem.name == 'Bimodal' or problem.name == '100D':
        next_metric = []
        for i in range(len(problem.algorithms)):
            next_metric.append(problem.algorithms[i].KLD)
        metrics.append(next_metric)
        metric_names.append('KLD')
    
    return metrics, metric_names

