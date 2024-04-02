#!/bin/bash
#SBATCH --job-name=tutorial2_R_container
#SBATCH --time=00-00:01:00
#SBATCH --mem=4G
#SBATCH --partition=Main
#SBATCH --reservation=intro_training
#SBATCH --output=R_container-%j.stdout
#SBATCH --error=R_container-%j.stderr
#SBATCH --mail-user=dane@idia.ac.za
#SBATCH --mail-type=BEGIN,END,FAIL,TIME_LIMIT_80
#SBATCH --account=b34-admins-ag

singularity exec /software/common/containers/RStudio2023.06.1-524-R4.3.1.sif Rscript hello_world.R
