#!/bin/bash
#SBATCH --array=0-999
#SBATCH -A quinnlab_paid
#SBATCH -p standard
#SBATCH -t 12:00:00
#SBATCH -N 1
#SBATCH -c 1
#SBATCH -D /gpfs/gpfs0/project/quinnlab/hk3sku/MCMC/bimodal
#SBATCH -o _script_outputs/%x_%A.out
#SBATCH -e _script_errors/%x_%A.out
#SBATCH --mail-user=hk3sku@virginia.edu          # address for email notification
#SBATCH --mail-type=ALL   

# note that the folders '_script_outputs' and '_script_errors' must exist beforehand
# in the same directory as the bash script that you run
# this will create a single output and error file for each script

module purge
module load goolf/7.1.0_3.1.4  R

Rscript SMC1.R ${SLURM_ARRAY_TASK_ID}