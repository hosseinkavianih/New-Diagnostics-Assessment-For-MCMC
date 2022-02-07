#!/bin/bash
#SBATCH --array=0-6
#SBATCH -A quinnlab_paid
#SBATCH -p standard
#SBATCH -t 24:00:00
#SBATCH -N 1
#SBATCH -c 1
#SBATCH -D /scratch/hk3sku/MCMC/HYMOD
#SBATCH -o /scratch/hk3sku/MCMC/HYMOD/MHGelmanNoUpdated/jobtest2.%j.%N.out
#SBATCH --mail-user=hk3sku@virginia.edu          # address for email notification
#SBATCH --mail-type=ALL   

module purge
module load goolf/7.1.0_3.1.4  R

Rscript psrfMHNo.R ${SLURM_ARRAY_TASK_ID}