#!/bin/bash
#SBATCH --job-name=hybrid-sum-4mpi-2threads
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=2
#SBATCH --mem=1GB
#SBATCH --time=00:05:00
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

echo "Submitting hybrid MPI+OpenMP job: hybrid_sum using 8 cores (4 MPI processes, 2 threads each)"

module load openmpi/5.0.3

# Check if executable exists, if not compile it
if [ ! -f ./hybrid_sum ]; then
    echo "hybrid_sum executable not found. Compiling..."
    mpic++ -fopenmp -O3 hybrid_sum.cpp -o hybrid_sum
    if [ $? -ne 0 ]; then
        echo "Compilation failed!"
        exit 1
    fi
fi

export OMP_NUM_THREADS=2
mpirun ./hybrid_sum
