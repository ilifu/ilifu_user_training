#!/bin/bash
#SBATCH --job-name=script1_setup
#SBATCH --mem=10GB
#SBATCH --time=00:02:00
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err
#SBATCH --reservation=advanced_training_2

singularity exec /idia/software/containers/ASTRO-PY3.8-2024-02-13.simg python script1_setup.py
