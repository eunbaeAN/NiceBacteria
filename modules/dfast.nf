#!/usr/bin/env nextflow

process DFAST {

    	tag "${meta.id}, ${meta.runtype}"

	errorStrategy 'ignore'

	// cpus 36 
    	publishDir "results/${meta.id}/${meta.runtype}", /*mode: params.publish_dir_mode, overwrite: params.force,*/
        mode: 'copy',
        saveAs: { filename -> "$filename" }

	input: 
	tuple val(meta), path(assembly_results_fasta)

	output:
	tuple val(meta), path("${meta.id}_Annotation/*"), emit: dfast_results
	tuple val(meta), path("${meta.id}_Annotation/genome.gff"), emit: dfast_gff_results
	
	when:
	meta.runtype == "hybrid" || meta.runtype == "long-reads" || meta.runtype == "short-reads"

	script:
	"""
	if [[ ! -f "${meta.id}_assembly.fasta" ]]; then
			cp assembly.fasta ${meta.id}_assembly.fasta
	fi
	
	dfast --force --complete f --organism ${meta.id} --strain ${meta.id} --locus_tag_prefix ${meta.id} --use_separate_tags t --minimum_length 200 --genome ${meta.id}_assembly.fasta --out ${meta.id}_Annotation --use_prodigal --use_trnascan bact --use_rnammer bact --cpu 5 
	"""
}


//you can use a uniprot database for the annotation but you need to index the database with dfast format (plz see the building database section in dfast).
//--out: output directory 
//--genome: assembly.fasta (input) 
//S3 : nom du strains (exemple) -----> ${sample_id}
