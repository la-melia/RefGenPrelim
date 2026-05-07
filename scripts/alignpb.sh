#!/bin/bash
#SBATCH --job-name=align_pb_mini
#SBATCH --output=logs/mini_pb_%a.out
#SBATCH --error=logs/mini_pb_%a.err
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=48G                    # Minimap2 is fast but needs RAM for large genomes
#SBATCH --time=04:00:00
#SBATCH --array=0-8

# 1. Setup Variables
DIR="/project/gbru_sweetpotato/RefGenPrelim"
PB_DATA="${DIR}/data/pbsim3"
BAM_DIR="${DIR}/results/data/bams/pb"
mkdir -p "$BAM_DIR" logs

SPECIES=("trif" "taiz")
GENOME_FILES=(
    "NSP306_trifida_chr_v3.fa"
    "Beauregard_v4.asm.fa"
    "ipoBat4.fa"
)

# 2. Matrix Logic
G_IDX=$(( SLURM_ARRAY_TASK_ID / 3 ))
R_IDX=$(( SLURM_ARRAY_TASK_ID % 3 ))

REF_NAME=${SPECIES[$G_IDX]}
READ_NAME=${SPECIES[$R_IDX]}
GENOME_FILE=${GENOME_FILES[$G_IDX]}

REF_PATH="${DIR}/data/${GENOME_FILE}"
READ_DIR="${PB_DATA}/${READ_NAME}"
OUT_BAM="${BAM_DIR}/${REF_NAME}_ref_${READ_NAME}_pb.bam"

echo "Task $SLURM_ARRAY_TASK_ID: Aligning $READ_NAME (Long Reads) to $REF_NAME Reference"

# 3. Environment
module load minimap2 samtools

# 4. Run Minimap2 with "Argument List" Fix
# -ax map-hifi: Optimized for PacBio HiFi (standard for pbsim3 --strategy hifi)
# -t: Use all 16 CPUs
# <(...): We use find to grab all filenames and pipe them through zcat
# This prevents the "Argument list too long" error for the 9,999 files.

minimap2 -ax map-pb -t $SLURM_CPUS_PER_TASK \
    -R "@RG\tID:${READ_NAME}_pb\tSM:${READ_NAME}\tPL:PACBIO" \
    "$REF_PATH" \
    <(find "$READ_DIR" -name "*.fq.gz" | xargs zcat) | \
    samtools sort -@ 4 -o "$OUT_BAM" -

# 5. Index
samtools index "$OUT_BAM"

echo "Done: $OUT_BAM"
