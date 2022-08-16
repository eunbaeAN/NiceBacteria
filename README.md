# NiceBacteria
NiceBacteria is a pipeline for bacterial genome analysis. This pipeline is developed to target _Bacillus cereus_ genomes, however, it can be used for other bacterial species. 

# Overview
![alt text](https://github.com/eunbaeAN/IRCAN_pipeline/blob/main/overview.png?raw=true)

# Description 
The main purpose of this pipeline is to automate the processing of high-throughput sequencing (HTS) data for whole bacterial genome analysis. It has been built using Nextflow to manage the workflow. It manages the parallel execution of several tasks and creates REPORT.html, a single document that includes useful metrics about a workflow execution. This pipeline sends a mail once the execution is completed. This email includes the information about a workflow execution and the execution report (REPORT.html).


The overview above summarises the different processes and component bioinformatics tools. It takes FASTQ files provided locally as inputs and processes them automatically with the bioinformatics tools and creates the output files.

This pipeline can be split into three main components: pre-processing, processing, and post-processing. 
The pre-processing step contains quality control and trimming steps.
The processing step includes de *novo* assembly and the evaluation of genome assembly. 
The post-processing step consists of annotation, taxonomic classification, detection of resistance and virulence genes, multi-locus sequence typing (MLST) for characterization of the bacterial genome, and pan-genome analysis and phylogenetic analysis which provide comparative genomic analysis.

# Processes


# Tutorial
### Running pipeline
 ``` 
 nextflow run /path/to/main.nf --samples "/path/to/my-samples.csv" -ansi-log false
 ```
NiceBacteria requires main.nf, nexflow.config, the files in modules, lib and workflow folders, and a samplesheet file (csv or txt file) to run. 
The nemerous incorportaed bioinformatics tools leaded the dependencies. However, the containerization of the dependencies is not done yet. Instead, the tools you need for this pipeline are already installed on the server, professorX


Please do not forget to put the parameter '--samples' to provide the information of your samples. 

### Create csv file "my-samples.csv" (tab delimited file)

This pipeline requires a csv file (or text file) describing the input samples. See an example file "my-samples.csv". 
This file contains 7 columns. The header of these columns should be : sample, runtype, r1, r2, long_reads, assembled_fasta, email. ***Attention, these columns must be delimited by tabs. And, it's case-sensitive, so please make sure that the header is written in lowercase.*** See below to further information. And please fill blank cell with "-" or "NA" so that there is no empty cell in the rows that you field.


|sample|runtype| r1 | r2 | long_reads | assembled_fasta | email |
|-------|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|
|Sample_1|short-reads|path/to/short_reads_R1.fq.gz|path/to/short_reads_R2.fq.gz|-|-|email@addresse.com|
|Sample_2|long-reads|-|-|path/to/long_reads_file.fq.gz|-|-|   
|Sample_3|hybrid|path/to/short_reads_R1.fq.gz|path/to/short_reads_R2.fq.gz|path/to/long_reads_file.fq.gz|-|-|   
|Sample_4|assembled_fasta|-|-|-|path/to/FASTA.fa|-|   

 ``` 
 =================================================================================================================================================================== 
 
- sample : Sample name. Remember that this name would be used when the output file is created. 
- runtype : You can choose one among four runtypes depending on your data sets. 
           "short-reads, long-reads, hybrid or assembled_fasta"
           The "runtype" column will eventually choose the type of input files and an assembler. 
           (Attention, it's case-sensitive. You should write this word in the exactly same way.)
           short-reads : This takes only short paired-end reads as inputs. It will use the SPAdes as an assembler.
           long-reads : When you have only long single-end reads. This uses the Flye as an assembler.
           hybrid : When you have both short paired-end reads and long single-end reads. Unicycler is integrated for hybrid assembler. 
           assembled_fasta : When you have a FASTA file which has been already assembled. This skips the assembly and starts from the evalutation of genome assembly. 
- r1 : short paired-end reads, forward for r1. 
- r2 : short paired-end reads, reverse for r2. 
- long_reads : long single-end reads. 
- assembled_fasta : The FASTA file which is already assembled. 
 - email : The email address that you want to be informed when the execution of the pipeline is completed. 
The complete location of each input file (FASTQs) is needed for r1, r2, long_reads and assembled_fasta.

===================================================================================================================================================================
 ``` 


# Inputs/outputs 
This pipeline takes FASTQs as inputs: short read sequencing data obtained from Illumina technology or/and long read sequencing data obtained from Oxford Nanopore Technology or Pacific Biosciences technology.

### Structure of the output folders
The pipeline will create several folders corresponding to the different processes of the pipeline. These folders will be saved in the output directory called "results". This directory will be created in the location where you run this pipeline.

**Example of output folders (short-reads, long-reads, hybrid)**:
```
results
├── <sample_name>
│   ├── short-reads | long-reads | hybrid
│   │   ├── <sample_name>_Raw_reads
│   │   │   ├── Illumina_Raw_reads
│   │   │   ├── Nanopore_Raw_reads
│   │   │   ├── ...
│   │   ├── <sample_name>_Cleaned_reads 
│   │   │   │   ├── <sample_name>_Short-Reads_Cleaned | <sample_name>_Long_Reads_cleaned
│   │   │   │   ├── ...
│   │   ├── <sample_name>_Assemblies
│   │   │   ├── <sample_name>_Short_Reads_Assembly | <sample_name>_Long_Reads_Assembly | <sample_name>_Hybrid_Reads_Assembly 
│   │   │   │   ├── 
│   │   │   │   ├── ...
│   │   |   ├── <sample_name>_Short_Reads_Assembly_Report | <sample_name>_Long_Reads_Assembly_Report | <sample_name>_Hybrid_Reads_Assembly_Report
│   │   │   │   ├── basic_stats
│   │   │   │   ├── icarus_viewers
│   │   │   │   ├── icarus.html
│   │   │   │   ├── quast.log
│   │   │   │   ├── report.html
│   │   │   │   ├── report.pdf
│   │   │   │   ├── ...
│   │   ├── <sample_name>_Annotation
│   │   │   ├── ddbj
│   │   │   ├── genbank
│   │   │   ├── application.log
│   │   │   ├── genome.gff (GFF3)
│   │   │   ├── genome.gbk (genbank)
│   │   │   ├── genome.ffn (gene sequences)
│   │   │   ├── genome.faa (protein sequences)
│   │   │   ├── statistics.txt
│   │   │   ├── ...
│   │   ├── <sample_name>_16S_analysis
│   │   │   ├── results_blast
│   │   │   ├── <sample_name>_16S_rRNA.fasta
│   │   │   ├── <sample_name>_rrna.fasta
│   │   │   ├── <sample_name>_rra.gff
│   │   │   ├── ...
│   │   ├── <sample_name>_MLST_typing
│   │   │   ├── <sample_name>_mlst_results.csv
│   │   │   ├── ...
│   │   ├── <sample_name>_Resistance_Virulence_genes
│   │   │   ├── <sample_name>_resistance_genes.xls
│   │   │   ├── <sample_name>_virulence_genes.xls
│   │   │   ├── ...
│   │   ├── <sample_name>_Ortho_ANI_analysis
│   │   │   ├── <sample_name>_Ortho_ANI_analysis.out
│   │   │   ├── <sample_name>_Reference_genomes_list.txt
│   │   │   ├── ...
│   │   ├── <sample_name>_Pan_genome_analysis
│   │   │   ├── genome_presence_absence.csv
│   │   │   ├── accessory.tab
│   │   │   ├── core_accessory.tab
│   │   │   ├── number_of_conserved_genes.Rtab
│   │   │   ├── number_of_genes_in_pan_genome.Rtab
│   │   │   ├── summary_statistics.txt
│   │   │   ├── pan_genome_frequence.png
│   │   │   ├── pan_genome_matrix.png
│   │   │   ├── pan_genome_pie.png
│   │   │   ├── ...
│   │   ├──<sample_name>_Phylogenetic_tree
│   │   │   ├── <sample_name>_multiple_alignments_by_muscle.afa
│   │   │   ├── <sample_name>_multiple_alignments_by_muscle.afa.treefile
│   │   │   ├── <sample_name>_phylotree.png
│   │   │   ├── ...
```

**Example of output folders (assembled)**:
```
results
│   ├── assembled
│   │   ├── <sample_name>_Assembly_Report
│   │   │   │   ├── basic_stats
│   │   │   │   ├── icarus_viewers
│   │   │   │   ├── icarus.html
│   │   │   │   ├── quast.log
│   │   │   │   ├── report.html
│   │   │   │   ├── report.pdf
│   │   │   │   ├── ...
│   │   ├── <sample_name>_Annotation
│   │   │   ├── ddbj
│   │   │   ├── genbank
│   │   │   ├── application.log
│   │   │   ├── genome.gff (GFF3)
│   │   │   ├── genome.gbk (genbank)
│   │   │   ├── genome.ffn (gene sequences)
│   │   │   ├── genome.faa (protein sequences)
│   │   │   ├── statistics.txt
│   │   │   ├── ...
│   │   ├── <sample_name>_16S_analysis
│   │   │   ├── results_blast
│   │   │   ├── <sample_name>_16S_rRNA.fasta
│   │   │   ├── <sample_name>_rrna.fasta
│   │   │   ├── <sample_name>_rra.gff
│   │   │   ├── ...
│   │   ├── <sample_name>_MLST_typing
│   │   │   ├── <sample_name>_mlst_results.csv
│   │   │   ├── ...
│   │   ├── <sample_name>_Resistance_Virulence_genes
│   │   │   ├── <sample_name>_resistance_genes.xls
│   │   │   ├── <sample_name>_virulence_genes.xls
│   │   │   ├── ...
│   │   ├── <sample_name>_Ortho_ANI_analysis
│   │   │   ├── <sample_name>_Ortho_ANI_analysis.out
│   │   │   ├── <sample_name>_Reference_genomes_list.txt
│   │   │   ├── ...
│   │   ├── <sample_name>_Pan_genome_analysis
│   │   │   ├── genome_presence_absence.csv
│   │   │   ├── accessory.tab
│   │   │   ├── core_accessory.tab
│   │   │   ├── number_of_conserved_genes.Rtab
│   │   │   ├── number_of_genes_in_pan_genome.Rtab
│   │   │   ├── summary_statistics.txt
│   │   │   ├── pan_genome_frequence.png
│   │   │   ├── pan_genome_matrix.png
│   │   │   ├── pan_genome_pie.png
│   │   │   ├── ...
│   │   ├──<sample_name>_Phylogenetic_tree
│   │   │   ├── <sample_name>_multiple_alignments_by_muscle.afa
│   │   │   ├── <sample_name>_multiple_alignments_by_muscle.afa.treefile
│   │   │   ├── <sample_name>_phylotree.png
│   │   │   ├── ...
```
# Errors 
Failed to invoke `workflow.onComplete` event handler

