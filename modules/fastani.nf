#!/usr/bin/env nextflow

process FASTANI {

    	tag "${meta.id}, ${meta.runtype}"

	errorStrategy 'ignore'

	// cpus 36 
    	publishDir "results/${meta.id}/${meta.runtype}", /*mode: params.publish_dir_mode, overwrite: params.force,*/
        mode: 'copy',
        saveAs: { filename -> "$filename" }

	input: 
	tuple val(meta), path(assembly_results_fasta), path(barrnap_xls_results)


	output:
	tuple val(meta), path("${meta.id}_Ortho_ANI_analysis/${meta.id}_Ortho_ANI_analysis.out"), emit: fastani_results
	tuple val(meta), path("${meta.id}_Ortho_ANI_analysis/${meta.id}_Reference_genomes_list.txt")

	when:
	meta.runtype == "hybrid" || meta.runtype == "long-reads" || meta.runtype == "short-reads"
	
	shell:
	'''
	mkdir -p !{meta.id}_FastANI_tmp_orthoani

	#on fixe arg1 pour le nom de genres "$1" == GENRE
	#GENRE=$(sed -n '6, 10p' !{meta.id}_blast.xls | cut -d$'\t' -f11 | cut -d ' ' -f1,2 | sort | uniq | cut -d ' ' -f1)
	#var $SPECIES=nom de species
	#SPECIES=$(sed -n '6, 10p' !{meta.id}_blast.xls | cut -d$'\t' -f11 | cut -d ' ' -f1,2 | sort | uniq | cut -d ' ' -f2)

	BAC_NAME=$(sed -n '6, 10p' !{meta.id}_blast.xls | cut -d$'\t' -f11 | cut -d ' ' -f1,2 | sort | uniq | cut -d ' ' -f1,2 | sed 's/ /_/g')

	for GR_SP in $BAC_NAME; do 
	
		GR=$(echo "$GR_SP" | cut -d '_' -f1)
		SP=$(echo "$GR_SP" | cut -d '_' -f2)
		#	echo "!{meta.id}" "$GR" "$SP";
		#	echo "${GR_SP}"

		if [[ -d "/home/ean/Genome_database/${GR}/${GR_SP}" ]]; then 
			mkdir -p !{meta.id}_FastANI_tmp_orthoani/"$GR_SP"
			find /home/ean/Genome_database/"$GR"/"$GR_SP"/refseq/bacteria/GCF_* -name '*.fna.gz' -exec cp --backup=numbered -t !{meta.id}_FastANI_tmp_orthoani/"$GR_SP" {} + > /dev/null

				pushd !{meta.id}_FastANI_tmp_orthoani/"$GR_SP" > /dev/null

					for i in *.fna.gz;
					do	
						if [[ -s "$i" ]]; then			 
							gunzip -d < "$i" > ../"${GR_SP}_${i%%.gz}";
						fi 
					done
								#je change le nom de fichier .fna avec le nom de genre et le nom d'espèce

					rm -rf !{meta.id}_FastANI_tmp_orthoani/"$GR_SP"
				popd > /dev/null

		else 
			echo "ATTENTION ! : ${GR_SP} does not exsit in your database: /home/ean/Genome_database" 

		fi

	done 


	mkdir -p !{meta.id}_Ortho_ANI_analysis

	ls -d !{meta.id}_FastANI_tmp_orthoani/*.fna > !{meta.id}_Ortho_ANI_analysis/!{meta.id}_Reference_genomes_list.txt


	if [[ ! -f "!{meta.id}_assembly.fasta" ]]; then
			cp assembly.fasta !{meta.id}_assembly.fasta
	fi

	fastANI -q !{meta.id}_assembly.fasta --rl !{meta.id}_Ortho_ANI_analysis/!{meta.id}_Reference_genomes_list.txt -o !{meta.id}_Ortho_ANI_analysis/!{meta.id}_Ortho_ANI_analysis.out

	rm -rf !{meta.id}_FastANI_tmp_orthoani

	'''
}

// ./fastANI -q [QUERY_GENOME] --rl [REFERENCE_LIST] -o [OUTPUT_FILE]
//.... extraction du 10 premier lignes de f
