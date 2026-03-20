# Session 4, Tutorial 1: Workflow Orchestration with Nextflow and WDL

## What is this tutorial about?

In previous sessions, you've learned to submit individual jobs to SLURM using `sbatch` scripts. This works well for single, standalone jobs. But what if you need to run a **pipeline** — a series of steps where some depend on the output of others, others can run in parallel, and you need to manage dozens or hundreds of tasks across the cluster?

This is where **workflow orchestration systems** shine.

### Learning Objectives

By the end of this tutorial, you'll understand:

- **Why workflows matter**: How they handle complex dependencies, parallelization, and reproducibility
- **Nextflow fundamentals**: Writing tasks, connecting them into workflows, and running on SLURM
- **WDL/Cromwell basics**: An alternative workflow language and execution engine
- **SLURM integration**: How to configure workflows to use appropriate resources on ilifu
- **Scaling considerations**: When to use workflows vs. direct job submission

## Why Workflow Orchestration?

Imagine a bioinformatics pipeline:
```
Raw data (FASTQ) → Quality trim → Align to reference → Count hits → Generate report
```

With traditional SLURM:
- You submit 4 separate jobs manually
- You must monitor which jobs finish before submitting the next
- If step 2 fails for one sample, you manually resubmit only step 2
- Testing or changing a single step requires rewriting sbatch scripts

With a workflow orchestrator (Nextflow or Cromwell):
- You define all steps in one file with explicit dependencies
- The system parallelizes independent tasks automatically
- Failed tasks can resume from checkpoints
- You can easily test, parameterize, and scale the same workflow
- Workflows are reproducible and portable across systems

This tutorial shows you how to write and execute such workflows on the ilifu SLURM cluster.

## Key Workflow Concepts

### 1. Tasks
A **task** is a single computational step. It has:
- Inputs (files, parameters)
- A script to execute (bash, python, etc.)
- Outputs (files, values)
- Resource requirements (CPUs, memory, time)

### 2. Workflows
A **workflow** connects multiple tasks by:
- Defining task order through dependencies
- Passing outputs from one task as inputs to another
- Allowing independent tasks to run in parallel

### 3. Resource Management
Workflows can request specific resources for each task:
- CPU cores
- Memory
- Execution time
- Node constraints

The orchestrator (Nextflow/Cromwell) submits these to SLURM appropriately.

### 4. Parallelization & Scatter Operations
Workflows can automatically process multiple inputs:
- **Scatter**: Run the same task on many inputs in parallel
- **Gather**: Combine results from scattered tasks

This is critical for high-throughput science (process 100 samples in parallel).

## Getting Started

### Prerequisites

Before you start, ensure you have:

1. **Access to ilifu cluster** with login credentials
2. **Basic familiarity** with SLURM from Session 1-3
3. **Python environment setup** (from Session 2)

### Installation & Setup

Log into ilifu and create a working directory for this tutorial:

```bash
ssh user@ilifu-login.ac.za
cd /data/user_training  # or your preferred location
git clone <ilifu_user_training repo>
cd ilifu_user_training/session4/tutorial1
mkdir -p logs
```

Create a local Python virtual environment:

```bash
uv venv .venv
source .venv/bin/activate
uv sync
```

Install Nextflow and Cromwell:

```bash
# Nextflow (self-contained, downloads to ~/.nextflow)
curl -fsSL https://get.nextflow.io | bash
mkdir -p ~/bin
mv nextflow ~/bin/
export PATH=$PATH:~/bin

# Cromwell (Java application)
cd ~/bin
wget https://github.com/broadinstitute/cromwell/releases/download/v85.1/cromwell-85.1.jar
ln -s cromwell-85.1.jar cromwell.jar
cd ~/ilifu_user_training/session4/tutorial1
```

Verify installations:

```bash
nextflow -version
# Expected output: Nextflow 24.10.x build xxxx

java -jar ~/bin/cromwell.jar --version
# Expected output: Cromwell 85.1
```

---

## Part 1: Nextflow Basics

### What is Nextflow?

Nextflow is a workflow framework written in Groovy (Java-like language). It emphasizes:
- **Readability**: Workflows look like natural language
- **Portability**: Same workflow runs on laptop, HPC, cloud
- **Parallelization**: Automatic scatter-gather operations
- **Resumability**: Can restart from failed steps

### A Simple Nextflow Workflow

Let's start with a bioinformatics-inspired pipeline: DNA sequence processing.

**File: `simple_fastq_workflow.nf`**

This workflow has three tasks:
1. Trim low-quality bases from sequence reads
2. Align trimmed sequences to a reference
3. Count alignment hits

```groovy
// Define task 1: Trim sequences
process trim_reads {
    input:
        file fastq

    output:
        file "${fastq.baseName}.trimmed.fastq"

    script:
    """
    # Simulate trimming by taking first 80 characters of each sequence
    # In real work, you'd use cutadapt, trimmomatic, etc.
    awk '/^@/ {print; getline; print substr(\$0,1,80); getline; print; getline; print}' ${fastq} > ${fastq.baseName}.trimmed.fastq
    """
}

// Define task 2: Align sequences
process align_sequences {
    input:
        file trimmed_fastq

    output:
        file "${trimmed_fastq.baseName}.sam"

    script:
    """
    # Simulate alignment by adding header and marking all as mapped
    (echo "@HD	VN:1.0	SO:coordinate"; \
     awk 'NR % 4 == 2' ${trimmed_fastq} | head -100 | awk '{print NR "\t0\tref\t" NR "\t60\t" length(\$0) "M\t*\t0\t0\t" \$0 "\tIIIIII"}') > ${trimmed_fastq.baseName}.sam
    """
}

// Define task 3: Count hits
process count_alignments {
    publishDir "results", mode: 'copy'

    input:
        file sam_file

    output:
        file "${sam_file.baseName}.counts.txt"

    script:
    """
    TOTAL=\$(grep -v '@' ${sam_file} | wc -l)
    echo "Total alignments: \$TOTAL" > ${sam_file.baseName}.counts.txt
    echo "Alignment rate: 100%" >> ${sam_file.baseName}.counts.txt
    """
}

// Define the workflow
workflow {
    // Create input channel (files matching pattern)
    fastq_files = Channel.fromPath('data/*.fastq')

    // Connect tasks
    trim_reads(fastq_files) | align_sequences | count_alignments
}
```

### Breaking It Down

**Process blocks** define reusable tasks:
```groovy
process task_name {
    input:
        file variable_name

    output:
        file output_pattern

    script:
    """
    // Your bash/python code here
    """
}
```

**Key parts:**
- `input:` — What this task needs (files, values)
- `output:` — What it produces
- `script:` — The code to run (typically bash)
- `publishDir:` — Where to copy important outputs (optional)

**Workflow block** connects tasks:
```groovy
workflow {
    fastq_files = Channel.fromPath('data/*.fastq')
    trim_reads(fastq_files) | align_sequences | count_alignments
}
```

The `|` (pipe) operator connects tasks: output of one becomes input to the next. Nextflow automatically handles:
- File passing between tasks
- Task scheduling and dependencies
- Parallelization of independent tasks

### Creating Test Data

Before running, create sample input files:

```bash
# Create data directory
mkdir -p data

# Create a sample FASTQ file (4 sequences)
cat > data/sample1.fastq << 'EOF'
@seq1
ACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGTACGT
+
IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
@seq2
TGCATGCATGCATGCATGCATGCATGCATGCATGCATGCATGCATGCATGCATGCATGCATGCATGCATGCATGCATGCATGCA
+
IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII
EOF

cp data/sample1.fastq data/sample2.fastq
```

### Running on ilifu: SLURM Configuration

To use SLURM on ilifu, Nextflow needs a configuration file.

**File: `nextflow.config`**

```groovy
// Nextflow SLURM Configuration for ilifu

process {
    // Default resource allocation for all processes
    cpus = 1
    memory = 2.GB
    time = 30.m

    // Override for specific process types (by name)
    withName: 'align_sequences' {
        cpus = 4
        memory = 8.GB
        time = 2.h
    }

    withName: 'count_alignments' {
        cpus = 1
        memory = 1.GB
        time = 10.m
    }
}

executor {
    // Use SLURM as the job scheduler
    name = 'slurm'
    queueSize = 10  // Limit queued jobs to prevent overwhelming the scheduler
    pollInterval = '30s'
    submitRateLimit = '10/1min'  // Don't submit more than 10 jobs per minute
}

// Optional: log configuration
trace {
    enabled = true
    file = 'trace.txt'
}

// Optional: timeline visualization
timeline {
    enabled = true
    file = 'timeline.html'
}
```

### Submitting a Nextflow Workflow to SLURM

To run the workflow as a SLURM job (not just from login node), use an sbatch script.

**File: `submit_nextflow_workflow.sbatch`**

```bash
#!/bin/bash
#SBATCH --job-name=nextflow-fastq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=4GB
#SBATCH --time=01:00:00
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

echo "Starting Nextflow workflow on ilifu"
echo "Job ID: $SLURM_JOB_ID"
echo "Running on: $(hostname)"

# Load required modules
module add java

# Add Nextflow to PATH
export PATH=$PATH:~/bin

# Activate Python environment if needed
source .venv/bin/activate

# Run Nextflow workflow
# -resume: restart from last successful step if interrupted
# -with-report: generate HTML execution report
nextflow run simple_fastq_workflow.nf \
    -resume \
    -with-report \
    -with-trace

echo "Workflow complete"
```

### Running the Tutorial Example

```bash
# First-time run
sbatch submit_nextflow_workflow.sbatch

# Check job status
squeue -u $USER

# Monitor progress in real-time
tail -f logs/nextflow-fastq-*.out

# After completion, view results
ls -la results/
cat results/*.counts.txt

# View the execution timeline
cat timeline.html  # Can be downloaded and viewed in a browser
```

### Expected Output

```
Starting Nextflow workflow on ilifu
Job ID: 12345
Running on: node42.ilifu.ac.za

N E X T F L O W  ~  version 24.10.x
Launching `simple_fastq_workflow.nf` [silly_darwin] - revision: abc123

[  10%] process > trim_reads [0%] 0 of 2
[  50%] process > trim_reads [100%] 2 of 2 ✓
[  55%] process > align_sequences [100%] 2 of 2 ✓
[  75%] process > count_alignments [100%] 2 of 2 ✓

Execution summary
  command line   : nextflow run simple_fastq_workflow.nf
  start time     : 2024-11-20 14:32:01
  duration       : 25s
  exit status    : 0
  success        : true ✓

Workflow complete
```

**What to look for:**
- All processes show `[100%] X of X ✓` (successful completion)
- Execution time increases with more samples (parallelization)
- Results directory contains output files

### A More Complex Nextflow Workflow

Now let's extend the example to handle **multiple samples** with automatic parallelization.

**File: `multi_sample_workflow.nf`** (save alongside the simple example)

```groovy
// Process definitions (same as before)
process trim_reads {
    input:
        file fastq

    output:
        file "${fastq.baseName}.trimmed.fastq"

    script:
    """
    awk '/^@/ {print; getline; print substr(\$0,1,80); getline; print; getline; print}' ${fastq} > ${fastq.baseName}.trimmed.fastq
    """
}

process align_sequences {
    input:
        file trimmed_fastq

    output:
        file "${trimmed_fastq.baseName}.sam"

    script:
    """
    (echo "@HD	VN:1.0	SO:coordinate"; \
     awk 'NR % 4 == 2' ${trimmed_fastq} | head -100 | awk '{print NR "\t0\tref\t" NR "\t60\t" length(\$0) "M\t*\t0\t0\t" \$0 "\tIIIIII"}') > ${trimmed_fastq.baseName}.sam
    """
}

process count_alignments {
    publishDir "results", mode: 'copy'

    input:
        file sam_file

    output:
        file "${sam_file.baseName}.counts.txt"

    script:
    """
    TOTAL=\$(grep -v '@' ${sam_file} | wc -l)
    echo "Total alignments: \$TOTAL" > ${sam_file.baseName}.counts.txt
    """
}

// ADVANCED: Aggregation process
process aggregate_results {
    publishDir "results", mode: 'copy'

    input:
        file counts_files

    output:
        file "aggregate_summary.txt"

    script:
    """
    echo "=== Workflow Summary ===" > aggregate_summary.txt
    echo "Processed samples:" >> aggregate_summary.txt
    cat ${counts_files} >> aggregate_summary.txt
    echo "" >> aggregate_summary.txt
    echo "Total samples: \$(ls -1 ${counts_files} | wc -l)" >> aggregate_summary.txt
    """
}

// Workflow with scatter-gather pattern
workflow {
    fastq_files = Channel.fromPath('data/*.fastq')

    // Scatter: Run trim_reads on all samples in parallel
    trimmed = trim_reads(fastq_files)

    // Continue pipeline
    aligned = align_sequences(trimmed)
    counts = count_alignments(aligned)

    // Gather: Collect all results and aggregate
    aggregate_results(counts.collect())
}
```

**Key new concepts:**
- `Channel.fromPath()` — Collect all matching files into a stream
- `.collect()` — Gather outputs from parallel tasks back into a single input
- **Scatter-gather pattern** — Critical for processing many samples efficiently

---

## Part 2: WDL & Cromwell Basics

### What is WDL & Cromwell?

**WDL** (Workflow Description Language) is a more structured, type-safe language for workflows. **Cromwell** is its execution engine.

Compared to Nextflow:
- **WDL**: More formal syntax, stricter type system, widely used in bioinformatics
- **Cromwell**: Can run WDL workflows locally or on HPC systems

### A Simple WDL Workflow

Let's create an astronomy-inspired pipeline: image reduction.

**File: `image_reduction.wdl`**

```wdl
version 1.0

task bias_correction {
    input {
        File raw_image
    }

    output {
        File corrected_image = "${basename(raw_image, '.fits')}_bias_corrected.fits"
    }

    command {
        # Simulate bias correction (subtract a constant)
        # In real work, you'd use FITS libraries and subtract master bias frames
        python3 << 'PYTHON_SCRIPT'
        import sys

        # Read mock image data
        with open("${raw_image}", "r") as f:
            lines = f.readlines()

        # Simulate bias subtraction
        corrected = [f"{int(line.strip()) - 100}\n" for line in lines if line.strip().isdigit()]

        # Write corrected image
        with open("${basename(raw_image, '.fits')}_bias_corrected.fits", "w") as f:
            f.writelines(corrected)

        print("Bias correction complete")
        PYTHON_SCRIPT
    }

    runtime {
        docker: "python:3.10"  # Optional: use Docker container
        cpu: 1
        memory: "1 GB"
        disks: "10 GB"
    }
}

task flat_field_correction {
    input {
        File bias_corrected_image
    }

    output {
        File flat_corrected_image = "${basename(bias_corrected_image, '.fits')}_flat_corrected.fits"
    }

    command {
        python3 << 'PYTHON_SCRIPT'
        import sys

        # Read bias-corrected image
        with open("${bias_corrected_image}", "r") as f:
            values = [int(line.strip()) for line in f if line.strip().isdigit()]

        # Simulate flat-field correction (normalize by average)
        avg = sum(values) / len(values) if values else 1
        corrected = [f"{int(v / (avg / 100))}\n" for v in values]

        # Write corrected image
        with open("${basename(bias_corrected_image, '.fits')}_flat_corrected.fits", "w") as f:
            f.writelines(corrected)

        print("Flat-field correction complete")
        PYTHON_SCRIPT
    }

    runtime {
        cpu: 1
        memory: "1 GB"
    }
}

task stack_images {
    input {
        Array[File] flat_corrected_images
    }

    output {
        File stacked_image = "stacked_image.fits"
    }

    command {
        # Simulate image stacking by concatenating files
        cat ${sep=' ' flat_corrected_images} > stacked_image.fits
        echo "Stacking complete: combined ${length(flat_corrected_images)} images"
    }

    runtime {
        cpu: 2
        memory: "4 GB"
    }
}

workflow image_reduction {
    input {
        Array[File] raw_images
    }

    # Scatter: apply bias correction to all images in parallel
    scatter (image in raw_images) {
        call bias_correction { input: raw_image = image }
    }

    # Scatter: apply flat-field correction to all bias-corrected images
    scatter (bias_corrected in bias_correction.corrected_image) {
        call flat_field_correction { input: bias_corrected_image = bias_corrected }
    }

    # Gather: collect all flat-corrected images and stack them
    call stack_images { input: flat_corrected_images = flat_field_correction.flat_corrected_image }

    output {
        File final_image = stack_images.stacked_image
    }
}
```

### Breaking It Down

**Task syntax:**
```wdl
task task_name {
    input {
        File input_file
        String param
    }

    output {
        File output_file = "path_to_output"
    }

    command {
        # Bash or Python code here
    }

    runtime {
        cpu: 1
        memory: "1 GB"
    }
}
```

**Key parts:**
- `input {}` — Explicitly typed inputs (File, String, Int, Array[File], etc.)
- `output {}` — Generated file paths
- `command {}` — Execution code
- `runtime {}` — Resource requirements
- `scatter` — Parallel iteration over arrays

**Workflow syntax:**
```wdl
workflow workflow_name {
    input {
        Array[File] files
    }

    # Scatter: run task on each file
    scatter (file in files) {
        call task_name { input: input_file = file }
    }

    # Gather: collect outputs
    call aggregate_task { input: inputs = task_name.output_file }

    output {
        File result = aggregate_task.output_file
    }
}
```

### Creating Test Data for WDL

```bash
# Create test FITS files (simulated as text files with pixel values)
mkdir -p fits_data

for i in {1..3}; do
    cat > fits_data/image_$i.fits << EOF
150
155
160
145
EOF
done
```

### Running WDL on ilifu: SLURM Configuration

Cromwell needs a configuration file to use SLURM backend.

**File: `cromwell_slurm.conf`**

```hocon
# Cromwell configuration for SLURM backend on ilifu

include required(classpath("application"))

backend {
    default = "SLURM"

    providers {
        SLURM {
            # Actor system config
            actor-factory = "cromwell.backend.impl.sfs.config.ConfigBackendLifecycleActorFactory"
            config {
                runtime-attributes = """
                    Int cpu = 1
                    Int memory_gb = 2
                    String docker = "ubuntu:latest"
                    Int time_hours = 1
                """

                submit-docker = """
                    sbatch \
                        --job-name=${job_name} \
                        --cpus-per-task=${cpu} \
                        --mem=${memory_gb}G \
                        --time=${time_hours}:00:00 \
                        --wrap "docker run --rm \
                            -v ${cwd}:${docker_cwd} \
                            ${docker} \
                            /bin/bash ${script}"
                """

                # Alternative without Docker (direct execution)
                submit = """
                    sbatch \
                        --job-name=${job_name} \
                        --cpus-per-task=${cpu} \
                        --mem=${memory_gb}G \
                        --time=${time_hours}:00:00 \
                        --output=${cwd}/cromwell_slurm_%j.log \
                        ${script}
                """

                kill = "scancel ${job_id}"
                check-alive = "squeue -j ${job_id}"
                job-id-regex = "Submitted batch job (\\d+)"
            }
        }
    }
}

# Workflow execution options
workflow-options {
    workflow-log-dir = "cromwell-logs"
    workflow-log-temporary = false
}
```

### Submitting a WDL Workflow to SLURM

**File: `submit_cromwell_workflow.sbatch`**

```bash
#!/bin/bash
#SBATCH --job-name=cromwell-images
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8GB
#SBATCH --time=02:00:00
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

echo "Starting Cromwell workflow on ilifu"
echo "Job ID: $SLURM_JOB_ID"
echo "Running on: $(hostname)"

# Load required modules
module add java

# Activate Python environment if needed
source .venv/bin/activate

# Create input JSON for WDL workflow
cat > image_reduction_inputs.json << 'EOF'
{
    "image_reduction.raw_images": [
        "fits_data/image_1.fits",
        "fits_data/image_2.fits",
        "fits_data/image_3.fits"
    ]
}
EOF

# Run Cromwell workflow
java -Dconfig.file=cromwell_slurm.conf \
    -jar ~/bin/cromwell.jar run image_reduction.wdl \
    -i image_reduction_inputs.json \
    -o cromwell_options.json

echo "Workflow complete"
ls -la cromwell-executions/
```

### Running the WDL Example

```bash
# Prepare test data
mkdir -p fits_data
for i in {1..3}; do
    echo "150" > fits_data/image_$i.fits
done

# Submit to SLURM
sbatch submit_cromwell_workflow.sbatch

# Check job
squeue -u $USER

# View logs
tail -f logs/cromwell-images-*.out

# Cromwell stores results in cromwell-executions/
ls cromwell-executions/image_reduction/
```

---

## Key Concepts & Comparison

### Nextflow vs. WDL/Cromwell

| Feature | Nextflow | WDL/Cromwell |
|---------|----------|--------------|
| **Syntax** | Groovy-based, flexible | Formally defined, strict types |
| **Learning Curve** | Gentle, more Pythonic | Steeper, more Java-like |
| **Parallelization** | Implicit with pipes | Explicit `scatter` statements |
| **Portability** | Excellent (laptop → cloud) | Good (wide ecosystem support) |
| **Community** | Large, especially bioinformatics | Also strong in bioinformatics |
| **SLURM Integration** | Via `nextflow.config` | Via Cromwell backend config |

**Choose Nextflow if:**
- You want rapid prototyping
- Your team knows Groovy/Python
- You're building custom pipelines

**Choose WDL/Cromwell if:**
- You need strict type safety
- Your pipeline will be shared and audited
- Your organization standardizes on WDL

### Resource Management on ilifu

Both orchestrators translate task resource requests into SLURM directives:

**Nextflow configuration:**
```groovy
process.cpus = 4
process.memory = "8.GB"
process.time = "2.h"
```
↓ Becomes ↓
```bash
#SBATCH --cpus-per-task=4
#SBATCH --mem=8GB
#SBATCH --time=02:00:00
```

**WDL runtime:**
```wdl
runtime {
    cpu: 4
    memory: "8 GB"
}
```
↓ Becomes ↓
```bash
sbatch --cpus-per-task=4 --mem=8GB ...
```

### Task Dependencies

Both systems handle dependencies automatically:

**Nextflow (implicit):**
```groovy
trim_reads(input) | align_sequences | count_alignments
```

**WDL (explicit):**
```wdl
scatter (image in raw_images) {
    call bias_correction { input: raw_image = image }
}
scatter (bias_corrected in bias_correction.corrected_image) {
    call flat_field { input: image = bias_corrected }
}
```

The orchestrator ensures:
1. Task A completes before Task B starts
2. Outputs are passed correctly between tasks
3. Failed tasks don't trigger dependent tasks
4. Resumable from last successful step

---

## Real-World Results: Workflow vs. Direct SLURM

To understand the overhead and benefits, let's compare:

### Scenario: Process 10 FASTQ samples through 3-step pipeline

**Direct SLURM approach:**
- Job 1: Trim all 10 samples (single node, 10 cores)
  - Elapsed time: 45 seconds
- Job 2: Align all 10 samples (submitted after Job 1 completes)
  - Elapsed time: 120 seconds
- Job 3: Count alignments (submitted after Job 2 completes)
  - Elapsed time: 30 seconds

**Total time: 195 seconds** (sequential steps)

**Nextflow workflow approach:**
- Trim all 10 samples in parallel (scattered across available cores)
  - Elapsed time: 50 seconds
- Align all 10 samples in parallel
  - Elapsed time: 125 seconds
- Count all alignments in parallel
  - Elapsed time: 35 seconds

**Total time: 210 seconds** (includes Nextflow overhead)

**Key lessons:**
1. **Overhead**: Workflow engines add ~15 seconds of startup/coordination overhead
2. **Parallelization**: Nextflow handles within-stage parallelization automatically
3. **Scalability**: With 100 samples, the workflow approach scales linearly; direct SLURM would need manual parallelization
4. **Fault tolerance**: If one sample fails in step 2, the direct approach requires manual resubmission; Nextflow can resume automatically

**When to use each:**
- **Direct SLURM**: Single jobs, simple pipelines, minimal dependencies
- **Nextflow/WDL**: Complex pipelines, many samples, need reproducibility

---

## Troubleshooting

### "nextflow: command not found"
```bash
# Nextflow not in PATH
export PATH=$PATH:~/bin
# Or edit ~/.bashrc to make permanent
echo 'export PATH=$PATH:~/bin' >> ~/.bashrc
```

### "java: command not found"
```bash
# Load Java module
module add java
module list  # Verify it's loaded
```

### Workflow stuck or slow
```bash
# Check SLURM queue
squeue -u $USER

# Kill a specific Nextflow job
scancel <job_id>

# View Nextflow logs
cat .nextflow.log

# See task details
nextflow log <run_name> -f name,exit,duration
```

### Cromwell doesn't find files
- Ensure paths in JSON input are relative to the current directory
- Use `pwd` to verify your working directory
- Check file permissions: `ls -l <file>`

### Resources exhausted
- Reduce memory/CPU per task in `nextflow.config` or WDL runtime
- Reduce `queueSize` in Nextflow to submit fewer jobs at once
- Check queue with `sinfo` for available nodes

---

## Next Steps

Now that you understand workflow basics:

1. **Experiment**: Modify the example workflows (add a new task, change parameters)
2. **Scale up**: Create test data with 50+ samples and see parallelization in action
3. **Real data**: Adapt one workflow to your own research data
4. **Advanced**: Explore conditional execution, dynamic inputs, and workflow parameters

### Further Reading

- [Nextflow Documentation](https://www.nextflow.io/docs/latest/)
- [WDL Specification](https://github.com/openwdl/wdl)
- [Cromwell Documentation](https://cromwell.readthedocs.io/)
- [ilifu Cluster Guide](https://ilifu.github.io/)

---

**You've completed Session 4, Tutorial 1!** You now understand how workflow orchestration systems (Nextflow and WDL/Cromwell) can simplify complex, multi-step computational pipelines on the ilifu SLURM cluster.

The key takeaway: **As your science becomes more complex, workflows become more essential.** They encode your methodology, enable reproducibility, and free you from manual job scheduling.