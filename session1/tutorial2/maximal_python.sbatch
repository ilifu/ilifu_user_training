#!/bin/bash
#SBATCH --job-name=tutorial2_python_module
#SBATCH --time=00-00:01:00
#SBATCH --mem=1G
#SBATCH --output=python_module-%j.stdout
#SBATCH --error=python_module-%j.stderr
# #SBATCH --mail-user=your@email_address
# #SBATCH --mail-type=BEGIN,END,FAIL,TIME_LIMIT_80
# #SBATCH --account=some_account

module add python/3.12.9

python hello_world.py

