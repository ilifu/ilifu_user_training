#!/bin/bash

#SBATCH --job-name=demo_job
#SBATCH --time=00:00:25
#SBATCH --mem=4G
#SBATCH --partition=Main
#SBATCH --output=tic-tac_output/demo-job-%j.out
#SBATCH --error=tic-tac_output/demo-job-%j.err
#SBATCH --mail-user=<user-email>
#SBATCH --mail-type=BEGIN,END,FAIL,TIME_LIMIT_80
#SBATCH --account=<user-accounting-group>

echo "------   Running demo job : Lets play TIC-TAC -----"

singularity exec /idia/software/containers/python-3.6.img python3 job_script.py 
