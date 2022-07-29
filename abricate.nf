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

/*
 #assembly.fasta, I have to create this file having this name -> Sample_1_assembly.fasta
 #Simplify $files/Assemblies/Unicycler5.0_filtlong_"$files"_mode_bold/assembly.fasta ----> Sample_1_assembly.fasta 
 #Change the folder name from $files/Assemblies/Unicycler5.0_filtlong_"$files"_mode_bold to $files/Assemblies/Hybrid_Assembly_"$files"

*/

/*
abricate --list
DATABASE	SEQUENCES	DBTYPE	DATE
argannot	2223	nucl	2022-Apr-28
card	2631	nucl	2022-Apr-28
ecoh	597	nucl	2022-Apr-28
ecoli_vf	2701	nucl	2022-Apr-28
megares	6635	nucl	2022-Apr-28
ncbi	5386	nucl	2022-Apr-28
plasmidfinder	460	nucl	2022-Apr-28
resfinder	3077	nucl	2022-Apr-28
vfdb	2597	nucl	2022-Apr-28
*/