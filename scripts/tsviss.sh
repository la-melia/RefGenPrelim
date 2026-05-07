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
BAM_DIR="${DIR}/data/bams/iss"
STATS_DIR="${DIR}/results/issaligntsv"
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

# 3. Run the extraction
if [ -f "$INPUT_BAM" ]; then
    # Add a header line to the TSV
    # Including the two parts from the QNAME split
    echo -e "NAME_PART1\tNAME_PART2\tFLAG\tRNAME\tMAPQ\tCIGAR\tQUAL" > "$OUTPUT_TSV"

    # samtools view flags:
    # -F 4 : Filters out unmapped reads
    # -q 30: Filters out reads with MAPQ < 30
    samtools view -F 4 -q $MAPQ_THRESHOLD "$INPUT_BAM" | \
    awk -F'\t' '{ 
        # Split the original QNAME ($1) by underscores to get original read positions
        split($1, h, "_"); 
        
        # Print parts 1 & 2 of the header, plus the requested BAM fields
        # $2=FLAG, $3=RNAME, $5=MAPQ, $6=CIGAR, $11=QUAL
        print h[1] "\t" h[2] "\t" $2 "\t" $3 "\t" $5 "\t" $6 "\t" $11 
    }' >> "$OUTPUT_TSV"

    echo "Saved filtered stats to $OUTPUT_TSV"
else
    echo "Error: $INPUT_BAM not found."
    exit 1
fi
