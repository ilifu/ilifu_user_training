#!/bin/bash
#SBATCH --partition=Devel

module add python/3.11.2

python hello_world.py
