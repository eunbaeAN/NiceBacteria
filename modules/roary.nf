#!/usr/bin/env nextflow

process ROARY {

    	tag "${meta.id}, ${meta.runtype}"

	errorStrategy 'ignore'

	// cpus 36 
    	publishDir "results/${meta.id}/${meta.runtype}", /*mode: params.publish_dir_mode, overwrite: params.force,*/
        mode: 'copy',
        saveAs: { filename -> "$filename" }

	input: 
	tuple val(meta), path(fastani_results), path(dfast_gff_results)

	output:
	tuple val(meta), path("${meta.id}_Pan_genome_analysis/${meta.id}_GFF_tmp/*")
	tuple val(meta), path("${meta.id}_Pan_genome_analysis/*")

	when:
	meta.runtype == "hybrid" || meta.runtype == "long-reads" || meta.runtype == "short-reads"
	
	shell:
	'''
	mkdir -p !{meta.id}_GFF_tmp

	head -n 10 !{meta.id}_Ortho_ANI_analysis.out | cut -f2 | cut -d "/" -f2 | cut -d "_" -f1-4 > !{meta.id}_GFF_tmp/!{meta.id}_10_species.txt
	
	NAME_ID=$(head -n 10 !{meta.id}_Ortho_ANI_analysis.out  | cut -f2 | cut -d "/" -f2 | cut -d "_" -f1-4 )


	for NAME in $NAME_ID; do

		GENRE_NAME=$(echo "$NAME" | cut -d '_' -f1)
		NAME_GR_SP=$(echo "$NAME" | cut -d '_' -f1-2)
		SP_ID=$(echo "$NAME" | cut -d '_' -f3-4)

		if ! [[ -d "!{meta.id}_GFF_tmp/${NAME_GR_SP}" ]]; then 
			mkdir -p !{meta.id}_GFF_tmp/"$NAME_GR_SP"
		fi

			find /home/ean/Genome_database/"$GENRE_NAME"/"$NAME_GR_SP"/refseq/bacteria/"$SP_ID" -name '*.gff.gz' -exec cp -t !{meta.id}_GFF_tmp/"$NAME_GR_SP" {} + 2> /dev/null 
			find /home/ean/Genome_database/"$GENRE_NAME"/"$NAME_GR_SP"/refseq/bacteria/"$SP_ID" -name '*.fna.gz' -exec cp -t !{meta.id}_GFF_tmp/"$NAME_GR_SP" {} + 2> /dev/null


		pushd !{meta.id}_GFF_tmp/"$NAME_GR_SP" > /dev/null
		for i in *;
			do	 
				if [[ -s "$i" ]]; then			 
					gunzip -d < "$i" > ../"${NAME_GR_SP}_${i%%.gz}";
				fi
			done
		popd > /dev/null

		rm -rf !{meta.id}_GFF_tmp/${NAME_GR_SP}
		
	done

	if [[ ! -f "!{meta.id}_genome.gff" ]]; then
			cp genome.gff !{meta.id}_GFF_tmp/!{meta.id}_genome.gff
	fi



	pushd !{meta.id}_GFF_tmp > /dev/null			
			
		for i in *_GCF_*;
			do	 
				BASENAME="${i%.*}"
				sed -i 's/###/##FASTA/g' $BASENAME.gff
				cat $BASENAME.fna >> $BASENAME.gff
			done	
	rm *.fna

	popd > /dev/null

	roary -e --mafft -p 10 -f !{meta.id}_Pan_genome_analysis !{meta.id}_GFF_tmp/*.gff 


    if [[ -f "!{meta.id}_Pan_genome_analysis/accessory_binary_genes.fa.newick" && "!{meta.id}_Pan_genome_analysis/gene_presence_absence.csv" ]]; then

		pushd !{meta.id}_Pan_genome_analysis > /dev/null			
		roary_plots.py accessory_binary_genes.fa.newick gene_presence_absence.csv 
		popd > /dev/null

    fi

    mv !{meta.id}_GFF_tmp/ !{meta.id}_Pan_genome_analysis/


	'''
}
