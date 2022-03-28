# Slurm Job Submission
Submmiting a job to slurm is more like submmitting a code script to prodcution.

 e.g. after building/testing the code on jupyter-notebook or a computing node and building a working pipepline/algortihm/etc. that has been tested.

## Example :

+ `job_script.py` is a simple algorithm that plays out a game called _*Tic-Tac*_.
+ `slurm_job_submission.sh` is the slurm script for submitting the algorithm script.

 
## To submit job

`$ sbatch slurm_job_submission.sh`

## Diagnostics

### Check what's happenig with the job
`$ squeue -u (username)`


