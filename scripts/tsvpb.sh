#!/bin/bash
#SBATCH --job-name=pb_extract
#SBATCH --output=logs/pb_stats_%a.out
#SBATCH --error=logs/pb_stats_%a.err
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=02:00:00
#SBATCH --array=0-8

# 1. Setup Variables
DIR="/project/gbru_sweetpotato/RefGenPrelim"
# Assuming your PacBio BAMs are in a separate subfolder
BAM_DIR="${DIR}/results/data/bams/pb" 
STATS_DIR="${DIR}/results/pacbio_stats"
mkdir -p "$STATS_DIR" logs

MAPQ_THRESHOLD=30
SPECIES=("trif" "beau" "taiz")

# 2. Matrix Logic (3x3)
G_IDX=$(( SLURM_ARRAY_TASK_ID / 3 ))
R_IDX=$(( SLURM_ARRAY_TASK_ID % 3 ))

REF_NAME=${SPECIES[$G_IDX]}
READ_NAME=${SPECIES[$R_IDX]}
INPUT_BAM="${BAM_DIR}/${REF_NAME}_ref_${READ_NAME}_pb.bam"
OUTPUT_TSV="${STATS_DIR}/${REF_NAME}_vs_${READ_NAME}_pbmapping.tsv"

echo "Processing PacBio Task $SLURM_ARRAY_TASK_ID: $INPUT_BAM"

# 3. Load Samtools
module load samtools
# 4. Extraction Logic
if [ -f "$INPUT_BAM" ]; then
    # Header: Added TRUE vs MAP labels for clarity
    echo -e "TRUE_CHR\tTRUE_POS\tTRUE_STRAND\tFLAG\tMAP_CHR\tMAP_POS\tMAPQ\tCIGAR" > "$OUTPUT_TSV"
    # Extraction
    # We exclude the QUAL field here because PacBio QUAL strings are massive 
    # and will make your TSV files several gigabytes larger.
    samtools view -F 4 -q $MAPQ_THRESHOLD "$INPUT_BAM" | \
    awk -F'\t' '{ 
        # PBSIM3 usually uses "!" or "_" as separators. 
        # Here we split by "!" which is standard for PBSIM3. 
        # If your headers use underscores, change "!" to "_" below.
        n = split($1, h, "!");
        # Mapping true values from PBSIM3 header:
        # h[2] is usually Chr, h[3] is Start Pos, h[5] is Strand (+/-)
        true_chr = h[2];
        true_pos = h[3];
        true_dir = h[5];
        # Print logic:
        # $2=FLAG, $3=MAP_CHR, $4=MAP_POS, $5=MAPQ, $6=CIGAR
        print true_chr "\t" true_pos "\t" true_dir "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6
    }' >> "$OUTPUT_TSV"
    echo "Saved filtered stats to $OUTPUT_TSV"
else
    echo "Error: $INPUT_BAM not found."
    exit 1
fi
