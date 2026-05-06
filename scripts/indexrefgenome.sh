#!/bin/bash
#SBATCH --job-name=idx_genomes
#SBATCH --output=logs/idx_%a.out
#SBATCH --error=logs/idx_%a.err
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4            # BWA index is mostly single-threaded, but samtools can use more
#SBATCH --mem=16G                    # Indexing needs enough RAM to hold the genome
#SBATCH --time=04:00:00
#SBATCH --array=0-2                  # Three genomes (0, 1, 2)



# 1. Setup Environment

module load bwa
module load samtools
mkdir -p logs

# 2. Project Directory (Adjust if your data is elsewhere)
DIR="/project/gbru_sweetpotato/RefGenPrelim/data"

# 3. Define Genome Files in an Array
GENOMES=(
    "NSP306_trifida_chr_v3.fa"
    "Beauregard_v4.asm.fa"
    "ipoBat4.fa"
)



# Pick the genome for THIS task
REFGEN="${DIR}/${GENOMES[$SLURM_ARRAY_TASK_ID]}"
echo "Starting index for: $REFGEN"


# 4. Run BWA Index
# This creates the .bwt, .ann, .amb, .pac, and .sa files
bwa index "$REFGEN"



# 5. Run SAMtools Faidx
# This creates the .fai file (the "table of contents")
samtools faidx "$REFGEN"



# 6. Optional: Create Sequence Dictionary (Highly recommended for GATK or Picard)
# Some downstream tools require a .dict file
# If you have 'picard' or 'gatk' modules, uncomment the next lines:
# module load picard
# java -jar $PICARD_JAR CreateSequenceDictionary R="$REFGEN" O="${REFGEN%.fa}.dict"

echo "Finished indexing $REFGEN"
