#!/usr/bin/env nextflow

process ASSEMBLED_BARRNAP {

    	tag "${meta.id}, ${meta.runtype}"

	errorStrategy 'ignore'

	// cpus 36 
   	publishDir "results/${meta.id}/${meta.runtype}", /*mode: params.publish_dir_mode, overwrite: params.force,*/
        mode: 'copy',
        saveAs: { filename -> "$filename" }

	input: 
	tuple val(meta), path(assembly_results_fasta)

	output:
	tuple val(meta), path("${meta.id}_16S_analysis/*"), emit: assembled_barrnap_results
	tuple val(meta), path("${meta.id}_16S_analysis/results_blast/${meta.id}_blast.xls"), emit: assembled_barrnap_xls_results
	tuple val(meta), path("${meta.id}_16S_analysis/${meta.id}_16S_rRNA.fasta"), emit: assembled_barrnap_rRNA_query
	
	when:
	meta.runtype == "assembled"

	script:
	"""
	mkdir -p ${meta.id}_16S_analysis
	#-p used on mkdir makes it create extra directory if they do not exsit yet
	# -- make sure that the passed name for the new directory is not interpreted as an option to mkdir 

	if [[ ! -f "${meta.id}_assembly.fasta" ]]; then
			cp assembly.fasta ${meta.id}_assembly.fasta
	fi
	
	barrnap -o ${meta.id}_16S_analysis/${meta.id}_rrna.fasta < ${meta.id}_assembly.fasta > ${meta.id}_16S_analysis/${meta.id}_rrna.gff 
	head -n 2 ${meta.id}_16S_analysis/${meta.id}_rrna.fasta > ${meta.id}_16S_analysis/${meta.id}_16S_rRNA.fasta

	#!!!!!!!!!!!!!!ATTNETION ! I take 16S in the first line of this file at the moment. !!!!!!!!!!!!!!!!!!!!!!!! 
	mkdir ${meta.id}_16S_analysis/results_blast
	blastn -query ${meta.id}_16S_analysis/${meta.id}_16S_rRNA.fasta -db /scratch/db/16S_ribosomal_RNA/blastDB/16S_ribosomal_RNA -outfmt "7 qseqid sseqid pident length mismatch qstart qend sstart send evalue stitle" -out ${meta.id}_16S_analysis/results_blast/${meta.id}_blast.xls -evalue 0.0001
	"""
}
