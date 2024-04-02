#!/bin/bash
#SBATCH --reservation=intro_training

module add python/3.11.2

python hello_world.py
