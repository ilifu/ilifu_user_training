#!/bin/bash
#SBATCH --job-name=8-cpus-2-nodes
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=1
#SBATCH --mem=1GB
#SBATCH --time=00:01:00
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err
#SBATCH --reservation=ilifu_training

echo "Submitting SLURM job: simple_mpi.py using 8 cores & 2 nodes"
module add openmpi/5.0.3

source .venv/bin/activate

mpirun python simple_mpi.py
