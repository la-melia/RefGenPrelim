# RefGenPrelim
Documented code repository in response to Prelimenary Exam for Amelia Loeb
Given by Dr. Amanda Hulse-Kemp
May 2026

The goal: investigate differences of reference genomes across ploidy levels for sweetpotato

Set up a documented code repository to investigate the differences when operating across ploidy levels

for sweet potato, thinking in terms of how this can impact your downstream decisions. You can use the

diploid reference you’ve mostly been working with to date Ipomoea trifida (NSP306) and the newest

hexaploid reference v4 of I. batatas Beauregard (assuming that’s the most relevant to your materials, if

you disagree use the other polyploid closest and explain why) to investigate impacts of read

mapping/parameters and input data types across different types of sequencing data and different

reference genome types (diploid vs hexaploid).

1. Record md5 sum of utilized genomic references.

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






