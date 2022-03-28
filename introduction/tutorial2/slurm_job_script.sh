#!/bin/bash

#SBATCH --job-name=demo_job
#SBATCH --time=00:00:10
#SBATCH --mem=4GB
#SBATCH --partition=Main
#SBATCH --output=tic-tac_output/demo-job-%j.out
#SBATCH --error=tic-tac_output/demo-job-%j.err
#SBATCH --mail-user=oarabile@idia.ac.za
#SBATCH --mail-type=BEGIN,END,FAIL,TIME_LIMIT_80
#SBATCH --account=b34-admins-ag

echo "------   Running demo job : Lets play TIC-TAC -----"

singularity exec /idia/software/containers/python-3.6.img python3 job_script.py 
