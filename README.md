# RefGenPrelim
Documented code repository in response to Prelimenary Exam for Amelia Loeb
Given by Dr. Amanda Hulse-Kemp
May 2026

The goal: investigate differences of reference genomes across ploidy levels for sweetpotato
The process:
1: download reference genomes 
reference genomes: I. trifida (NSP306) & I.batatas c.v. Beauregard v4 [I.batatas c.v. Taizong 6 included but not discussed]
2: record MD5SUM for reference genomes
3: Sample reads from reference genomes
- simulated illumina reads
- simulated PacBio wgs reads
4: Align reads back to their reference genomes

The scripts & code:

1.Download reference genomes
 Record md5 sum of utilized genomic references.
 downloaded Trifida v3, Beauregard v4 and Tiazgon 6 reference genomes using downloadrefgen.sh
unziped files and recorded md5 sum
  981  gunzip Beauregard_v4.asm.fa >> RefGenmd5sum
  982  gunzip NSP306_trifida_chr_v3.fa.zip
  983  gunzip -S .zip NSP306_trifida_chr_v3.fa.zip
  986  nano RefGenmd5sum
  987  md5sum Beauregard_v4.asm.fa >> RefGenmd5sum
  989  md5sum NSP306_trifida_chr_v3.fa >> RefGenmd5sum 
  990  md5sum ipoBat4.fa >> RefGenmd5sum 
2. Simulate data of known genomic location for each reference genotype for the following:

a. Illumina short-read WGS data (to be equivalent to your DArT reads, 81bp I think)

b. Pacbio long-read WGS data

c. Optional – GBS and/or your actual DArT positions - I don’t believe that GBS short-read

data is currently being used in the program but if it is you can run that as well here –

identify which enzymes they’re running and substitute: ex. PstI and MspI double digest



3. Align simulated data back to the following genome assemblies,

a. Itself - respective reference genomes

b. The other reference genome

4. Visualize the proportion of reads aligning to the correct spot across the genomes. (Known

position vs mapped position for 2a).

5. Visualize relationship between the genomes with true position (Y) and the mapped position of

the reads on the other genome (X).

Interpret your findings (and any struggles for being able to complete analysis), particularly in terms of

thinking related to your project, and communicate your suggestions as a short presentation to

potentially occur at the beginning of the oral prelim session.

Consider how to include simulated variants of various types (SNPs, InDels, etc), in your simulation

design, how to deal with multiple copies of each homologous chromosome (e.g., in the hexaploid

reference), and whether a pan-genome approach may improve your results.






