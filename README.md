# RefGenPrelim
Documented code repository in response to Prelimenary Exam for Amelia Loeb
Given by Dr. Amanda Hulse-Kemp
May 2026

The goal: investigate differences of reference genomes across ploidy levels for sweetpotato
The process:
- 1: download reference genomes 
reference genomes: I. trifida (NSP306) & I.batatas c.v. Beauregard v4 [I.batatas c.v. Taizong 6 included but not discussed]
- 2: record MD5SUM for reference genomes
- 3: Sample reads from reference genomes
	- simulated illumina reads
	- simulated PacBio wgs reads
- 4: Align reads back to their reference genomes

The scripts & code:

- 1.Download reference genomes
  - **downloadrefgen.sh**
  - Record md5 sum of utilized genomic references.
  - **indexreference.sh**
2. Simulate data of known genomic location for each reference genotype for the following:
	- a. Illumina short-read WGS data (to be equivalent to your DArT reads, 81bp I think)
		- **simiss.sh** or **simiss.sh** to simulate 200 million HiSeq reads per genome
			- 200 million was chosen to provide coverage for genome size
			- HiSeq simulation chosen based on https://pmc.ncbi.nlm.nih.gov/articles/PMC5407923/
			- did not work well because sampling location was not correctly saved in header
		- **simwg.sh** to simulate illumina 81bp reads, other lengths tested, including paired-ends 
	- b. Pacbio long-read WGS data
		- **simpb3.sh** to simulate pacbio long reads. Did not work well because sampling location was unable to be identified
	- c. Optional – GBS and/or your actual DArT positond
		- aligned unique reference and alternate consensus sequences from population that was genotyped with DaRT panel
		- **simgbs.sh**
3. Align simulated data back to the following genome assemblies
	- a. Short Reads
		- **iss_qcpre.sh** optional quality control check
		- **trim_iss.sh** optional trimming of reads
		- **aligniss.sh** to align InSilicoSeq reads using bwa-me
		- **tsviss.sh** extract mapping coordinates from bam file
		- **master_wgsim_pipeline.sh** total script to align and extract mapping coordinates from simulated short reads produced by **simwg.sh**
	- b. long reads
		- **alignpb.sh** align pacbio reads simulated from simpb3
		- **tsvpb.sh** extract mapping coordinates from bam files of long reads
4. Visualize the proportion of reads aligning to the correct spot across the genomes
5. Additional Scripts [mostly unused]
	- **mummer.sh** tried aligning long reads to reference genomes, issue with awk commands for reads, did not use
	- **qualimapat.sh** tried to examine the quality of the mapping for short reads, did not prove insightful since coverage was not a factor
	- *qcgenome.sh** script to compare the quality of reference genomes using assembly stats, busco & quash. Ran, but did not include data due to time

RefGenPrelim/
├── data/                       # Raw and processed genomic data (excluded from repo)
│   ├── bams/                   # Alignment files
│   ├── gbs_sim/                # GBS simulation outputs
│   ├── genomes/                # Reference FASTA files & MD5 checksums
│   ├── iss/                    # InSilicoSeq intermediate files
│   ├── pbsim3/                 # PacBio simulation data
│   ├── qualimap/               # Quality control reports
│   ├── stats/                  # Summary statistics
│   ├── trimmed_reads/          # Post-QC sequencing reads
│   └── wgsim/                  # wgsim simulation outputs
├── scripts/                    # Pipeline automation and analysis scripts
│   ├── aligniss.sh             # Alignment for InSilicoSeq reads
│   ├── alignpb.sh              # Alignment for PacBio reads
│   ├── downloadrefgen.sh       # Reference genome acquisition
│   ├── indexrefgenome.sh       # BWA/Samtools indexing
│   ├── iss_qcpre.sh            # Pre-alignment QC for ISS
│   ├── master_wgsim_pipeline.sh# Main workflow wrapper
│   ├── mummer.sh               # Comparative genomics analysis
│   ├── qcgenome.sh             # Genome assembly QC
│   ├── qualimapat.sh           # Automated Qualimap reports
│   ├── simgbs.sh               # GBS data simulation
│   ├── simiss.sh               # InSilicoSeq simulation
│   ├── simisspars.sh           # Parameter parsing for ISS
│   ├── simpbs3.sh              # PBSIM3 simulation
│   ├── trim_iss.sh             # Read trimming/adapter removal
│   ├── tsviss.sh               # Data conversion for ISS
│   └── tsvpb.sh                # Data conversion for PacBio
├── results/                    # Final analysis outputs and figures
├── logs/                       # Standard out/error logs from pipeline runs
├── AssemblyStats.yml           # Configuration for assembly metrics
├── README.md                   # Project documentation
└── RefGenPrelimEnv.yml         # Conda/Mamba environment definition

