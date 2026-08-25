#!/bin/bash
#SBATCH --job-name=cromwell-images
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8GB
#SBATCH --time=02:00:00
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

echo "=========================================="
echo "Starting Cromwell workflow on ilifu"
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

# Verify Cromwell is available
if [ ! -f ~/bin/cromwell.jar ]; then
    echo "ERROR: Cromwell JAR not found at ~/bin/cromwell.jar"
    echo "Please download Cromwell first:"
    echo "  cd ~/bin"
    echo "  wget https://github.com/broadinstitute/cromwell/releases/download/v85.1/cromwell-85.1.jar"
    echo "  ln -s cromwell-85.1.jar cromwell.jar"
    exit 1
fi

# Activate Python virtual environment if it exists
if [ -f .venv/bin/activate ]; then
    echo "Activating Python virtual environment..."
    source .venv/bin/activate
fi

echo ""
echo "Environment:"
echo "  Cromwell version: $(java -jar ~/bin/cromwell.jar --version 2>&1)"
echo "  Java version: $(java -version 2>&1 | head -1)"
echo ""

# Create fits_data directory with sample data if it doesn't exist
if [ ! -d "fits_data" ]; then
    echo "Creating fits_data directory with sample FITS files..."
    mkdir -p fits_data

    # Create sample FITS files (simulated as text files with pixel values)
    for i in {1..3}; do
        cat > fits_data/image_$i.fits << EOF
150
155
160
145
EOF
    done
    echo "  Created image_1.fits, image_2.fits, image_3.fits"
fi

echo ""
echo "Creating input JSON for WDL workflow..."

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

echo "  Created image_reduction_inputs.json"

echo ""
echo "=========================================="
echo "Running Cromwell workflow"
echo "=========================================="
echo ""

# Run Cromwell workflow
java -Dconfig.file=cromwell_slurm.conf \
    -jar ~/bin/cromwell.jar run image_reduction.wdl \
    -i image_reduction_inputs.json

WORKFLOW_EXIT=$?

echo ""
echo "=========================================="
echo "Workflow execution complete"
echo "=========================================="
echo "Exit status: $WORKFLOW_EXIT"
echo ""

# List execution outputs
if [ -d "cromwell-executions" ]; then
    echo "Workflow execution directory:"
    ls -la cromwell-executions/
    echo ""
    echo "To view workflow outputs, check:"
    echo "  cromwell-executions/image_reduction/"
fi

exit $WORKFLOW_EXIT
