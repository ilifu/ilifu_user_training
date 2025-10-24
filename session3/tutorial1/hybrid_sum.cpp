#include <iostream>
#include <omp.h>
#include <mpi.h>
#include <unistd.h>
#include <cstring>

int main(int argc, char** argv) {
    MPI_Init(&argc, &argv);

    int rank, nprocs;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &nprocs);

    double start_time = MPI_Wtime();

    // Parse command line arguments
    long long total_numbers = 100000000LL;  // default
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-n") == 0 && i + 1 < argc) {
            total_numbers = std::stoll(argv[i + 1]);
            i++;
        }
    }

    // Print process info
    char hostname[256];
    gethostname(hostname, sizeof(hostname));
    printf("Process (rank %d) is running on host %s\n", rank, hostname);

    // Print OpenMP thread info
    int num_threads = omp_get_max_threads();
    printf("OpenMP threads available: %d\n", num_threads);

    // Rank 0 prints setup info
    if (rank == 0) {
        printf("Summing numbers from 1 to %lld across %d MPI processes\n", total_numbers, nprocs);
    }

    // Calculate range for this process
    long long numbers_per_process = total_numbers / nprocs;
    long long remainder = total_numbers % nprocs;

    long long start_num = rank * numbers_per_process + (rank < remainder ? rank : remainder) + 1;
    long long end_num = start_num + numbers_per_process + (rank < remainder ? 1 : 0) - 1;

    long long count = end_num - start_num + 1;

    // Compute partial sum with OpenMP parallelization
    double compute_start = MPI_Wtime();

    long long partial_sum = 0;
    #pragma omp parallel for reduction(+:partial_sum)
    for (long long i = start_num; i <= end_num; i++) {
        partial_sum += i;
    }

    double compute_end = MPI_Wtime();
    double compute_time = compute_end - compute_start;

    printf("Rank %d computed sum of %lld numbers in %.3f s: %lld\n",
           rank, count, compute_time, partial_sum);

    // Gather all partial sums to rank 0
    long long total_sum = 0;
    MPI_Reduce(&partial_sum, &total_sum, 1, MPI_LONG_LONG, MPI_SUM, 0, MPI_COMM_WORLD);

    double end_time = MPI_Wtime();

    if (rank == 0) {
        printf("\nTotal sum: %lld\n", total_sum);
        printf("Total execution time: %.3f s\n", end_time - start_time);
    }

    MPI_Finalize();
    return 0;
}
