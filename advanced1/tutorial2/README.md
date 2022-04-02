# Interactive Session

An interactive session is more of a development space. This is where you can access a compute nde and run your code interacitvely in real-time without having to submit the code to a queue to be automatically ran. 

# Logging-in
In the event that you wish to use software that provides a GUI, such as CASA plotms, you can start an interactive session with X11 forwarding.You must ssh into the Slurm login node with the -Y parameter, which sets your DISPLAY variable. As shown below : 

`$ ssh -Y (username)`

# Cluster info
Before running a session, you can view the available resources on ilifu using `sinfo`, example below (there's other parameters that you may select to view):

`$ sinfo -O "partition,available,cpus,nodes,memory,statecompact" `

# Starting a session

You can use these two commands `sinteractive` or `srun`.

## Difference between the two
+ If you need to do interactive work and don't want to wait in the queue, the `sinteractive` command aims to provide on-demand access to resources on the Devel partition. This partition is designed to eliminate wait time by sharing resources between mulitple users.
+ With `srun`, by default, the session will run on the Main partition and the resources allocated to the session will not be shared with other users, however, the session may be queued if the requested resources are not available

We will use `srun`.

`$ srun -x11 --time=10 --pty bash`

### GUI

`$ xmessage "Playing Tic-Tac-Toe"`

## Invoking a singurality Shell

`$ singularity shell /idia/software/containers/python-3.6.img`
This will start an interactive session on a compute node and open a shell in the python3 container, which contains a large suite of python tools.

### Run job script
`$ python3 job_script.py`
# Note
Interactive sessions may be lost if you lose connection to the ilifu cluster. Persistent terminals, such as tmux or GNU screen can help to reduce volatility. See the section Persistent Terminals for instructions.
