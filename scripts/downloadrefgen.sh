#!/bin/bash
#SBATCH --job-name=downloadrefgen          # Job name
#SBATCH --output=logs/dlrg%J.out     # Standard output file
#SBATCH --error=logs/dlrg%J.err      # Standard error file
#SBATCH --nodes=1                    # Number of nodes
#SBATCH --cpus-per-task=4            # Number of CPU cores per task
#SBATCH --mem=8G
#SBATCH --time=01:00:00


# script to download reference genomes and run MD5Sum

## Genomes
# Beauregard v4 
BEAU_URL="https://sweetpotato.uga.edu/Beauregard_v4_download/Beauregard_v4.asm.fa.gz"
# Trifida v3 (NSP323)
TRIF_URL="https://sweetpotato.uga.edu/download_v3/NSP306_trifida_chr_v3.fa.zip"
#Taizhong 6 v2
TAIZ_URL="http://public-genomes-ngs.molgen.mpg.de/SweetPotato/DOWNLOADS/ipoBat4.fa"

#data folder
DATA_DIR="/project/gbru_sweetpotato/RefGenPrelim/data"
#download data
wget -P ${DATA_DIR} ${BEAU_URL}
wget -P ${DATA_DIR} ${TRIF_URL}
wget -P ${DATA_DIR} ${TAIZ_URL}


