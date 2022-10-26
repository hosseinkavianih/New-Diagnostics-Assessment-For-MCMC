#!/bin/bash
#SBATCH --array=0-999
#SBATCH -A quinnlab_paid
#SBATCH -p standard
#SBATCH -t 18:00:00
#SBATCH -N 1
#SBATCH -c 1
#SBATCH -D /scratch/hk3sku/MCMC/200d
#SBATCH -o /scratch/hk3sku/MCMC/200d/Update-Dream/job.%j.%N.out
#SBATCH --mail-user=hk3sku@virginia.edu          # address for email notification
#SBATCH --mail-type=ALL   

module purge
module load goolf/7.1.0_3.1.4  R

Rscript Highparam2.R ${SLURM_ARRAY_TASK_ID}