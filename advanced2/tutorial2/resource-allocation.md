# Resource Allocation Tutorial

This tutorial briefly outlines how to profile running or previously run jobs, for the purpose of making efficient use of resources on the ilifu facily. It is based on the [resource allocation guide](https://docs.ilifu.ac.za/#/tech_docs/resource_allocation), where you can find much more information, in addition to the recordings and slides available on the [ilifu website](https://www.ilifu.ac.za/latest-training).

## Submit job

After cloning this repo, create the logs directory (`mkdir logs`). Submit `initialise_array.sbatch` to the SLURM queue:

```bash
sbatch initialise_array.sbatch
```

Store the jobID that is output when you run the job (e.g. 2605138) as an environment variable:

```bash
jobid=2605138
```

## View memory usage of running jobs

Once your job is running (check with `squeue -u $USER`), view the maximum memory usage of the job (MaxRSS), using:

```bash
sstat -j $jobid -o MaxRSS
```

This is given in units of kB. To calculate this in GB, divide the value by 1024<sup>2</sup>. This should show \~50 GB maximum memory (\~53,000,000K).

Next, ssh onto the node where the job is running (listed with `squeue -u $USER`). To ssh onto the node, you must have a job running on that node, and you must enable authentication forwarding when you first ssh onto the cluster using the `-A` parameter (`ssh -A <username>@slurm.ilifu.ac.za`).

After you ssh onto the node running the job, run the following command:

```bash
htop -u $USER
```

This gives a real-time dashboard of computing resources for your different (e.g. master and spawned) processes that are running on the node, and allows you to monitor how the resource usage of your job progresses in real time.

Within the first \~30 seconds of the job running, `htop` should show close to 100% CPU usage (i.e. all of a single core), and \~20% memory usage (corresponding to the \~50 GB maximum memory from above). If you weren't quick enough, run the job again and repeat the this step, keeping in mind the node may be different. You will be logged out of the node automatically once your job has completed.

## View memory usage of previous job

After the job has run, list the `MaxRSS` with:

```bash
sacct -j $jobid --unit=G -o JobID,JobName,MaxRSS,ReqMem
```

This will also list your requested memory (`ReqMem`) and the unit (e.g. `80 Gn` = 80 GB per node, or `7.25c` = 7.25 GB per core), for comparison to the used memory.

Now list the efficiency of your job’s use of compute resources with:

```bash
seff $jobid
```

This should list a moderate to high memory efficiency (>=50%, depending on how close the maximum memory usage occurred to when SLURM samples it every 20 seconds), but low CPU efficiency, which is penalised due to our wall-time being longer than necessary (but useful for allowing time for live profiling). To view the effect of the CPU efficiency decreasing, submit the job again and watch the output of `seff`:

```bash
watch seff $jobid
```

## View wall-time usage

Now list the wall-time vs. the time allocated to the job:

```bash
sacct -j $jobid -o jobID,jobName,Elapsed,TimeLimit
```

## Find historical job ID for profiling

In order to profile your previous jobs when submitting a similar job, you may need to find the ID of a previous job to display the usage statistics. Search for a job ID within the time range that you submitted the job, using sacct:

```bash
sacct -X --name=initialise_array --starttime=2022-01-01 --endtime=2022-04-12
```

## Accounting Groups

Each project supported on ilifu has a corresponding SLURM accounting group, against which resource usage is charged. If you are a member of multiple projects on the ilifu cluster, it is important to select the correct project accounting group when submitting a job. You can list your accounting groups, corresponding to the different ilifu projects in which you’re involved, using the following:

```bash
sacctmgr show user $USER cluster=ilifu-slurm2021 -s format=account%25
```

Your default account, used when no accounting group is specified, can be viewed with:

```bash
sacctmgr show user $USER
```

You can change your default account using:

```bash
sacctmgr modify user name=${USER} set DefaultAccount=<account>
```

When submitting a job, your account can be specified within the SLURM parameter `--account` (following `#SBATCH` within sbatch jobs). For example: `--account=b05-pipelines-ag`
