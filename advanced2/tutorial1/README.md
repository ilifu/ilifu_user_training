Thanks to Robin Hall for creating this tutorial: https://github.com/robinlh/slurm-mpi-demo/tree/master

# SLURM MPI demo

This is a demo for running a very simple python script in parallel within a node and across nodes, using MPI and SLURM. The python script uses `mpi4py`'s `Scatterv` and `Reduce` functions for simply adding up the numbers in an array. The sbatch scripts can be changed to any configuration of tasks and nodes, but you need to make sure you change the relevant print statements, jobs names or log output names to reflect the resource configuration (and make sure to create the `logs` directory). After cloning this repo and starting an interactive session (e.g. with `git clone` and `sinteractive`), there are 2 ways to run these scripts on ilifu.

### 1. Using a virtual environment and OpenMPI module
Load your  desired OpenMPI version before building the virtual environment. Available versions can be shown with `module avail`. For example:

```
module load openmpi/4.0.3
```

Set up a virtual environment using the `requirements.txt` file within this repo:
```
> virtualenv mpi_env
> source mpi_env/bin/activate
(mpi_env) > pip install -r requirements.txt
```

Once installed, activate the virtual environment

```
source mpi_env/bin/activate
```

Any sbatch file that uses this virtual environment will need to load the same OpenMPI module that we used to build the virtual environment, after defining the SLURM parameters. He we explicity load it again:

```
module load openmpi/4.0.3
```

Finally, run the relevant sbatch script, or manually call the MPI wrapper around the script you want to run:

```
mpirun python simple_mpi.py
```

This method requires both the OpenMPI module for the MPI wrapper and the python virtual environment for the mpi4py library, which lets us take advantage of MPI calls in python. See the example sbatch files for more clarity on the structure.

### 2. Using a container with OpenMPI installed in it
This method requires that the version and implementation of OpenMPI is the same between the `mpirun` wrapper and what's inside the container. For example, the ASTRO-PY3 container has MPICH installed in it, so it's necessary to load the corresponding module when using MPI through this container. The `mpirun` wrapper is simply called around a regular `singularity exec` call as you'd use for a normal job. For example:

```
module load mpich/3.3a2
mpirun singularity exec /idia/software/containers/ASTRO-PY3.simg python simple_mpi.py
```

This method, which is shown in the `8_cpus_1_node_container.sbatch` file, is slightly slower due to the overhead of launching Singularity.
