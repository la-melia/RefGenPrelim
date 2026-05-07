#!/bin/bash
#SBATCH --job-name=simISS
#SBATCH --output=logs/iss_%a.out
#SBATCH --error=logs/iss_%a.err
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16           # Increased for speed
#SBATCH --mem=32G                    # Increased for 200M reads
#SBATCH --time=08:00:00
#SBATCH --array=0-2                  # One job for each genome (trif, beau, taiz)

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
OUTDIR="${DATADIR}/iss/${NAME}"

mkdir -p "$OUTDIR" logs

# 2. Environment
module load miniconda3
source activate RefGenPrelim

echo "Starting simulation for $NAME using $SLURM_CPUS_PER_TASK CPUs..."

# 3. Generate Reads (The Speed Up)
# --cpus: Tells ISS to use all requested threads
# --n_reads: 200M is huge; ensure you have the disk space!

iss generate \
    --genomes "${DATADIR}/${REF_FILE}" \
    --model HiSeq \
    --n_reads 200M \
    --cpus $SLURM_CPUS_PER_TASK \
    --output "${OUTDIR}/${NAME}"
echo "Simulation for $NAME finished."
