#!/bin/bash
#SBATCH --job-name=Ref_QC
#SBATCH --output=logs/qc_%a.out
#SBATCH --error=logs/qc_%a.err
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=32G
#SBATCH --time=12:00:00
#SBATCH --array=0-2

# 1. Variables & Paths
DIR="/project/gbru_sweetpotato/RefGenPrelim"
DATA_DIR="${DIR}/data"
OUT_BASE="${DIR}/results/reference_stats"

SPECIES=("trif" "beau" "taiz")
GENOMES=(
    "NSP306_trifida_chr_v3.fa"
    "Beauregard_v4.asm.fa"
    "ipoBat4.fa"
)

# Pick current genome based on array ID
NAME=${SPECIES[$SLURM_ARRAY_TASK_ID]}
ASSEMBLY="${DATA_DIR}/${GENOMES[$SLURM_ARRAY_TASK_ID]}"
QC_OUT="${OUT_BASE}/qcref/${NAME}"

mkdir -p "$QC_OUT" logs

# 2. Environment Setup
# Assuming tools are installed in your RefGenPrelim environment
module load miniconda3
source activate assemblyqc

# Check if assembly exists
if [ ! -f "$ASSEMBLY" ]; then
    echo "Error: Assembly file '$ASSEMBLY' not found!"
    exit 1
fi

echo "Analyzing Reference: $NAME ($ASSEMBLY)"

######################################
# 3. Run assembly-stats
# Provides N50, total length, and contig counts
echo "Running assembly-stats..."
assembly-stats "$ASSEMBLY" > "${QC_OUT}/${NAME}_assembly_stats.txt"

######################################
# 4. Run BUSCO
# Measures "completeness" by looking for conserved plant genes
# Lineage: solanales_odb10 (Sweet potato order)
echo "Running BUSCO..."
run_BUSCO.py -i "$ASSEMBLY" \
      -l eudicots_odb10 \
      -o "${NAME}_busco" \
      -m genome \
      -c $SLURM_CPUS_PER_TASK \
      --out_path "$QC_OUT" \
      --offline \
      -f

######################################
# 5. Run QUAST
# Provides detailed assembly metrics and plots
echo "Running QUAST..."
quast.py -t $SLURM_CPUS_PER_TASK \
         -o "${QC_OUT}/quast" \
         "$ASSEMBLY"

echo "Analysis for $NAME complete."
