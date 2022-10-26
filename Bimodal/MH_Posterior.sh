#!/bin/bash
#SBATCH --array=0-999
#SBATCH -A quinnlab_paid
#SBATCH -p standard
#SBATCH -t 08:00:00
#SBATCH -N 1
#SBATCH -c 1
#SBATCH -D /project/quinnlab/hk3sku/MCMC/bimodal
#SBATCH -o /project/quinnlab/hk3sku/MCMC/bimodal/Post-MHNew/job.%j.%N.out
#SBATCH --mail-user=hk3sku@virginia.edu          # address for email notification
#SBATCH --mail-type=ALL   

module purge
module load goolf/7.1.0_3.1.4  R

Rscript MH_Posterior.R ${SLURM_ARRAY_TASK_ID}