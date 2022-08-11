# NiceBacteria
NiceBacteria is a pipeline for bacterial genome analysis. This pipeline is developed to target _Bacillus cereus_ genomes, however, it can be used for other bacterial species. 

# OVERVIEW
![alt text](https://github.com/eunbaeAN/IRCAN_pipeline/blob/main/overview.png?raw=true)

# Description 
The main purpose of this pipeline is to automate the processing of high-throughput sequencing (HTS) data for whole bacterial genome analysis. It has been built using Nextflow to manage the workflow. It manages the parallel execution of sereral tasks and creates REPORT.html, a single document includes useful metrics about a workflow execution. This pipeline sends a mail once the execution is complete. This email includes the information about a workflow execution and the execution report (REPORT.html).


The overview above summarises the different processes and component bioinformatics tools incorporated into this pipeline. This pipeline can be split into three main components : pre-processing, processing, and post processing. 
The pre-processing step contains quality controls and trimming step.
The processing step includes de *novo* assembly and the evaluation of assembly. 
The post-processing step consists of annotation, taxonomic classification, the detection of resistance and virulence genes, multi-locus sequence typing (MLST) for characterization of bacterial genome, and pan-genome analysis and phylogenetic analysis which provide comparative genomic analysis.



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

# Inputs/outputs 

This pipeline takes FASTQs as input the whole bacterial genome analysis using short read sequencing data obtained from Illumina technology or/and long read sequencing data obtained from Oxford Nanopore Technology or Pacific Biosciences technology. 
