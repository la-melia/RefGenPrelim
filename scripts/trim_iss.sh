#!/bin/bash
#SBATCH --job-name=trim_reads
#SBATCH --output=logs/trim_%a.out
#SBATCH --error=logs/trim_%a.err
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=02:00:00
#SBATCH --array=0-2

# 1. Variables
DIR="/project/gbru_sweetpotato/RefGenPrelim"
SPECIES=("trif" "beau" "taiz")
NAME=${SPECIES[$SLURM_ARRAY_TASK_ID]}

IN_DIR="${DIR}/data/iss/${NAME}"
OUT_DIR="${DIR}/data/trimmed_reads/${NAME}"
mkdir -p "$OUT_DIR" logs

# 2. Load Environment
module load miniconda3
source activate RefGenPrelim

echo "Starting Fastp for ${NAME}..."

# 3. Run Fastp
# -q 20: Trim bases with quality < 20 (standard)
# -l 50: Discard reads that become shorter than 50bp after trimming
# --detect_adapter_for_pe: Automatically find and remove adapter sequences
# -w: Number of threads (CPUs)
fastp -i "${IN_DIR}/${NAME}_R1.fastq" \
      -I "${IN_DIR}/${NAME}_R2.fastq" \
      -o "${OUT_DIR}/${NAME}_trimmed_R1.fastq.gz" \
      -O "${OUT_DIR}/${NAME}_trimmed_R2.fastq.gz" \
      -q 20 \
      -l 120 \
      -w $SLURM_CPUS_PER_TASK \
      -j "${OUT_DIR}/${NAME}_fastp.json" \
      -h "${OUT_DIR}/${NAME}_fastp.html"
echo "Trimming for ${NAME} complete. Files saved to ${OUT_DIR}"

echo "Running FastQC on ${NAME} reads..."
# 3. Run FastQC
# -t 4: Uses the 4 CPUs we requested to process files in parallel
# -o: Directs the .html and .zip reports to our results folder
fastqc -t $SLURM_CPUS_PER_TASK \
       -o "$OUT_DIR" \
       ${OUT_DIR}/${NAME}_trimmed_R1.fastq.gz \
       ${OUT_DIR}/${NAME}_trimmed_R2.fastq.gz
echo "FastQC for ${NAME} complete."


