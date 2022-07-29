#!/usr/bin/env nextflow

process ABRICATE {

    tag "${meta.id}, ${meta.runtype}"

	errorStrategy 'ignore'

	// cpus 36 
    	publishDir "results/${meta.id}/${meta.runtype}", /*mode: params.publish_dir_mode, overwrite: params.force,*/
        mode: 'copy',
        saveAs: { filename -> "$filename" }

	input: 
	tuple val(meta), path(assembly_results)

	output:
	tuple val(meta), path("${meta.id}_Resistance_Virulence_genes"), emit: abricate_results
	tuple val(meta), path("${meta.id}_Resistance_Virulence_genes/${meta.id}_virulence_genes.xls") 
	tuple val(meta), path("${meta.id}_Resistance_Virulence_genes/${meta.id}_resistance_genes.xls")
	
	when:
	meta.runtype == "hybrid" || meta.runtype == "long-reads" || meta.runtype == "short-reads"

	script:
	"""

	if [[ ! -f "${meta.id}_assembly.fasta" ]]; then
			cp assembly.fasta ${meta.id}_assembly.fasta
	fi

	# If there is not Sample_1_assembly.fasta file, this script will create a copy of "assembly.fasta" called "Sample_1_assembly.fasta"

	abricate --db resfinder --minid 70 --mincov 70 ${meta.id}_assembly.fasta > ${meta.id}_resistance_genes.xls 
	abricate --db vfdb --minid 70 --mincov 70 ${meta.id}_assembly.fasta > ${meta.id}_virulence_genes.xls 

	#popd

	mkdir -p ${meta.id}_Resistance_Virulence_genes
	
	cat ${meta.id}_virulence_genes.xls | cut -f1-4,6,9-14 > ${meta.id}_Resistance_Virulence_genes/${meta.id}_virulence_genes.xls
	cat ${meta.id}_resistance_genes.xls | cut -f1-4,6,9-14 > ${meta.id}_Resistance_Virulence_genes/${meta.id}_resistance_genes.xls

	"""
}

