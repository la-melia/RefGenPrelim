#!/bin/bash
#SBATCH --job-name=fastqc_parallel
#SBATCH --output=logs/fastqc_%a.out
#SBATCH --error=logs/fastqc_%a.err
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=01:00:00
#SBATCH --array=0-2                  # One task for each species (trif, beau, taiz)

# 1. Setup Variables
DIR="/project/gbru_sweetpotato/RefGenPrelim"
SPECIES=("trif" "beau" "taiz")
NAME=${SPECIES[$SLURM_ARRAY_TASK_ID]}

INPUT_DIR="${DIR}/data/wgsim/${NAME}"
OUT_DIR="${INPUT_DIR}/qcpre"

mkdir -p "$OUT_DIR" logs

# 2. Load Module
module load fastqc

echo "Running FastQC on ${NAME} reads..."

# 3. Run FastQC
# -t 4: Uses the 4 CPUs we requested to process files in parallel
# -o: Directs the .html and .zip reports to our results folder
fastqc -t $SLURM_CPUS_PER_TASK \
       -o "$OUT_DIR" \
       ${INPUT_DIR}/${NAME}_R1.fastq \
       ${INPUT_DIR}/${NAME}_R2.fastq

echo "FastQC for ${NAME} complete."
