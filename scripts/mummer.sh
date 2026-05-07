#!/bin/bash
#SBATCH --job-name=mummer_dual
#SBATCH --output=logs/mummer_%J.out
#SBATCH --error=logs/mummer_%J.err
#SBATCH --nodes=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=64G              # Bumped memory for genome-scale alignment
#SBATCH --time=06:00:00

# 1. Variables
REF_GENOME="/project/gbru_sweetpotato/RefGenPrelim/data/NSP306_trifida_chr_v3.fa"
INPUT_DIR="/project/gbru_sweetpotato/RefGenPrelim/data/pbsim3/trif"
OUT_DIR="results/mummer_plots"
GEN="trif-trif"

# CHOOSE YOUR MODE: "reads" for .fq.gz or "ref" for .ref files
MODE="reads" 

mkdir -p "$OUT_DIR" logs
module load miniconda3
source activate RefGenPrelim

# 2. Input Processing Logic
if [ "$MODE" == "reads" ]; then
    echo "Mode: READS. Subsetting and converting FASTQ to FASTA..."
    PREFIX="${GEN}_${MODE}"
    # Combine a subset of reads (first 100k lines)
    zcat ${INPUT_DIR}/*.fq.gz | head -n 100000 | \
    awk 'NR%4==1{printf ">%s\n", substr($0,2)} NR%4==2{print}' > ${OUT_DIR}/query.fasta

elif [ "$MODE" == "ref" ]; then
    echo "Mode: REF. Combining .ref files..."
    PREFIX="${GEN}_${MODE}"
    # Concatenate all .ref files into one query file
    cat ${INPUT_DIR}/*.ref > ${OUT_DIR}/query.fasta
else
    echo "Error: Mode must be 'reads' or 'ref'"
    exit 1
fi

# 3. Alignment
echo "Running Nucmer alignment for $PREFIX..."
nucmer -t $SLURM_CPUS_PER_TASK \
       -p ${OUT_DIR}/${PREFIX} \
       $REF_GENOME \
       ${OUT_DIR}/query.fasta

# 4. Filter and Plot
echo "Filtering and Plotting..."
delta-filter -m ${OUT_DIR}/${PREFIX}.delta > ${OUT_DIR}/${PREFIX}.filter.delta

# -m in delta-filter is "many-to-many" alignment, 
# which is better for whole-genome vs whole-genome comparisons.

mummerplot --png --large \
           -p ${OUT_DIR}/${PREFIX}_plot \
           ${OUT_DIR}/${PREFIX}.filter.delta

echo "Complete. Plot saved as ${OUT_DIR}/${PREFIX}_plot.png"
