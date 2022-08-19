#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

params.empty_long_reads = "${baseDir}/data/EMPTY_LONG_READS"
params.empty_r1 = "${baseDir}/data/EMPTY_R1"
params.empty_r2 = "${baseDir}/data/EMPTY_R2"



/*
========================================================================================
    IMPORT LOCAL MODULES/SUBWORKFLOWS
========================================================================================
*/

include { TEST_WORKFLOW } from './workflow/main_workflow'


/*
========================================================================================
    RUN MAIN WORKFLOW
========================================================================================
*/

workflow { 
    TEST_WORKFLOW ()
}




