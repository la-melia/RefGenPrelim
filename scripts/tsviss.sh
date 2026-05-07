#!/bin/bash
#SBATCH --job-name=extract_stats
#SBATCH --output=logs/stats_%a.out
#SBATCH --error=logs/stats_%a.err
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1            # This task is low CPU, mostly Disk I/O
#SBATCH --mem=4G                     # Low memory requirement
#SBATCH --time=01:00:00
#SBATCH --array=0-8                  # 9 combinations (3x3 matrix)



# 1. Setup Variables
DIR="/project/gbru_sweetpotato/RefGenPrelim"
BAM_DIR="${DIR}/data/bams"
STATS_DIR="${DIR}/data/issaligntsv"
mkdir -p "$STATS_DIR" logs



# Define the species list
SPECIES=("trif" "beau" "taiz")



# 2. Determine which BAM file this task handles
# Task 0,1,2 = Genome 0; Task 3,4,5 = Genome 1; Task 6,7,8 = Genome 2
G_IDX=$(( SLURM_ARRAY_TASK_ID / 3 ))
# Task 0,3,6 = Read 0; Task 1,4,7 = Read 1; Task 2,5,8 = Read 2
R_IDX=$(( SLURM_ARRAY_TASK_ID % 3 ))



REF_NAME=${SPECIES[$G_IDX]}
READ_NAME=${SPECIES[$R_IDX]}



# Construct filenames based on your alignment script output
INPUT_BAM="${BAM_DIR}/${REF_NAME}_ref_${READ_NAME}_reads.bam"
OUTPUT_TSV="${STATS_DIR}/${REF_NAME}_vs_${READ_NAME}_mapping.tsv"



echo "Processing Task $SLURM_ARRAY_TASK_ID: $INPUT_BAM"



# 3. Load Samtools
module load samtools



# 4. Run the extraction
# We check if the BAM exists first to avoid empty files
if [ -f "$INPUT_BAM" ]; then
    samtools view "$INPUT_BAM" | \
    awk -F'\t' '{ 
        split($1, header, "_"); 
        print header[1] "\t" header[2] "\t" $3 "\t" $4 "\t" $5 
    }' > "$OUTPUT_TSV"
    echo "Saved stats to $OUTPUT_TSV"
else
    echo "Error: $INPUT_BAM not found."
    exit 1
fi
