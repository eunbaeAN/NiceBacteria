#!/usr/bin/env nextflow

process ASSEMBLED_FASTTREE {

    tag "${meta.id}, ${meta.runtype}"

	errorStrategy 'ignore'

	// cpus 36 
    publishDir "results/${meta.id}/${meta.runtype}", /*mode: params.publish_dir_mode, overwrite: params.force,*/
        mode: 'copy',
        saveAs: { filename -> "$filename" }

	input: 
	tuple val(meta), path(assembled_barrnap_results)


	output:
	tuple val(meta), path("${meta.id}_Phylogenetic_tree/*")

	when:
	meta.runtype == "assembled"
	
	shell:

	'''
	mkdir -p !{meta.id}_Phylogenetic_tree

	sed "s/>/>!{meta.id}_/g" !{meta.id}_16S_rRNA.fasta > !{meta.id}_Phylogenetic_tree/!{meta.id}_16S.fa
	
	ENTRIES=$(sed -n '6, 15p' results_blast/!{meta.id}_blast.xls | cut -d$'\t' -f2 | cut -d '|' -f2)

	for ENTRY in $ENTRIES;
	do	blastdbcmd -db /scratch/db/16S_ribosomal_RNA/blastDB/16S_ribosomal_RNA -entry "$ENTRY" >> !{meta.id}_Phylogenetic_tree/!{meta.id}_16S.fa
	done
	
	sed -i 's/ /_/g' !{meta.id}_Phylogenetic_tree/!{meta.id}_16S.fa 
	sed -i 's/_strain.*/ /g' !{meta.id}_Phylogenetic_tree/!{meta.id}_16S.fa
	
	muscle -align !{meta.id}_Phylogenetic_tree/!{meta.id}_16S.fa -output !{meta.id}_Phylogenetic_tree/!{meta.id}_multiple_alignments_by_muscle.afa
	FastTree -gtr -nt !{meta.id}_Phylogenetic_tree/!{meta.id}_multiple_alignments_by_muscle.afa > !{meta.id}_Phylogenetic_tree/!{meta.id}.tree



	'''
}


//	plottree !{meta.id}_Phylogenetic_tree/!{meta.id}.tree -s 10.0 -w 6.4 -l 4.8 -x -0.00 0.01 -y 11.80 0.30 -o !{meta.id}_Phylogenetic_tree/!{meta.id}_tree
