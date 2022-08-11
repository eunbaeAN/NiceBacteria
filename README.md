# NiceBacteria
NiceBacteria is a pipeline for bacterial genome analysis. This pipeline is developped to target _Bacillus cereus_ genomes, however, it can be used for other bacterial species. 

# OVERVIEW
![alt text](https://github.com/eunbaeAN/IRCAN_pipeline/blob/main/overview.png?raw=true)

# Description 
This pipeline is developped to automate the whole bacterial genome analysis. It has been built using Nextflow to manage the workflow. It manages the parallel execution of sereral tasks and creates REPORT.html, a single document includes useful metrics about a workflow execution. This pipeline sends a mail once the execution is complete. This email includes the information about a workflow execution and the execution report (REPORT.html).


This pipeline is developped to automate the whole bacterial genome analysis using short read or/and long read sequencing data obtained from Illumina technology (short reads) or/and Oxford Nanopore Technology (long reads) or Pacific Biosciences technology (long reads).
The overview above summarises the different process and component tools of this pipeline. The process can be split into three parts : pre-processing, processing, and post processing. 

# Tutorial
 **Running pipeline**
 ``` 
 nextflow run main.nf --samples "my-samples.csv" -ansi-log false
 ```
Please do not forget to put the parameter '--samples' to provide the information of your samples. 

**Create csv file "my-samples.csv"**
This pipeline requires a csv file (or text file) describing the input samples. This file contains 7 columns :
sample, runtype, r1, r2, long_reads, assembled_fasta, email. 
*Attention, these columns need to be tab delimited.*
sample names, location to assicociated input files (FASTQs), email adresse. 
* 
*  

