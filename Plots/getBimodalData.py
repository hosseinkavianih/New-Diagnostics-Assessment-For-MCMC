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

class Problem:
    def __init__(self):
        self.name = None
        self.nParam = None
        self.MH = Algorithm()
        self.AM = Algorithm()
        self.DREAM = Algorithm()
        self.algorithms = None

def getAlgorithm(algName, problem):
    algorithm = Algorithm()
    algorithm.name = algName
    if algorithm.name == 'AM' or algorithm.name == 'MH':
        algorithm.params = pd.read_csv("../Data/Parameters/MH_Param.txt",header=None,
                                       names=["Parameter","Min","Max"],delimiter=" ")
        algorithm.LHsamples = np.loadtxt("../Data/Parameters/MHsample.txt")
        
        # remove last 7 parameters for Gibbs probabilities because they were not used
        algorithm.params = algorithm.params.drop(np.arange(7,len(algorithm.params)).tolist())
        algorithm.LHsamples = algorithm.LHsamples[:,0:-8]
        
        if algorithm.name == 'MH':
            # remove adaptInterval and adaptStart because not applicable
            algorithm.params = algorithm.params.drop([5,6])
            algorithm.LHsamples = np.delete(algorithm.LHsamples,[5,6],1)
        
        # drop optimize and adapt parameter from params and LH samples because separating T and F cases
        algorithm.params = algorithm.params.drop([3,4])
        algorithm.LHsamples = np.delete(algorithm.LHsamples,[3,4],1)
            
        algorithm.WD = np.loadtxt("../Data/" + problem.name + '/WD/' + algorithm.name + '/WD.txt')
        if problem.name != '200D':
            algorithm.GR = []
            for i in range(problem.nParam):
                tempGR = np.loadtxt("../Data/" + problem.name + "/GR/" + algorithm.name + '/GR-Param' +
                        str(i+1) + ".txt",skiprows=1,usecols=np.arange(1,26))
                algorithm.GR.append(tempGR)
        if problem.name == 'Bimodal':
            algorithm.KLD = np.loadtxt("../Data/" + problem.name + '/KLD/' + algorithm.name + '/KLD.txt', skiprows=1,
                                       usecols = np.arange(1,26))
    elif algorithm.name == 'DREAM':
        algorithm.params = pd.read_csv("../Data/Parameters/DREAM_Param.txt",header=None,
                                       names=["Parameter","Min","Max"],delimiter=" ")
        algorithm.LHsamples = np.loadtxt("../Data/Parameters/DREAMsamples.txt")
        
        # drop update parameter because always used T
        algorithm.params = algorithm.params.drop([6])
        algorithm.LHsamples = np.delete(algorithm.LHsamples,6,1)
        
        algorithm.WD = np.loadtxt("../Data/" + problem.name + "/WD/" + algorithm.name + "/WD.txt")
        if problem.name != '200D':
            algorithm.GR = []
            for i in range(problem.nParam):
                algorithm.GR.append("../Data/" + np.loadtxt("../Data/" + problem.name + "/GR/" + algorithm.name + '/GR-Param' +
                                               str(i+1) + ".txt",skiprows=1,usecols=np.arange(1,26)))
        if problem.name == 'Bimodal':
            algorithm.KLD = np.loadtxt("../Data/" + problem.name + '/KLD/' + algorithm.name + '/KLD.txt', skiprows=1,
                                       usecols = np.arange(1,26))
    
    return algorithm
        
def getProblem(name, nParam):
    problem = Problem()
    problem.name = name
    problem.nParam = nParam
    problem.MH = getAlgorithm('MH', problem)
    problem.AM = getAlgorithm('AM', problem)
    problem.DREAM = getAlgorithm('DREAM', problem)
    problem.algorithms = [problem.MH, problem.AM, problem.DREAM]
    
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
    if problem.name == 'Bimodal' or problem.name == 'HYMOD':
        for j in range(problem.nParam):
            next_metric = []
            for i in range(len(problem.algorithms)):
                next_metric.append(problem.algorithms[i].GR[j])
            metrics.append(next_metric)
            metric_names.append('GR-Param' + str(j+1))
    
    # get KLD, which we have for bimodal
    if problem.name == 'Bimodal':
        next_metric = []
        for i in range(len(problem.algorithms)):
            next_metric.append(problem.algorithms[i].KLD)
        metrics.append(next_metric)
        metric_names.append('KLD')
    
    return metrics, metric_names

def meetThresholds(problem, KLDthres, WDthres):
    # count how many random seeds have KLD < 1 for each LHS
    KLDcounts = []
    for i in range(len(problem.algorithms)):
        KLDcount = np.count_nonzero(problem.algorithms[i].KLD < KLDthres, 1)
        KLDcounts.append(KLDcount)
        
    WDcounts = []
    for i in range(len(problem.algorithms)):
        WDcount = np.count_nonzero(problem.algorithms[i].WD < WDthres, 1)
        WDcounts.append(WDcount)
        
    bothCounts = []
    for i in range(len(problem.algorithms)):
        KLDtrue = (problem.algorithms[i].KLD < KLDthres)
        WDtrue = (problem.algorithms[i].WD < WDthres)
        bothTrue = KLDtrue*WDtrue
        bothCount = np.count_nonzero(bothTrue==True,1)
        bothCounts.append(bothCount)
    
    return KLDcounts, WDcounts, bothCounts

