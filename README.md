# NiceBacteria
NiceBacteria is a pipeline for bacterial genome analysis. This pipeline is developed to target _Bacillus cereus_ genomes, however, it can be used for other bacterial species. 

# OVERVIEW
![alt text](https://github.com/eunbaeAN/IRCAN_pipeline/blob/main/overview.png?raw=true)

# Description 
The main purpose of this pipeline is to automate the processing of high-throughput sequencing (HTS) data for whole bacterial genome analysis. It has been built using Nextflow to manage the workflow. It manages the parallel execution of several tasks and creates REPORT.html, a single document includes useful metrics about a workflow execution. This pipeline sends a mail once the execution is completed. This email includes the information about a workflow execution and the execution report (REPORT.html).


The overview above summarises the different processes and component open-source bioinformatics tools incorporated into this pipeline. It takes FASTQ files provided locally as inputs and processes them automatically with the bioinformatics tools and creates the output files locally.

This pipeline can be split into three main components : pre-processing, processing, and post processing. 
The pre-processing step contains quality controls and trimming step.
The processing step includes de *novo* assembly and the evaluation of genome assembly. 
The post-processing step consists of annotation, taxonomic classification, the detection of resistance and virulence genes, multi-locus sequence typing (MLST) for characterization of bacterial genome, and pan-genome analysis and phylogenetic analysis which provide comparative genomic analysis.


# Tutorial
### Running pipeline
 ``` 
 nextflow run /path/to/main.nf --samples "/path/to/my-samples.csv" -ansi-log false
 ```
Please do not forget to put the parameter '--samples' to provide the information of your samples. 

### Create csv file "my-samples.csv" (tab delimited file)

This pipeline requires a csv file (or text file) describing the input samples. See an example file "my-samples.csv". 
This file contains 7 columns : sample, runtype, r1, r2, long_reads, assembled_fasta, email. ***Attention, these columns need to be tab delimited. And, it's case-sensitive, please do not confuse uppercase and lowercase letters***

 ``` 
- sample : Sample name. Remember that this name would be used when the output file is created. 
- runtype : You can choose one among four types of runtypes depending on your data sets. 
            "short-reads or long-reads or hybrid or assembled_fasta" (Attnetion, it's case-sensitive.)  
- r1 : short paired-end reads, forward for r1. 
- r2 : short paired-end reads, reverse for r2. 
- long_reads : long single-end reads. 
- assembled_fasta : The FASTA file which is already assembled. 
 - email : The email address that you want to be informed when the execution of the pipeline is completed. 
**The complete location of each input file (FASTQs) is nedded for r1, r2, long_reads and assembled_fasta.**
 ``` 


# Inputs/outputs 

This pipeline takes FASTQs as input the whole bacterial genome analysis using short read sequencing data obtained from Illumina technology or/and long read sequencing data obtained from Oxford Nanopore Technology or Pacific Biosciences technology. 
