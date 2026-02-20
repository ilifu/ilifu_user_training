#!/usr/bin/env bash
# Record Asciinema demos for the Slurm tutorial presentation.
# Run this script ON the ilifu cluster (slurm.ilifu.ac.za).
#
# Prerequisites:
#   pip install asciinema   (or use the system-installed version)
#
# Usage:
#   bash record.sh basic     # Record the basic demo
#   bash record.sh advanced  # Record the advanced demo
#   bash record.sh all       # Record both demos

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

record_basic() {
    echo "🎬 Recording basic demo..."
    echo "Steps to perform:"
    echo "  1. cat minimal.sbatch"
    echo "  2. sbatch minimal.sbatch"
    echo "  3. squeue -u \$USER"
    echo "  4. (wait for completion)"
    echo "  5. cat slurm-<jobid>.out"
    echo ""
    echo "Press Enter to start recording, Ctrl+D to stop."
    read -r

    asciinema rec \
        --title "Slurm Basic Demo — ilifu Tutorial" \
        --cols 100 \
        --rows 24 \
        --overwrite \
        "${SCRIPT_DIR}/demo_basic.cast"
}

record_advanced() {
    echo "🎬 Recording advanced demo..."
    echo "Steps to perform:"
    echo "  1. cat maximal.sbatch"
    echo "  2. sbatch maximal.sbatch"
    echo "  3. squeue -u \$USER  (note the job-name)"
    echo "  4. (wait for completion)"
    echo "  5. cat R_container-<jobid>.stdout"
    echo "  6. cat R_container-<jobid>.stderr"
    echo ""
    echo "Press Enter to start recording, Ctrl+D to stop."
    read -r

    asciinema rec \
        --title "Slurm Advanced Demo — ilifu Tutorial" \
        --cols 100 \
        --rows 24 \
        --overwrite \
        "${SCRIPT_DIR}/demo_advanced.cast"
}

case "${1:-all}" in
    basic)    record_basic ;;
    advanced) record_advanced ;;
    all)
        record_basic
        record_advanced
        ;;
    *)
        echo "Usage: $0 {basic|advanced|all}"
        exit 1
        ;;
esac

echo "✅ Done! Recordings saved to ${SCRIPT_DIR}/"
echo "   View locally:  asciinema play demo_basic.cast"
echo "   Upload:        asciinema upload demo_basic.cast"
