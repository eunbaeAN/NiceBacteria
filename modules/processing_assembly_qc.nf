process PROCESSING_ASSEMBLY_QC {

    	tag "${meta.id}, ${meta.runtype}"

	errorStrategy 'ignore'

	// cpus 36 
    	publishDir "results/${meta.id}/${meta.runtype}", /*mode: params.publish_dir_mode, overwrite: params.force,*/
        mode: 'copy',
        saveAs: { filename -> "$filename" }


	input: 
	tuple val(meta), path(assembled_fasta)

	output:
	tuple val(meta), path("${meta.id}_Assemblies/${meta.id}_Assembly_Report/*"), emit: assembly_report

	when:
	meta.runtype == "assembled"
	script:
    	runtype = meta.runtype

	"""

	#QUAST Assembly quality evaluation
	quast.py ${meta.id}_assembly.fasta -o ${meta.id}_Assemblies/${meta.id}_Assembly_Report


	"""
}
