# Tutotial 2: Interactive Job Demo

This demo will show an example where three dummy scripts are executed in order as part of workflow that are ran as interactive jobs.

Interactive jobs are jobs that requires ongoing input or interaction from a user while it's running.

There are two main ways to run interactive jobs. To run an interactive job on the development partition use the `sinteractive` command.
If you want to run an interactive job on the Main partition, please use: `srun --pty bash -i`

There are three scripts in the directory, namely:
* script1_setup.sh
* script2_calculate.sh
* script3_summarise.sh

If you navigate to the directory, you can use the following linux command to see all the scripts:

# show scripts
`ls` 

If you wanted to run the first script you would use: `./script1_setup.sh`. 
However, don't run the script on the login node. 

First use `sinteractive`. This will open up a session for you so you can run on the development partion. 
Your prompt should change to reflect this e.g. USERNAME@compute-101 $

Now you can run the scripts:

```
./script1_setup.sh
./script2_calculate.sh
./script3_summarise.sh
```

You will see that a input parameter can be given for the second script. This is why interactive scripts are useful for debugging a workflow. 
If this was a sbatch script you would have had to find a way to directly pass a parameter to this script. 

Finally, when you are done you can exit the sinteractive session with:
`exit`

Or alternatively by pressing: `ctrl+d`
