#!/bin/bash
#SBATCH --job-name=combined_script
#SBATCH --mem=80GB
#SBATCH --time=00:04:00
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err
#SBATCH --reservation=advanced_training_2

singularity exec /idia/software/containers/ASTRO-PY3.8-2024-02-13.simg python script_combined.py
