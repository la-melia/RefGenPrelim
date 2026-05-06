#!/bin/bash
#SBATCH --job-name=qualimap_matrix
#SBATCH --array=0-3
#SBATCH --mem=16G        # Qualimap needs more than 1.2G!
#SBATCH --cpus-per-task=4
#SBATCH --output=logs/qmap_%A_%a.out
#SBATCH --error=logs/qmap_%A_%a.err


# 1. Variables
DIR="/project/gbru_sweetpotato/RefGenPrelim"
BAM_DIR="${DIR}/data/bams"
OUT_DIR="${DIR}/data/qualimap"
mkdir -p "$OUT_DIR" logs

# Define only the two species you want
SPECIES=("trif" "beau")

# 2. 2x2 Matrix Logic
# Task 0,1 = Genome 0 (trif); Task 2,3 = Genome 1 (beau)
G_IDX=$(( SLURM_ARRAY_TASK_ID / 2 ))
# Task 0,2 = Read 0 (trif); Task 1,3 = Read 1 (beau)
R_IDX=$(( SLURM_ARRAY_TASK_ID % 2 ))

REF_NAME=${SPECIES[$G_IDX]}
READ_NAME=${SPECIES[$R_IDX]}

BAM_FILE="${BAM_DIR}/${REF_NAME}_ref_${READ_NAME}_reads.bam"
RESULTS_DIR="${OUT_DIR}/${REF_NAME}_vs_${READ_NAME}"

# 3. Environment Setup & Java Fix
module load qualimap

# Fix for the 'MaxPermSize' error and memory allocation
export QUALIMAP_JAVA_OPTS="-Xms4G -Xmx12G"

# 4. Run Qualimap
if [ -f "$BAM_FILE" ]; then
    echo "Running Qualimap on $BAM_FILE"
    qualimap bamqc \
        -bam "$BAM_FILE" \
        -outdir "$RESULTS_DIR" \
        -nt $SLURM_CPUS_PER_TASK \
        --java-mem-size=12G
else
    echo "Error: $BAM_FILE not found!"
    exit 1
fi
