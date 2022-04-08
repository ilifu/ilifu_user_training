#!/bin/bash
#SBATCH --job-name=initialise_array
#SBATCH --mem=80GB
#SBATCH --time=00:02:00
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

module load anaconda3
srun python initialise_array.py
sleep 60
