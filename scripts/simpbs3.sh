#!/bin/bash
#SBATCH --job-name=pb_GBS
#SBATCH --output=logs/pb_sim_%a.out
#SBATCH --error=logs/pb_sim_%a.err
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=05:00:00
#SBATCH --array=0-2

# 1. Variables & Paths
DIR="/project/gbru_sweetpotato/RefGenPrelim"
DATA_DIR="${DIR}/data"
OUT_BASE="${DATA_DIR}/pbsim3"

# Genomes to process
SPECIES=("trif" "beau" "taiz")
GENOMES=(
    "NSP306_trifida_chr_v3.fa"
    "Beauregard_v4.asm.fa"
    "ipoBat4.fa"
)

# Pick current genome
NAME=${SPECIES[$SLURM_ARRAY_TASK_ID]}
REF="${DATA_DIR}/${GENOMES[$SLURM_ARRAY_TASK_ID]}"
GENOME_OUT="${OUT_BASE}/${NAME}"

mkdir -p "$GENOME_OUT" logs

# 2. Load Environment
# Assuming pbsim3 and biopython are in this environment
module load miniconda3
source activate RefGenPrelim

# 4. Step Two: Simulate PacBio HiFi Reads
# We target 200x depth of the DIGESTED fragments, not the whole genome
pbsim --strategy wgs \
      --method errhmm
      --sample 
      --genome "${GENOME_OUT}/digested_fragments.fa" \
      --depth 200 \
      --prefix "${GENOME_OUT}/${NAME}_pb"

echo "Simulation for $NAME complete."
