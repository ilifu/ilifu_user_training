This tutorial will show you an example of how to submit a Slurm array job. 

A Slurm array job is a way for submitting and managing collections of similar jobs quickly and easily.
Each of the job in the job array will get a different parameter as input though, making sure that they run different computations. 

There are two files in this tutorial, namely:
* myscript.py : This is a dummy script
* slurm-arrayjob.sh: This is the sbatch script, telling slurm how the job array will work.

In this case the Slurm array job will be created with 20 jobs, where 5 are run concurrently.
The indexes of these jobs will be from 1 to 20. 
Our dummy script will receive these indexes as as an input, and just print out which index it received.

You can try out the dummy script yourself and calling it with a random number (e.g. with 10):

```
module load python3
python3 myscript3 --input 10
```

You should see the following output in the terminal: "The input parameter is: 10".

Next we are going to run the the array job that calls this script 20 times, but with only 5 running concurrently. 
You can this by running the following command.
`sbatch slurm-arrayjob.sh`

After submitting the job, you should see a jobid printed in the terminal. 
You will also able to see the job with that jobid in the job queue using this command:
`squeue -u $USER`

In order to see how the jobs get completed and how only 5 are run concurrently, you can use the following command.
This will refresh the squeue every 2 seconds.
`watch "squeue -u $USER"`

Finally, after the array job completes, you can look at the output generated in the logs folder. 
There should be a ".out" file with the standard output for every one of the 20 array jobs.
These should will be similar to the output you received by running the script manually.

e.g. If your jobid was 1000, then the output for the 5th job will be: 'myarrayjob-1000_5.out'

Lastly, there will also be a ".err" files for the standard error: 'myarrayjob-1000_5.err'
This file should be blank if everything went well.

Array jobs are especially useful for automating the runnning of the same scripts.
