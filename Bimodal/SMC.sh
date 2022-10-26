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
# then you can use helpful commands like:
# Helpful SLURM commands:
    # sacct -j [job id #] -o jobid,jobname%20,user,partition,state,start,end,NodeList%60
    # - this is helpful for getting the cluster’s estimate of when a job will start (start command); you can also submit this for completed jobs to get the wall clock time
    # - This came in handy when trying to balance memory allocation requests (larger requests would cause a longer wait time) and data chunk size (larger chunks would mean faster computing time)

    # seff [job id #]
    # - returns job statistics, e.g., CPU and memory efficiency

module purge
module load goolf/7.1.0_3.1.4  R

Rscript SMC1.R ${SLURM_ARRAY_TASK_ID}