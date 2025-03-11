#!/bin/bash
#SBATCH --array=1-20%5
#SBATCH --time=0-00:05:00
#SBATCH --job-name=myarrayjob
#SBATCH --output=logs/%x-%A_%a.out
#SBATCH --error=logs/%x-%A_%a.err

singularity exec /idia/software/containers/ASTRO-PY3.8-2024-02-13.simg python myscript.py --input $SLURM_ARRAY_TASK_ID

