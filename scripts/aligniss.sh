#!/bin/bash
#SBATCH --job-name=align_matrix
#SBATCH --output=logs/align_%a.out
#SBATCH --error=logs/align_%a.err
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=12G                 # Slightly increased for safety
#SBATCH --time=02:00:00
#SBATCH --array=0-8               # 9 combinations total (0,1,2,3,4,5,6,7,8)



# 1. Setup Variables
DIR="/project/gbru_sweetpotato/RefGenPrelim"
BAM_DIR="${DIR}/data/bams"
mkdir -p "$BAM_DIR" logs



# Define the species list
SPECIES=("trif" "beau" "taiz")
# Define the actual file names for the genomes
# (Make sure these match your actual filenames in the data folder)

GENOME_FILES=(
    "NSP306_trifida_chr_v3.fa"
    "Beauregard_v4.asm.fa"
    "ipoBat4.fa"
)



# 2. Determine which combination this task handles
# Task 0,1,2 = Genome 0; Task 3,4,5 = Genome 1; Task 6,7,8 = Genome 2
G_IDX=$(( SLURM_ARRAY_TASK_ID / 3 ))
# Task 0,3,6 = Read 0; Task 1,4,7 = Read 1; Task 2,5,8 = Read 2
R_IDX=$(( SLURM_ARRAY_TASK_ID % 3 ))



REF_NAME=${SPECIES[$G_IDX]}
READ_NAME=${SPECIES[$R_IDX]}
GENOME_FILE=${GENOME_FILES[$G_IDX]}



# 3. Paths to files
REF_PATH="${DIR}/data/${GENOME_FILE}"
R1="${DIR}/data/iss/${READ_NAME}/${READ_NAME}_R1.fastq"
R2="${DIR}/data/iss/${READ_NAME}/${READ_NAME}_R2.fastq"
OUT_BAM="${BAM_DIR}/${REF_NAME}_ref_${READ_NAME}_reads.bam"

echo "Task $SLURM_ARRAY_TASK_ID: Aligning $READ_NAME reads to $REF_NAME genome"
# 4. Run Alignment
module load bwa samtools

# Optimization: Pipe directly to sort and use -@ for multi-threading
bwa mem -t $SLURM_CPUS_PER_TASK \
    -R "@RG\tID:${READ_NAME}\tSM:${READ_NAME}\tPL:ILLUMINA" \
    "$REF_PATH" "$R1" "$R2" | \
    samtools sort -@ $SLURM_CPUS_PER_TASK -o "$OUT_BAM" -

# 5. Index the BAM
samtools index "$OUT_BAM"
echo "Finished $REF_NAME vs $READ_NAME"
