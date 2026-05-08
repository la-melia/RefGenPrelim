#!/bin/bash
#SBATCH --job-name=GBS_Master
#SBATCH --output=logs/master_%a.out
#SBATCH --error=logs/master_%a.err
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=05:00:00
#SBATCH --array=0-8

# ---------------------------------------------------------
# 1. Setup Variables & Paths
# ---------------------------------------------------------

DIR="/project/gbru_sweetpotato/RefGenPrelim"
GENOME_DIR="${DIR}/data/genomes"
READ_DIR="${DIR}/data/wgsim"
RESULTS_DIR="${DIR}/results/matrix_analysis"

MAPQ_THRESHOLD=0 # Keep all for polyploid analysis
SPECIES=("trif" "beau" "taiz")
GENOMES=(
    "NSP306_trifida_chr_v3.fa"
    "Beauregard_v4.asm.fa"
    "ipoBat4.fa"
)



# Matrix Logic: 0,1,2=Ref 0 | 3,4,5=Ref 1 | 6,7,8=Ref 2
G_IDX=$(( SLURM_ARRAY_TASK_ID / 3 ))
R_IDX=$(( SLURM_ARRAY_TASK_ID % 3 ))

REF_NAME=${SPECIES[$G_IDX]}
READ_NAME=${SPECIES[$R_IDX]}
REF_FILE="${GENOME_DIR}/${GENOMES[$G_IDX]}"

# Define output subfolders
mkdir -p "${RESULTS_DIR}/qc" "${RESULTS_DIR}/trimmed" "${RESULTS_DIR}/bams" "${RESULTS_DIR}/tsv" logs

# ---------------------------------------------------------
# 2. Load Environment
# ---------------------------------------------------------
module load miniconda3
source activate RefGenPrelim
module load bwa
module load samtools
# Ensure fastp, fastqc, bwa, and samtools are in this env

echo "Task $SLURM_ARRAY_TASK_ID: Aligning $READ_NAME reads to $REF_NAME reference"

# ---------------------------------------------------------
# 3. Trimming & QC (Only run if not already done by another task)
# ---------------------------------------------------------

RAW_R1="${READ_DIR}/${READ_NAME}/${READ_NAME}_R1.fq"
RAW_R2="${READ_DIR}/${READ_NAME}/${READ_NAME}_R2.fq"
TRIM_R1="${RESULTS_DIR}/trimmed/${READ_NAME}_trim_R1.fq.gz"
TRIM_R2="${RESULTS_DIR}/trimmed/${READ_NAME}_trim_R2.fq.gz"

if [ ! -f "$TRIM_R1" ]; then
    echo "Running fastp and FastQC for $READ_NAME..."
    fastp -i "$RAW_R1" -I "$RAW_R2" \
          -o "$TRIM_R1" -O "$TRIM_R2" \
          --html "${RESULTS_DIR}/qc/${READ_NAME}_fastp.html" \
          --thread $SLURM_CPUS_PER_TASK

    fastqc -t $SLURM_CPUS_PER_TASK "$TRIM_R1" "$TRIM_R2" -o "${RESULTS_DIR}/qc/"
else
    echo "Trimmed files for $READ_NAME already exist. Skipping to alignment."
fi

# ---------------------------------------------------------
# 4. Alignment (BWA MEM)
# ---------------------------------------------------------
OUT_BAM="${RESULTS_DIR}/bams/${REF_NAME}_vs_${READ_NAME}.bam"

echo "Aligning to $REF_NAME..."
# Indexing is fast, but usually done once. Check for index file.
if [ ! -f "${REF_FILE}.bwt" ]; then
    bwa index "$REF_FILE"
fi
bwa mem -t $SLURM_CPUS_PER_TASK -a "$REF_FILE" "$TRIM_R1" | \

samtools view -h -F 4 - | \
samtools sort -@ 4 -o "$OUT_BAM"
samtools index "$OUT_BAM"
# ---------------------------------------------------------

# 5. Advanced Extraction (Fixed Syntax)

# ---------------------------------------------------------

OUTPUT_TSV="${RESULTS_DIR}/tsv/${REF_NAME}_vs_${READ_NAME}_coords.tsv"
echo -e "READ_NUM\tTRUE_CHR\tTRUE_START\tTRUE_END\tTRUE_MUT\tMAP_CHR\tMAP_POS\tMAPQ\tCIGAR\tOFFSET" > "$OUTPUT_TSV"
samtools view -q "$MAPQ_THRESHOLD" "$OUT_BAM" | awk -F'\t' '
{
    # 1. Parse wgsim header
    n = split($1, h, "_");
    true_chr = h[1];
    true_start = h[2];
    true_end = h[3];
    # 2. Identify R1 vs R2 using the FLAG ($2)
    # If (Flag / 64) is odd, it is Read 1. If (Flag / 128) is odd, it is Read 2.
    if (int($2/64) % 2 == 1) {
        read_num = "R1";
        true_mut = h[4];
        expected_pos = true_start;
    } else {
        read_num = "R2";
        true_mut = h[5];
        # R2 starts at: Fragment End - ReadLength + 1
        expected_pos = true_end - 150 + 1;
    }
    # 3. Calculate Offset
    # Mapping position ($4) minus where wgsim said it should be
    offset = $4 - expected_pos;
    # 4. Output results
    print read_num "\t" true_chr "\t" true_start "\t" true_end "\t" true_mut "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\t" offset
}' >> "$OUTPUT_TSV"
echo "Pipeline complete for Task $SLURM_ARRAY_TASK_ID."
