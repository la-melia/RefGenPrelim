#!/bin/bash
#SBATCH --job-name=mummer_array
#SBATCH --output=logs/mummer_%a.out
#SBATCH --error=logs/mummer_%a.err
#SBATCH --nodes=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=64G
#SBATCH --time=08:00:00
#SBATCH --array=0-2                  # 0=trif, 1=beau, 2=taiz

# 1. Variables & Species Mapping
DIR="/project/gbru_sweetpotato/RefGenPrelim"
OUT_DIR="results/mummer_plots"
mkdir -p "$OUT_DIR" logs

SPECIES=("trif" "beau"")
GENOME_FILES=(
    "NSP306_trifida_chr_v3.fa"
    "Beauregard_v4.asm.fa"
)
#removed taiz because only ref

# Pick current species based on array ID
NAME=${SPECIES[$SLURM_ARRAY_TASK_ID]}
GENOME_FILE=${GENOME_FILES[$SLURM_ARRAY_TASK_ID]}

# Paths
REF_GENOME="${DIR}/data/genomes/${GENOME_FILE}"
INPUT_DIR="${DIR}/data/pbsim3/${NAME}"

# --- TOGGLE MODE HERE ---
MODE="sample"   # Options: "reads" for simulated reads or "sample" for the sampled referece seqence
# ------------------------

# 2. Environment
#module load miniconda3
#source activate RefGenPrelim
module load mummer4

# 3. Input Processing Logic
QUERY_FASTA="${OUT_DIR}/query_${NAME}.fasta"
PREFIX="${NAME}_vs_${NAME}_${MODE}"

if [ "$MODE" == "reads" ]; then
	echo "Mode: READS. Subsetting FASTQ for $NAME..."
	zcat ${INPUT_DIR}/*.fq.gz | head -n 100000 | awk 'NR%4==1{printf ">%s\n", substr($0,2)} NR%4==2{print}' > "$QUERY_FASTA"
elif [ "$MODE" == "sample" ]; then
	echo "Mode: sample. Combining .ref files for $NAME..."
	cat ${INPUT_DIR}/*.ref > "$QUERY_FASTA"
else
	echo "Error: Mode must be 'reads' or 'ref'"
	exit 1
fi

# 4. Alignment
echo "Running Nucmer alignment for $PREFIX..."
nucmer -t $SLURM_CPUS_PER_TASK \
       -p "${OUT_DIR}/${PREFIX}" \
       "$REF_GENOME" \
       "$QUERY_FASTA"

# 5. Filter and Plot
echo "Filtering and Plotting..."
delta-filter -m "${OUT_DIR}/${PREFIX}.delta" > "${OUT_DIR}/${PREFIX}.filter.delta"

mummerplot --png --large \
           -p "${OUT_DIR}/${PREFIX}_plot" \
           "${OUT_DIR}/${PREFIX}.filter.delta"

# Cleanup temporary fasta to save space
rm "$QUERY_FASTA"

echo "Complete. Plot saved as ${OUT_DIR}/${PREFIX}_plot.png"
