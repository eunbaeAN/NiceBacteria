process PROCESSING {

    tag "${meta.id}, ${meta.runtype}"

	errorStrategy 'ignore'

	// cpus 36 
    publishDir "results/${meta.id}/${meta.runtype}", /*mode: params.publish_dir_mode, overwrite: params.force,*/
        mode: 'copy',
        saveAs: { filename -> "$filename" }

	input: 
	tuple val(meta), path(preprocessing_results)

	output:
	tuple val(meta), path("${meta.id}_Assemblies/${meta.id}_{Short,Long,Hybrid}_Reads_Assembly/*"), emit: assembly_results
	tuple val(meta), path("${meta.id}_Assemblies/${meta.id}_{Short,Long,Hybrid}_Reads_Assembly_Report/*"), path("${meta.id}_Assemblies/${meta.id}_Assembly_Report"), emit: assembly_report, optional: true
	tuple val(meta), path("${meta.id}_Assemblies/${meta.id}_{Short,Long,Hybrid}_Reads_Assembly/${meta.id}_assembly.fasta"), emit: assembly_results_fasta

	when:
	meta.runtype == "hybrid" || meta.runtype == "long-reads" || meta.runtype == "short-reads"

	script:
    runtype = meta.runtype

	"""
	if [ "${runtype}" == "short-reads" ]; then

		mkdir -p ${meta.id}_Assemblies/${meta.id}_Short_Reads_Assembly 

		#SPAdes
		spades.py \
			-o ${meta.id}_Assemblies/${meta.id}_Short_Reads_Assembly \
			--isolate -1 ${meta.id}_clean_forward_paired.fq.gz -2 ${meta.id}_clean_reverse_paired.fq.gz \
			-s ${meta.id}_clean_unpaired.fq.gz -t 12 -k 77,99,127 --cov-cutoff auto

		cp ${meta.id}_Assemblies/${meta.id}_Short_Reads_Assembly/scaffolds.fasta ${meta.id}_Assemblies/${meta.id}_Short_Reads_Assembly/${meta.id}_assembly.fasta

		#QUAST 
		quast.py ${meta.id}_Assemblies/${meta.id}_Short_Reads_Assembly/${meta.id}_assembly.fasta -o ${meta.id}_Assemblies/${meta.id}_Short_Reads_Assembly_Report


	elif [ "${runtype}" == "long-reads" ]; then

		mkdir -p ${meta.id}_Assemblies/${meta.id}_Long_Reads_Assembly 

		#FLYE long assembly
		flye --nano-raw ${meta.id}_filtlong.fq.gz --out-dir ${meta.id}_Assemblies/${meta.id}_Long_Reads_Assembly --threads 20 --trestle --plasmids
	
		cp ${meta.id}_Assemblies/${meta.id}_Long_Reads_Assembly/assembly.fasta ${meta.id}_Assemblies/${meta.id}_Long_Reads_Assembly/${meta.id}_assembly.fasta

		#QUAST Assembly quality evaluation
		quast.py ${meta.id}_Assemblies/${meta.id}_Long_Reads_Assembly/${meta.id}_assembly.fasta -o ${meta.id}_Assemblies/${meta.id}_Long_Reads_Assembly_Report


	elif [ "${runtype}" == "hybrid" ]; then

		mkdir -p ${meta.id}_Assemblies/${meta.id}_Hybrid_Reads_Assembly 

		unicycler \
			--short1 ${meta.id}_clean_forward_paired.fq.gz \
			--short2 ${meta.id}_clean_reverse_paired.fq.gz \
			--unpaired ${meta.id}_clean_unpaired.fq.gz \
			--long ${meta.id}_filtlong.fq.gz \
			--out ${meta.id}_Assemblies/${meta.id}_Hybrid_Reads_Assembly --mod bold --min_fasta_length 800 --threads 25  --contamination lambda --keep 3

		
		sed -n '/Component/,/Rotating/p' ${meta.id}_Assemblies/${meta.id}_Hybrid_Reads_Assembly/unicycler.log | head -n -3 > ${meta.id}_Assemblies/${meta.id}_Hybrid_Reads_Assembly/info_assembly.txt


		cp ${meta.id}_Assemblies/${meta.id}_Hybrid_Reads_Assembly/assembly.fasta ${meta.id}_Assemblies/${meta.id}_Hybrid_Reads_Assembly/${meta.id}_assembly.fasta


		#Assembly quality evaluation
		quast.py ${meta.id}_Assemblies/${meta.id}_Hybrid_Reads_Assembly/${meta.id}_assembly.fasta -o ${meta.id}_Assemblies/${meta.id}_Hybrid_Reads_Assembly_Report


	fi


	"""
}