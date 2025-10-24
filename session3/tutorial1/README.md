Thanks to Robin Hall for creating this tutorial: https://github.com/robinlh/slurm-mpi-demo/tree/master

# SLURM MPI Demo: Understanding Parallel Computing

## What is this tutorial about?

This tutorial demonstrates how to run code in parallel—spreading work across multiple CPU cores and computing nodes. You'll learn:
- How **SLURM** (a job scheduler) allocates computing resources
- How **MPI** (Message Passing Interface) lets different processes work together
- How adding more CPUs *usually* makes code run faster, but not always!

We'll use a simple Python script that adds up 10 million numbers, splitting the work across different numbers of cores and nodes. By watching how the execution time changes, you'll see parallelism in action and discover its limitations.

## The Example: `simple_mpi.py`

This script adds all numbers from 1 to 10,000,000 in parallel. Here's how it works:

- **Rank 0** (the "leader" process) creates the full list of numbers and splits it into chunks
- **All processes** receive their chunk of numbers (using `Scatterv`)
- **Each process** independently adds up its chunk
- **Process 0** collects all the partial sums and adds them together (using `Reduce`)

The script also prints out:
- Which process is running and on which computer (`gethostname()`)
- The partial sum calculated by each process
- The total execution time

This demonstrates the key MPI concepts: distributing work (`Scatterv`), doing work in parallel, and collecting results (`Reduce`).

## Getting Started

### Prerequisites

Create a logs directory before running any jobs:

```bash
mkdir -p logs
```

### Setup: Using uv and OpenMPI

This project uses **uv** for Python package management. Dependencies are listed in `pyproject.toml`.

**Step 1: Load OpenMPI**

Check available versions with:

```bash
module avail
```

Load OpenMPI (example version):

```bash
module load openmpi/5.0.3
```

**Step 2: Create and activate a virtual environment**

```bash
uv venv .venv
source .venv/bin/activate
```

**Step 3: Install dependencies**

```bash
uv sync
```

This will install all dependencies listed in `pyproject.toml` (mpi4py, numpy).

**Note:** When running sbatch scripts, the OpenMPI module is loaded automatically in each script (see the `module load` line). You just need to make sure your `.venv` virtual environment is set up before submitting jobs.

## The Scaling Demo: Running the Tutorials

Now you're ready to run the example jobs. Submit each script with `sbatch`, then check the results in the `logs/` directory. Watch how execution time changes as you add more resources!

### Demo 1: 1 CPU, 1 Node (Baseline)

**What it does:** Runs the script on a single CPU core.

```bash
sbatch 1_cpu_1_node.sbatch
```

Check the output:

```bash
cat logs/1-cpu-1-node-*.out
```

**What to look for:**
- Only one process (Rank 0)
- Execution time will be the slowest (baseline)
- All work happens on one core

**Key lesson:** This is our baseline. All other runs will be compared to this time.

---

### Demo 2: 4 CPUs, 1 Node (Good Parallelism)

**What it does:** Splits the work across 4 CPU cores on the same physical machine.

```bash
sbatch 4_cpus_1_node.sbatch
```

Check the output:

```bash
cat logs/4-cpus-1-node-*.out
```

**What to look for:**
- Four processes (Rank 0, 1, 2, 3)
- All running on the same hostname (same node)
- Execution time will be roughly 4× faster than Demo 1
- Each process receives ≈2.5 million numbers to add

**Key lesson:** When processes are on the same machine, they can communicate quickly without crossing the network. This is very efficient!

---

### Demo 3: 8 CPUs, 1 Node (Maximum Single-Node Parallelism)

**What it does:** Uses all 8 cores on a single machine.

```bash
sbatch 8_cpus_1_node.sbatch
```

Check the output:

```bash
cat logs/8-cpus-1-node-*.out
```

**What to look for:**
- Eight processes (Rank 0 through 7)
- All running on the same hostname
- Execution time slightly faster than Demo 2 (roughly 8× faster than baseline, or close to it)
- Each process receives ≈1.25 million numbers

**Key lesson:** Adding more cores on the same machine continues to help, but you may hit diminishing returns depending on the CPU architecture and what the cores need to share.

---

### Demo 4: 8 CPUs, 2 Nodes (Communication Overhead)

**What it does:** Spreads the work across 2 different physical machines (4 cores each).

```bash
sbatch 8_cpus_2_nodes.sbatch
```

Check the output:

```bash
cat logs/8-cpus-2-nodes-*.out
```

**What to look for:**
- Eight processes split across two hostnames
- 4 processes on one node, 4 on another
- Execution time will be **similar to or even slower** than Demo 3
- The network communication between nodes is the bottleneck

**Key lesson:** When processes need to communicate across physical machines, network latency becomes a major bottleneck. ILIFU doesn't have InfiniBand (a high-speed interconnect), so inter-node communication is (relatively) slow. Adding more nodes doesn't help—it hurts!

---

## Understanding the Results

When you run each demo, the output will show something like:

```
This process (rank 0) is running on host node01
This process (rank 1) is running on host node02
...
Partial sum on process 0 is: 2500005000000.0
Partial sum on process 1 is: 2500005000000.0
...
After Reduce, total sum on process 0 is: 10000005000000.0
total time: 0.234 s
```

**Compare the execution times across all four demos.** You should see:
1. Demo 1: Baseline (slowest)
2. Demo 2: Faster (4 cores, shared memory)
3. Demo 3: Fastest (8 cores, shared memory)
4. Demo 4: Slower than Demo 3 (network overhead kills the benefit)

This is a real-world lesson in high-performance computing: **parallelism doesn't scale infinitely**. The type of interconnect and the amount of communication your code does matter greatly.

---

## Advanced Demo: C++ with Explicit OpenMP Parallelism

For a better demonstration of how OpenMP threading helps with scaling, we provide a **C++ version** (`hybrid_sum.cpp`) with an **explicit inner loop** that benefits from parallelization. This makes the scaling much more visible than library-based operations like Polars.

### The Example: `hybrid_sum.cpp`

This C++ program sums all numbers from 1 to 100 million (10× larger than the original Python example). Here's how it works:

- **Rank 0** divides the range among all processes
- **Each process** sums its assigned numbers using `#pragma omp parallel for`
- **OpenMP parallelizes the inner loop** across all available threads
- **Rank 0** collects all partial sums using `MPI_Reduce`

The key difference from the Python version: the inner loop is **explicitly parallelizable by OpenMP**, so adding threads actually helps!

### Compiling the C++ Program

Before running the sbatch files, you need to compile the program:

```bash
module load openmpi/5.0.3
mpicc -fopenmp -O3 hybrid_sum.cpp -o hybrid_sum
```

This creates an executable `hybrid_sum` that you can run.

### C++ Demo 1: Single Core (Baseline)

**What it does:** Runs on 1 core with 1 MPI process and 1 thread.

```bash
sbatch hybrid_sum_1_cpu_1_core.sbatch
```

Check the output:

```bash
cat logs/hybrid-sum-1-core-*.out
```

**What to look for:**
- 1 MPI process (rank 0)
- 1 OpenMP thread
- Execution time is the slowest (baseline for comparison)

---

### C++ Demo 2: 8 Cores, Pure MPI (8 Processes, 1 Thread Each)

**What it does:** Distributes work across 8 MPI processes, each with 1 thread.

```bash
sbatch hybrid_sum_1_node_8_cores_8mpi.sbatch
```

Check the output:

```bash
cat logs/hybrid-sum-8mpi-1thread-*.out
```

**What to look for:**
- 8 MPI processes (Rank 0 through 7)
- 1 OpenMP thread per process
- Execution time roughly 8× faster than Demo 1
- Pure MPI parallelism

---

### C++ Demo 3: 8 Cores, Hybrid (4 Processes, 2 Threads Each)

**What it does:** Uses 4 MPI processes, each with 2 OpenMP threads.

```bash
sbatch hybrid_sum_1_node_8_cores_4mpi.sbatch
```

Check the output:

```bash
cat logs/hybrid-sum-4mpi-2threads-*.out
```

**What to look for:**
- 4 MPI processes (Rank 0 through 3)
- 2 OpenMP threads per process (working on the inner loop in parallel)
- Execution time **comparable to or slightly better than Demo 2** (also uses 8 cores)
- Fewer MPI processes = less communication overhead

**Key lesson:** Both Demo 2 and Demo 3 use 8 cores total, but you can achieve similar performance with fewer MPI processes by using OpenMP threading. This shows how hybrid parallelism can be more efficient than pure MPI when communication is expensive.

### C++ Demo 4: 8 Cores, Maximum Threading (1 Process, 8 Threads)

**What it does:** All work in a single MPI process with 8 OpenMP threads.

```bash
sbatch hybrid_sum_1_node_8_cores_1mpi.sbatch
```

Check the output:

```bash
cat logs/hybrid-sum-1mpi-8threads-*.out
```

**What to look for:**
- 1 MPI process (rank 0)
- 8 OpenMP threads working in parallel
- Execution time **likely similar to Demo 2 and Demo 3** (also uses 8 cores)
- No inter-process communication overhead at all

**Key lesson:** With only 1 MPI process, there's no communication cost. OpenMP threads do all the parallelism internally. This is the most efficient approach *on a single node* because there's no messaging overhead.

---

### C++ Demo 5: 8 Cores Across 2 Nodes (1 Process Per Node, 4 Threads Each)

**What it does:** 2 MPI processes (1 per node), each with 4 OpenMP threads.

```bash
sbatch hybrid_sum_2_nodes_4_cores_1mpi.sbatch
```

Check the output:

```bash
cat logs/hybrid-sum-2nodes-1mpi-4threads-*.out
```

**What to look for:**
- 2 MPI processes (one on each node)
- 4 OpenMP threads per process
- Execution time **slower than Demo 2/3/4** (network latency between nodes)
- Each process sums 50 million numbers

**Key lesson:** Just like in the simple_mpi examples, adding a second node with network communication overhead slows things down. Threading can't overcome network latency.

---

### Comparing All Results

To compare all five runs:

```bash
grep "compute sum\|Total execution time" logs/hybrid-sum-*.out
```

You should see output showing computation times for each process. Notice:
- **Demo 1 (baseline)**: Slowest (single core, single thread)
- **Demos 2, 3, 4**: All much faster (use 8 cores), similar performance
- **Demo 5**: Slower due to network overhead between nodes

The key insight: **On a single node**, you can choose between pure MPI, hybrid MPI+OpenMP, or pure threading—they'll all perform similarly. **Across nodes**, network latency dominates and kills performance.


