# Slurm Job Submission

## Overview

Slurm is a job scheduling system for managing compute resources on a cluster. It consists of a login node (where users interact with the system) and many compute nodes (where jobs actually run).

Using a batch script to submit jobs to Slurm is like writing a to-do list for the cluster. Instead of asking the system to run something right now, you write instructions that Slurm will execute automatically when resources become available. Batch scripts allow you to:
- Submit multiple jobs in parallel
- Create job dependencies where one job relies on another's output
- Specify resource requirements (CPU, memory, time)
- Capture logs automatically

Interactive jobs are useful for developing and testing workflows before submitting batch jobs.

## Logging In

Access the Slurm login node via SSH:

```bash
ssh <username>@slurm.ilifu.ac.za
```

### Accessing Compute Nodes

Some activities require direct access to compute nodes (e.g., monitoring a job with `htop`). Use SSH authentication forwarding with the `-A` flag to enable agent forwarding:

```bash
ssh -A <username>@slurm.ilifu.ac.za
```

This allows you to SSH from the login node to compute nodes without re-entering credentials.

## Your First Job: A Minimal Example

Let's start with the simplest possible Slurm job. Here's `minimal.sbatch`:

```bash
#!/bin/bash

echo "Hello World!"
```

### Breaking It Down

- `#!/bin/bash` - Standard shebang line indicating this is a bash script

The script then simply runs `echo "Hello World!"` on a compute node.

### Submitting Your Job

Once logged into the login node, submit the job with:

```bash
sbatch minimal.sbatch
```

Slurm will queue your job. If resources are available, it will run immediately on a compute node.

## Monitoring Your Job

Check the status of your jobs with:

```bash
squeue -u <username>
```

This displays all jobs you've submitted, showing amongst other things, their:
- Job ID
- Name
- Status (RUNNING, PENDING, COMPLETED)

## Adding Output Capture

By default, job output goes nowhere. To capture stdout and stderr to files, add these directives:

```bash
#SBATCH --output=logs/demo-job-%j.out
#SBATCH --error=logs/demo-job-%j.err
```

The `%j` placeholder is replaced with the job ID, ensuring each run has unique log files. Create the `logs` directory before submitting:

```bash
mkdir -p logs
```

## A More Advanced Example: Building Features Incrementally

As jobs become more complex, you'll need more control. Here's `maximal.sbatch` with explanations of each addition.

### Step 1: Add Job Naming

```bash
#SBATCH --job-name=tutorial2_R_container
```

This makes your job easier to identify in `squeue` output instead of seeing just a number. It is also useful when you view past jobs with `sacct`.

### Step 2: Set Time and Memory Limits

```bash
#SBATCH --time=00-00:01:00
#SBATCH --mem=4G
```

- `--time=00-00:01:00` - Maximum runtime: 0 days, 0 hours, 1 minute. Jobs exceeding this are terminated
  - Format: `DD-HH:MM:SS`
  - Set this slightly higher than your expected runtime
  - Helps prevent wasted resources and ensures fair cluster sharing
- `--mem=4G` - Allocate 4 GB of memory to this job
  - Choose based on your application's needs
  - Requesting too little causes out-of-memory errors
  - Requesting too much wastes resources and delays job scheduling

### Step 3: Organize Output Files

```bash
#SBATCH --output=R_container-%j.stdout
#SBATCH --error=R_container-%j.stderr
```

Now stdout and stderr are captured to separate files. The `%j` is replaced with your job ID.

### Step 4: Add Email Notifications

```bash
#SBATCH --mail-user=your@email_address
#SBATCH --mail-type=BEGIN,END,FAIL,TIME_LIMIT_80
```

Slurm will email you when:
- `BEGIN` - Job starts
- `END` - Job completes successfully
- `FAIL` - Job fails
- `TIME_LIMIT_80` - Job uses 80% of allocated time (warning before timeout)

This helps you monitor long-running jobs without checking `squeue` repeatedly.

### Step 5: Specify a Billing Account

```bash
#SBATCH --account=<YOUR_ACCOUNT_NAME>
```

Many clusters require jobs to be billed to a specific project or account. Check with your cluster administrator for the correct account name.

### Step 6: Run Containerized Software

The job itself runs an R script inside a Singularity container:

```bash
singularity exec /software/common/containers/RStudio2023.06.1-524-R4.3.1.sif Rscript hello_world.R
```

Containers provide reproducible software environments packaged with all dependencies. An alternative approach is to load modules (shown commented out):

```bash
# module add R
# Rscript hello_world.R
```

Both approaches work: containers bundle everything together for consistency; while modules load pre-installed software on the system. Choose based on what's available and your needs.

## Complete Advanced Example

Here's the full `maximal.sbatch` with all features:

```bash
#!/bin/bash
#SBATCH --job-name=tutorial2_R_container
#SBATCH --time=00-00:01:00
#SBATCH --mem=4G
#SBATCH --partition=Devel
#SBATCH --output=R_container-%j.stdout
#SBATCH --error=R_container-%j.stderr
#SBATCH --mail-user=your@email_address
#SBATCH --mail-type=BEGIN,END,FAIL,TIME_LIMIT_80
#SBATCH --account=b34-admins-ag

singularity exec /software/common/containers/RStudio2023.06.1-524-R4.3.1.sif Rscript hello_world.R
```

## Summary

Start simple with minimal resource requests, then add features as needed:

1. Basic job → add output capture
2. Add time/memory limits to prevent runaway jobs
3. Add email notifications for long jobs
4. Use containers for reproducible environments
5. Specify billing accounts as required by your cluster

As your jobs become more sophisticated, refer to the Slurm documentation (`man sbatch`) for additional options.
