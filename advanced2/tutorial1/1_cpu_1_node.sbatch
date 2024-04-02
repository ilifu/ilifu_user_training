#!/bin/bash
#SBATCH --job-name=1-cpu-1-node
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1GB
#SBATCH --time=00:01:00
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

echo "Submitting SLURM job: simple_mpi.py using 1 core & 1 node"
module add openmpi/4.0.3
source .venv/bin/activate
mpirun python simple_mpi.py
