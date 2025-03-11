#!/bin/bash

# Submit the first script and capture the job ID
job_id=$(sbatch slurm_script1_setup.sbatch | awk '{print $4}')

echo $job_id

# Submit the second script with a dependency on the first job
sbatch --dependency=afterok:$job_id slurm_script2_calc.sbatch
