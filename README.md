# Nice_Bacteria
IRCAN_pipeline is a pipeline for bacterial genome analysis. This pipeline targets _Bacillus cereus_ genomes. However, it can be used for other bacterial species. 

# OVERVIEW of IRCAN_pipeline
![alt text](https://github.com/eunbaeAN/IRCAN_pipeline/blob/main/overview.png?raw=true)

# Description 
This pipeline has been built using Nextflow to manage the workflow. 
This pipeline is developped to automate the whole bacterial genome analysis using sequencing data obtained from Illumina technology (short reads) or/and Oxford Nanopore Technology or Pacific Biosciences technology (long reads).

# Tutorial
* Running pipeline
 ``` 
 nextflow run main.nf --samples "my-samples.csv" -ansi-log false
 ```
* 

