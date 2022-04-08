#!/bin/bash
#SBATCH --job-name=8-cpus-1-node-container
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --cpus-per-task=1
#SBATCH --mem=1GB
#SBATCH --time=00:01:00
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

echo "Submitting SLURM job: simple_mpi.py using Singularity container over 8 cores & 1 node"
module add mpich/3.3a2
mpirun singularity exec /idia/software/containers/ASTRO-PY3.simg python simple_mpi.py
