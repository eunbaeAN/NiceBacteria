#!/usr/bin/env nextflow

process MLST {

    	tag "${meta.id}, ${meta.runtype}"

	errorStrategy 'ignore'

	// cpus 36 
    	publishDir "results/${meta.id}/${meta.runtype}", /*mode: params.publish_dir_mode, overwrite: params.force,*/
        mode: 'copy',
        saveAs: { filename -> "$filename" }

	input: 
	tuple val(meta), path(assembly_result)

	output:
	tuple val(meta), path("${meta.id}_MLST_typing/${meta.id}_mlst_results.csv")
	
	when:
	meta.runtype == "hybrid" || meta.runtype == "long-reads" || meta.runtype == "short-reads"

	script:
	"""
	if [[ ! -f "${meta.id}_assembly.fasta" ]]; then
			cp assembly.fasta ${meta.id}_assembly.fasta
	fi
	mkdir -p ${meta.id}_MLST_typing
	mlst --csv ${meta.id}_assembly.fasta > ${meta.id}_MLST_typing/${meta.id}_mlst_results.csv

	"""
}

