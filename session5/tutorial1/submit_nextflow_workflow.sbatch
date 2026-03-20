#!/bin/bash
#SBATCH --job-name=nextflow-fastq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=4GB
#SBATCH --time=01:00:00
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

echo "=========================================="
echo "Starting Nextflow workflow on ilifu"
echo "=========================================="
echo "Job ID: $SLURM_JOB_ID"
echo "Running on: $(hostname)"
echo "Date: $(date)"
echo "Working directory: $(pwd)"
echo ""

# Load required modules
echo "Loading Java module..."
module add java

# Verify Java is available
if ! command -v java &> /dev/null; then
    echo "ERROR: Java module not loaded. Aborting."
    exit 1
fi

# Add Nextflow to PATH
export PATH=$PATH:~/bin

# Verify Nextflow is available
if ! command -v nextflow &> /dev/null; then
    echo "ERROR: Nextflow not found in PATH. Aborting."
    exit 1
fi

# Activate Python virtual environment if it exists
if [ -f .venv/bin/activate ]; then
    echo "Activating Python virtual environment..."
    source .venv/bin/activate
fi

echo ""
echo "Environment:"
echo "  Nextflow version: $(nextflow -version | head -1)"
echo "  Java version: $(java -version 2>&1 | head -1)"
echo ""

# Create data directory if it doesn't exist
if [ ! -d "data" ]; then
    echo "Creating data directory with sample FASTQ files..."
    mkdir -p data

    # Create sample FASTQ file
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
    echo "  Created sample1.fastq and sample2.fastq"
fi

echo "=========================================="
echo "Running Nextflow workflow"
echo "=========================================="
echo ""

# Run Nextflow workflow
# -resume: restart from last successful step if interrupted
# -with-report: generate HTML execution report
# -with-trace: generate trace file for detailed analysis
nextflow run simple_fastq_workflow.nf \
    -resume \
    -with-report \
    -with-trace

WORKFLOW_EXIT=$?

echo ""
echo "=========================================="
echo "Workflow execution complete"
echo "=========================================="
echo "Exit status: $WORKFLOW_EXIT"
echo ""

# List output files if they exist
if [ -d "results" ]; then
    echo "Results directory contents:"
    ls -lh results/
fi

echo ""
echo "View execution timeline: cat timeline.html"
echo "View execution report: cat report.html"

exit $WORKFLOW_EXIT
