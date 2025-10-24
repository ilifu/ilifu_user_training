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

### Setup: Using a Virtual Environment and OpenMPI

Load your desired OpenMPI version. Check available versions with:

```bash
module avail
```

Load OpenMPI (example version):

```bash
module load openmpi/5.0.3
```

Create and activate a virtual environment with `uv`:

```bash
uv venv .venv
source .venv/bin/activate
uv pip install -r requirements.txt
```

When running any sbatch script, the same OpenMPI module will be loaded automatically (see the `module load` line in each script).

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
