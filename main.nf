#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

runtype = "multiples_samples"



params.empty_long_reads = "${baseDir}/Data/EMPTY_LONG_READS"
params.empty_r1 = "${baseDir}/Data/EMPTY_R1"
params.empty_r2 = "${baseDir}/Data/EMPTY_R2"
/*
[[id:FCH7LN7CCX2_L7_wHAXPI123862-101, runtype:hybrid, genome_size:1000], [/home/ean/Samples_data/workflow/Samples/FCH7LN7CCX2_L7_wHAXPI123862-101_1_paired.fq.gz], [/home/ean/Samples_data/workflow/Samples/FCH7LN7CCX2_L7_wHAXPI123862-101_2_paired.fq.gz], /home/ean/Samples_data/workflow/Samples/WH2002000017.reads.fastq.gz]
[[id:FCH7LN7CCX2_L7_wHAXPI123862-101, runtype:paired-end, genome_size:1000], [/home/ean/Samples_data/workflow/Samples/FCH7LN7CCX2_L7_wHAXPI123862-101_1_paired.fq.gz], [/home/ean/Samples_data/workflow/Samples/FCH7LN7CCX2_L7_wHAXPI123862-101_2_paired.fq.gz], [null]]
[[id:FCH7LN7CCX2_L7_wHAXPI123862-101, runtype:ont, genome_size:1000], [/home/ean/Samples_data/workflow/Samples/WH2002000017.reads.fastq.gz], [null], [null]]
[[id:FCH7LN7CCX2_L7_wHAXPI123870-101, runtype:hybrid, genome_size:1000], [/home/ean/Samples_data/workflow/Samples/FCH7LN7CCX2_L7_wHAXPI123870-101_1_paired.fq.gz], [/home/ean/Samples_data/workflow/Samples/FCH7LN7CCX2_L7_wHAXPI123870-101_2_paired.fq.gz], /home/ean/Samples_data/workflow/Samples/WH2002000018.reads.fastq.gz]
[[id:FCH7LN7CCX2_L7_wHAXPI123870-101, runtype:paired-end, genome_size:1000], [/home/ean/Samples_data/workflow/Samples/FCH7LN7CCX2_L7_wHAXPI123870-101_1_paired.fq.gz], [/home/ean/Samples_data/workflow/Samples/FCH7LN7CCX2_L7_wHAXPI123870-101_2_paired.fq.gz], [null]]
[[id:FCH7LN7CCX2_L7_wHAXPI123870-101, runtype:ont, genome_size:1000], [/home/ean/Samples_data/workflow/Samples/WH2002000018.reads.fastq.gz], [null], [null]]
*/


/*
========================================================================================
    IMPORT LOCAL MODULES/SUBWORKFLOWS
========================================================================================
*/

include { TEST_WORKFLOW } from './modules/main_workflow'


/*
========================================================================================
    RUN MAIN WORKFLOW
========================================================================================
*/

workflow { 
	TEST_WORKFLOW ()
}


