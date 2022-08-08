# NiceBacteria
NiceBacteria is a pipeline for bacterial genome analysis. This pipeline targets _Bacillus cereus_ genomes. However, it can be used for other bacterial species. 

# OVERVIEW
![alt text](https://github.com/eunbaeAN/IRCAN_pipeline/blob/main/overview.png?raw=true)

# Description 
This pipeline is developped to automate the whole bacterial genome analysis. It has been built using Nextflow to manage the workflow. It manages the parallel execution of tasks and creates REPORT.html allowing users to 


This pipeline is developped to automate the whole bacterial genome analysis using sequencing data obtained from Illumina technology (short reads) or/and Oxford Nanopore Technology or Pacific Biosciences technology (long reads).
The overview above summarises the different process and component tools of this pipeline.
# Tutorial
 **Running pipeline**
 ``` 
 nextflow run main.nf --samples "my-samples.csv" -ansi-log false
 ```
 **Create csv file "my-samples.csv"**

This pipeline requires a csv file (or text file) describing the input samples. This file contains 7 columns :
sample, runtype, r1, r2, long_reads, assembled_fasta, email. 
*Attention, these columns need to be tab delimited.*
sample names, location to assicociated input files (FASTQs), email adresse. 
* 
*  

