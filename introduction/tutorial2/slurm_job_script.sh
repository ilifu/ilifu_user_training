#!/bin/bash

#SBATCH --job-name=demo_job
#SBATCH --time=00:00:10
#SBATCH --mem=4GB
#SBATCH --reservation=ilifu_training
#SBATCH --partition=Main
#SBATCH --output=demo-job-%j.out
#SBATCH --error=demo-job-%j.err
#SBATCH --mail-user=oarabile@idia.ac.za
#SBATCH --mail-type=BEGIN,END,FAIL,TIME_LIMIT_80
#SBATCH --account=b34-admins-ag

echo "------   Running demo job : Lets play TIC-TAC -----"

singularity exec /idia/software/containers/python3/python3-2020-01-28.simg python job_script.py
