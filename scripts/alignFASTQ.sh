#!/bin/bash
#SBATCH --job-name=alignreads        # Job name
#SBATCH --output=logs/align%A_%a_out           # Standard output file
#SBATCH --error=logs/align%A_%a_err             # Standard error filee
#SBATCH --nodes=1                     # Number of nodes
#SBATCH --ntasks-per-node=1           # Number of tasks per node
#SBATCH --cpus-per-task=8             # Number of CPU cores per task
#SBATCH --mem=8G
#SBATCH --time=1:00:00                # Maximum runtime (D-HH:MM:SS)s
#SBATCH --array=0-358%20           # run 359 jobs, 20 at a time, total number of samples minus 1

#memory allocation: BWA-MEM needs to load reference ~500Mb genome, 4-5Gb RAM + buffer room
#could increase the number of jobs to %50 or 100 because only taking a few minutes
#CPU/realtime from err files gives the number of threads

# list of FASTQ files
# make in folder with ls -d ../ospfastq/*FASTQ.gz > ospfastqlist.txt
#get number of lines to give to ode
#each fastq file corresponds to an individual
FASTQLIST="ospfastqlist.txt"

#reference 
REFGEN="../trifidagenome/NSP306_trifida_chr_v3.fa"

#get the line number of the sample by the array job+1
# must add 1 because sed -n starts at 1 not 0
# arithmatic is bash needs $(( ))
SAMPLELINE=$((SLURM_ARRAY_TASK_ID + 1))

#get the FASTQ name to process by the line 
#Use double quotes in sed to allow the variable to expand
FASTQ=$(sed -n "${SAMPLELINE}p" "$FASTQLIST")

# 4. Fix: Clean up the sample name and ID
# basename removes the path; then we strip the extension
FULLNAME=$(basename "$FASTQ")
ID="${FULLNAME%%.*}"  # This turns 3535400.FASTQ.gz into 3535400

echo "Task ID $SLURM_ARRAY_TASK_ID is processing sample line $SAMPLELINE: $ID"

# 5. Create log directory
mkdir -p logs

# create directory for bams

#load modules
module load samtools
module load bwa

# 6. Run the alignment pipe
# Changed SM to $ID to keep headers clean
bwa mem -t $SLURM_CPUS_PER_TASK -R "@RG\tID:$ID\tSM:$ID\tPL:ILLUMINA" "$REFGEN" "$FASTQ" | \
#align $FASTQ tp $REFGEN using bwa mem algorithm and -t threads with read group heder -R
#columns seperated by \t tabls with tID, tSM and tPL necessary
#passes output to view -S for compatibility with prev. versions -b for output bam
samtools view -Sb - | \
#passes bam output to sort by left most coordinates with -o outpt
samtools sort -o "bams/${ID}_sorted.bam"

# 7. Index the resulting BAM
samtools index "bams/${ID}_sorted.bam"
## could make faster by giving BAM more memory
#samtools sort -@ 4 -m 1G -o "${ID}_sorted.bam"

echo "Finished processing $ID"
