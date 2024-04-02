# Slurm Job Submission
Submitting a job to slurm is more like deploying a code script to prodcution.Submitting jobs using a batch script allows for multiple jobs to be submitted in parallel, or for a series of jobs to be submitted, where one job may depend on the output of a previous job. Interactive jobs are useful for developing workflows or scripts, or working with software interactively.

 e.g. after building/testing the code on jupyter-notebook or a computing node and building a working pipepline/algortihm/etc. that has been tested.

# Logging in
Slurm is a job scheduling system. It consists of a single login node and many compute nodes. The login node is likened to a controller and manages the cluster resources and job submissions.

The Slurm system can be accessed via ssh at slurm.ilifu.ac.za

some activities require direct access to Slurm compute nodes via ssh, such as running htop to monitor your running job. In order to achieve this you must use authentication forwarding when sshing onto the Slurm login node using the -A parameter

`$ ssh <username>@slurm.ilifu.ac.za`

## Example 
After sshing into slurm.ilifu.ac.za, you can submit a job to Slurm using a shell script

+ `job_script.py` is a simple algorithm that plays out a game called _*Tic-Tac*_.
+ `slurm_job_script.sh` is the slurm script for submitting the algorithm script.

 
### To submit job
The next step is to run the shell script using the Slurm sbatch command:

`$ sbatch slurm_job_script.sh`


This will submit the job to the Slurm queue. If the requested resources are available the job will be initiated. You can see the status of all jobs in the Slurm queue by using the command:

`$ squeue -u <username>`

## Outputs

To get the outputs, you can create a folder, for example `tic-tac_ouputs` where you can send your log files to, which you specify in the sbatch script, as follows:

`#SBATCH --output=tic-tac_output/demo-job-%j.out`

`#SBATCH --error=tic-tac_output/demo-job-%j.err`


