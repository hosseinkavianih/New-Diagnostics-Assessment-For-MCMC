import get100Ddata
import getBimodalData
from controlAttainMaps_100D import controlAttainMaps_100D
from CDFs_sensitivity_100D import CDFs_sensitivity_100D
from controlAttainMaps_Bimodal import controlAttainMaps_Bimodal
from BimodalThresholdMaps import BimodalThresholdMaps
from CDFs_sensitivity_Bimodal import CDFs_sensitivity_Bimodal

# 100 D figures
HighDim = get100Ddata.getProblem('100D',1)
metrics, metric_names = get100Ddata.getMetrics(HighDim)

#control and attainment maps
fignames = ["2","S1","S2"]
for i, metric in enumerate(metrics):
    controlAttainMaps_100D(HighDim, metric, metric_names[i], fignames[i])
    
#CDFs and sensitivity charts
fignames = ["4","S5","S6"]
for i, metric in enumerate(metrics):
    CDFs_sensitivity_100D(HighDim, metric, metric_names[i], fignames[i])

# Bimodal figures
Bimodal = getBimodalData.getProblem('Bimodal',1) # change to 10 when all G-R values are there
metrics, metric_names = getBimodalData.getMetrics(Bimodal)

#control and attainment maps
controlAttainMaps_Bimodal(Bimodal, metrics, metric_names, "Figures/PaperFigures/Fig5_Bimodal_All_Maps.pdf")

#control maps of # of seeds meeting KLD < 1 and WD < 120
counts = getBimodalData.meetThresholds(Bimodal, 1, 120)
BimodalThresholdMaps(Bimodal, counts, 1, 120, "Figures/PaperFigures/Fig7_Threshold_Maps.pdf")

#CDFs and sensitivity charts
fignames = ["S9","S10", "8"]
for i, metric in enumerate(metrics):
    CDFs_sensitivity_Bimodal(Bimodal, metric, metric_names[i], fignames[i])
