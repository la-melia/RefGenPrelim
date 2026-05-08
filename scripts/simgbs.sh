#!/bin/bash
#SBATCH --job-name=gbs_sim
#SBATCH --output=logs/gbs_%a.out
#SBATCH --error=logs/gbs_%a.err
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --array=0-2

# 1. Setup Variables
DIR="/project/gbru_sweetpotato/RefGenPrelim"
OUT_DIR="${DIR}/data/gbs_sim"
mkdir -p "$OUT_DIR" logs

SPECIES=("trif" "beau" "taiz")
GENOME_FILES=(
    "NSP306_trifida_chr_v3.fa"
    "Beauregard_v4.asm.fa"
    "ipoBat4.fa"
)

NAME=${SPECIES[$SLURM_ARRAY_TASK_ID]}
REF_PATH="${DIR}/data/genomes/${GENOME_FILES[$SLURM_ARRAY_TASK_ID]}"

# 2. Enzyme and Simulation Parameters
# Change these if you are using different enzymes!
ENZYME1="NspI"  # PstI cut site
ENZYME2="ApeKI"    # MspI cut site
READ_LEN=80      # Standard Illumina length
FRAG_MIN=70      # Minimum fragment size to sequence
FRAG_MAX=100      # Maximum fragment size to sequence
READ_COUNT=5000000 # 5 Million reads per sample (typical for GBS)

# 3. Load Environment
module load miniconda3
source activate RefGenPrelim  # Assuming a GBS-sim environment

echo "Simulating GBS reads for $NAME using $ENZYME1 and $ENZYME2..."

# 4. Run GBS-sim
# -g: genome, -e1/e2: enzymes, -n: read count, -l: read length
# -min/max: fragment size selection (In-silico size selection)
gbs-sim.py -g "$REF_PATH" \
           -e "$ENZYME1" \
           -E "$ENZYME2" \
           -n "$READ_COUNT" \
           -l "$READ_LEN" \
           -min "$FRAG_MIN" \
           -max "$FRAG_MAX" \
           -o "${OUT_DIR}/${NAME}_gbs"

echo "Simulation for $NAME complete. Results in $OUT_DIR"
