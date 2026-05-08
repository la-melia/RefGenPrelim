#!/bin/bash
#SBATCH --job-name=simWGSIM
#SBATCH --output=logs/wgsim_%a.out
#SBATCH --error=logs/wgsim_%a.err
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1          # wgsim is single-threaded; 1 CPU is plenty
#SBATCH --mem=4G                   # Memory requirement is very low for wgsim
#SBATCH --time=00:30:00            # Will likely finish in seconds
#SBATCH --array=0-2                # One job for each genome (trif, beau, taiz)

# 1. Setup Variables
DATADIR="/project/gbru_sweetpotato/RefGenPrelim/data"
SPECIES=("trif" "beau" "taiz")
GENOMES=(
    "NSP306_trifida_chr_v3.fa"
    "Beauregard_v4.asm.fa"
    "ipoBat4.fa"
)

NAME=${SPECIES[$SLURM_ARRAY_TASK_ID]}
REF_FILE=${GENOMES[$SLURM_ARRAY_TASK_ID]}
OUTDIR="${DATADIR}/wgsim/${NAME}"

mkdir -p "$OUTDIR" logs

# 2. Environment
module load miniconda3
source activate RefGenPrelim

echo "Starting wgsim simulation for $NAME..."



# 3. Generate Reads
# -N: Number of read pairs (3000 pairs = 6000 reads total)
# -1: Length of the first read (Standard Illumina = 150)
# -2: Length of the second read
# -d: Outer distance between the two reads (insert size)
# -s: Standard deviation of the insert size
# -e: Base error rate (0.02 = 2%)
REF_PATH="${DATADIR}/genomes/${REF_FILE}"
R1_OUT="${OUTDIR}/${NAME}_R1.fq"
R2_OUT="${OUTDIR}/${NAME}_R2.fq"

wgsim -N 3000 \
      -1 150 \
      -2 150 \
      -d 500 \
      -s 50 \
      -e 0.01 \
      "$REF_PATH" \
      "$R1_OUT" \
      "$R2_OUT"
echo "Simulation for $NAME finished. Files saved in $OUTDIR"
