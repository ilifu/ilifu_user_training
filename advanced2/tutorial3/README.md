# Tutorial for Resource Allocation using Smaller High-throughput Jobs

This tutorial follows on from tutorial 2, and is also based on the [resource allocation guide](https://docs.ilifu.ac.za/#/tech_docs/resource_allocation). However, it shows an example of how to make jobs more efficient by using a high-throughput approach where larger jobs are split into smaller indepedent jobs with their own resource requirements.

You can find additional information, including a video recordings of the tutorial and the slides on the [ilifu website](https://www.ilifu.ac.za/latest-training).

## Scripts Overview

Assume you have a job script with multiple steps, and these steps have different resource requirements.
Normally, these steps would be combined in a single script, however for this tutorial we will be saving them in separate files. 
The combined script is named `script_combined.py`, while the separate steps are named `script1_setup.py` and `script2_calc.py`. 
The first setup script mainly makes use of CPU resources and is meant to simulate the setup stages needed for a project. 
The second script is the main calculation for the project and mainly makes use of RAM memory resources, using up to 60GB of RAM and a small amount of compute. 

## SBatch Overview

We have also created the sbatch files for these scripts, with roughly resource requirements. These are saved as 
`slurm_script1_setup.sbatch`, `slurm_script2_calc.sbatch` and `slurm_script_combined.sbatch`. 

## Submit Combined Script as a SLURM Job

After cloning this repo, first create the logs directory (`mkdir logs`). Submit `slurm_script_combined.sbatch` to the SLURM queue:

```bash
sbatch slurm_script_combined.sbatch
```

Store the jobID that is output when you run the combined job (e.g. 9418176) as an environment variable:

```bash
jobid_comb=9418176
```

## View Memory and CPU usage of Combined Job 

Once your job has completed running (check with `squeue -u $USER`), view the Memory and CPU usage of the job using `seff`:

```bash
seff $jobid_comb
```

The output should be similar to the following: 

```
Job ID: 9418176
Cluster: ilifu-slurm2021
User/Group: tcloete/idia-group
State: COMPLETED (exit code 0)
Cores: 1
CPU Utilized: 00:00:58
CPU Efficiency: 98.31% of 00:00:59 core-walltime
Job Wall-clock time: 00:00:59
Memory Utilized: 22.38 GB
Memory Efficiency: 27.98% of 80.00 GB
```

As can be seen from the above, the CPU Efficiency is quite high, however the Memory efficieny of this job is quite low. 

Note that the above memory utilisation is based on the MaxRSS statistics which only samples the memory used by the job every 20 seconds. So their might be some variability in the your results. In a more realistic scenario with longer running times where it is likely that high memory usage right could be sustained longer it is also likely to have less of an effect.
Alternatively, the run can be repeated multiple times to get a better estimate.

## View Memory and CPU usage of Two Scripts Separately 

Next repeat the same steps for each of the two separate scripts. 

```bash 
sbatch slurm_script1_setup.sbatch
sbatch slurm_script2_calc.sbatch
```

Also remember to save their job ids

```
jobid_script1=9418178
jobid_script2=9418179
```

Looking at the resource efficiency of each of these scripts will show that the first script required much less memory. 

```bash
seff $jobid_script1; echo; seff $jobid_script2
```

```bash
Job ID: 9418178
Cluster: ilifu-slurm2021
User/Group: tcloete/idia-group
State: COMPLETED (exit code 0)
Cores: 1
CPU Utilized: 00:00:33
CPU Efficiency: 97.06% of 00:00:34 core-walltime
Job Wall-clock time: 00:00:34
Memory Utilized: 7.59 GB
Memory Efficiency: 75.90% of 10.00 GB

Job ID: 9418179
Cluster: ilifu-slurm2021
User/Group: tcloete/idia-group
State: COMPLETED (exit code 0)
Cores: 1
CPU Utilized: 00:00:27
CPU Efficiency: 100.00% of 00:00:27 core-walltime
Job Wall-clock time: 00:00:27
Memory Utilized: 55.87 GB
Memory Efficiency: 69.84% of 80.00 GB
```

The first script only uses 7.59 GB of RAM to run, while the second script uses 55.87 GB. In the combined script we in effect requested 80GB for the whole duration of the job. 
However, by splitting the combined job into these two pieces we are able to only request the resources required of each piece of the job.

## Submit Dependent Jobs - Manual

In the previous example we submitted both scripts to Slurm at the same time to measure their resource efficiency. However, this was only possible since they only simulate a workload and don't actually create files. In a real workflow the first script's job would first have to complete, before the second script could be started. 

The way to do this in Slurm is by making use of Job dependencies. The first setup script will be submitted normally, and the second script will be submitted with a dependency on the first script completing successfully.

```bash
sbatch slurm_script1_setup.sbatch
```

Remember to save the new jobid. We will assume it is also saved in the `jobid_script1` variable. Next submit script2, but indicate the dependency using the -d flag, and use 'afterok', followed by the a colon and the job id number to indicate the dependency. `afterok` means that this job will only start once the previous job ran succesfully, while `afterany` means that it will run irrespective of the reason for completiong of the previous job. A useful parameter to add is `--kill-on-invalid-dep=yes`, which will make sure that this job gets cancelled if the dependency can never be satisfied (e.g., if you cancel the first job)

```bash
sbatch -d afterok:$jobid_script1 --kill-on-invalid-dep=yes slurm_script2_calc.sbatch
```

## Submit Dependent Jobs - Automatic

We have also included a script that can submit the job dependencies without any manaul work required.

```
./slurm_script_dependent.sh
```

You should see both jobs being submitted. However, if the script doesn't run you might have to give the script execution permission by using the `chmod +x` command.

## View wall-time usage

The one resource used by all of these scripts that have not been optimised is the wall time. 

You can use the following command to analyse the wall-time vs. the running time of each of the jobs (remember to replace the jobid's in the command with your own jobids):

```bash
sacct -X -j 9418176,9418178,9418179 -o jobID,jobName%20,Elapsed,TimeLimit
```

```
JobID                     JobName    Elapsed  Timelimit 
------------ -------------------- ---------- ---------- 
9418176           combined_script   00:00:59   00:04:00 
9418178             script1_setup   00:00:34   00:02:00 
9418179              script2_calc   00:00:27   00:02:00

```

From the output it can be seen that the allocated time of these jobs were a bit too high. Most likely a total time of 1 minute 30 seconds would be more better for the combined script, and 45 seconds for script1 and script2. This is based on a margin of 20-30% that was added to the running time of the jobs.