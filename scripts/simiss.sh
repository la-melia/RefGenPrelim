#!/bin/bash
#SBATCH --job-name=simDArT          # Job name
#SBATCH --output=logs/simiss%J.out     # Standard output file
#SBATCH --error=logs/simiss%J.err      # Standard error file
#SBATCH --nodes=1                    # Number of nodes
#SBATCH --cpus-per-task=4            # Number of CPU cores per task
#SBATCH --mem=8G
#SBATCH --time=08:00:00


# simulate 1 million reads illumina HiSeq Reads with InSilicoSeq

# data directory
DATADIR="/project/gbru_sweetpotato/RefGenPrelim/data"
TRIF="NSP306_trifida_chr_v3.fa"
BEAU="Beauregard_v4.asm.fa"
TAIZ="ipoBat4.fa"

# build output folders if doesnt exist
TRIFOUT="${DATADIR}/iss/trif"
BEAUOUT="${DATADIR}/iss/beau"
TAIZOUT="${DATADIR}/iss/taiz"
mkdir -p "${TRIFOUT}"
mkdir -p "${BEAUOUT}"
mkdir -p "${TAIZOUT}"

#activate conda envi - load miniconda and then activate envi
module load miniconda3
source activate RefGenPrelim

#generate reads
#requesting 6 thousand reads
iss generate --genomes "${DATADIR}/genomes/${TRIF}" --model HiSeq -n 6K -o "${TRIFOUT}/trif"
iss generate --genomes "${DATADIR}/genomes/${BEAU}" --model HiSeq -n 6K -o "${BEAUOUT}/beau"
iss generate --genomes "${DATADIR}/genomes/${TAIZ}" --model HiSeq -n 6K -o "${TAIZOUT}/taiz"

# align reads to genome

#filter to dart bed regions
