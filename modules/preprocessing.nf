process PREPROCESSING {

    	tag "${meta.id}, ${meta.runtype}"

	errorStrategy 'ignore'

	// cpus 36 
    	publishDir "results/${meta.id}/${meta.runtype}", 
        mode: 'copy',
        saveAs: { filename -> "$filename" }

	input: 
	tuple val(meta), path(fq)
	tuple val(meta), path(extra)

	output:
	tuple val(meta), path("${meta.id}_Cleaned_reads/${meta.id}_{Short,Long}_Reads_Cleaned/*"), emit: preprocessing_results

	when:
	meta.runtype == "hybrid" || meta.runtype == "long-reads" || meta.runtype == "short-reads"

	shell:
   	runtype = meta.runtype

	'''
	if [ "!{runtype}" == "short-reads" ]; then

		mkdir -p !{meta.id}_Cleaned_reads/!{meta.id}_Short_Reads_Cleaned
	
		#Trimmomatic
		java -jar /scratch/bin/cleaner/Trimmomatic/trimmomatic-0.39.jar PE -phred33 -threads 12 !{meta.id}_R1.fq.gz !{meta.id}_R2.fq.gz !{meta.id}_Cleaned_reads/!{meta.id}_Short_Reads_Cleaned/!{meta.id}_clean_forward_paired.fq.gz !{meta.id}_Cleaned_reads/!{meta.id}_Short_Reads_Cleaned/!{meta.id}_clean_forward_unpaired.fq.gz !{meta.id}_Cleaned_reads/!{meta.id}_Short_Reads_Cleaned/!{meta.id}_clean_reverse_paired.fq.gz !{meta.id}_Cleaned_reads/!{meta.id}_Short_Reads_Cleaned/!{meta.id}_clean_reverse_unpaired.fq.gz ILLUMINACLIP:/scratch/bin/cleaner/Trimmomatic/adapters/TruSeq3-PE-2.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:30
		cat !{meta.id}_Cleaned_reads/!{meta.id}_Short_Reads_Cleaned/!{meta.id}_clean_forward_unpaired.fq.gz !{meta.id}_Cleaned_reads/!{meta.id}_Short_Reads_Cleaned/!{meta.id}_clean_reverse_unpaired.fq.gz > !{meta.id}_Cleaned_reads/!{meta.id}_Short_Reads_Cleaned/!{meta.id}_clean_unpaired.fq.gz


	elif [ "!{runtype}" == "long-reads" ]; then

		mkdir -p !{meta.id}_Cleaned_reads/!{meta.id}_Long_Reads_Cleaned

		#=================================== PORECHOP =================================== 
		porechop -i !{meta.id}.fq.gz -b !{meta.id}_Cleaned_reads/!{meta.id}_Long_Reads_Cleaned/!{meta.id}_barcodes_reads --threads 12 --min_split_read_size 600
		cat .command.log > !{meta.id}_Cleaned_reads/!{meta.id}_Long_Reads_Cleaned/porechop.log
	
		#=================================== FILTLONG =================================== 
		FILTLONG_SIZE=`ls -S1 !{meta.id}_Cleaned_reads/!{meta.id}_Long_Reads_Cleaned/!{meta.id}_barcodes_reads | head -n1`
		echo "\$FILTLONG_SIZE" > !{meta.id}_Cleaned_reads/!{meta.id}_Long_Reads_Cleaned/filtlong_input_file.txt
	
		filtlong \
			--min_length 1000 --keep_percent 90 --target_bases 500000000 \
			!{meta.id}_Cleaned_reads/!{meta.id}_Long_Reads_Cleaned/!{meta.id}_barcodes_reads/$FILTLONG_SIZE | gzip > !{meta.id}_Cleaned_reads/!{meta.id}_Long_Reads_Cleaned/!{meta.id}_filtlong.fq.gz

	
	elif [ "!{runtype}" == "hybrid" ]; then

		mkdir -p !{meta.id}_Cleaned_reads/!{meta.id}_Long_Reads_Cleaned
		mkdir -p !{meta.id}_Cleaned_reads/!{meta.id}_Short_Reads_Cleaned
		
		#Trimmomatic
		java -jar /scratch/bin/cleaner/Trimmomatic/trimmomatic-0.39.jar PE -phred33 -threads 12 !{meta.id}_R1.fq.gz !{meta.id}_R2.fq.gz !{meta.id}_Cleaned_reads/!{meta.id}_Short_Reads_Cleaned/!{meta.id}_clean_forward_paired.fq.gz !{meta.id}_Cleaned_reads/!{meta.id}_Short_Reads_Cleaned/!{meta.id}_clean_forward_unpaired.fq.gz !{meta.id}_Cleaned_reads/!{meta.id}_Short_Reads_Cleaned/!{meta.id}_clean_reverse_paired.fq.gz !{meta.id}_Cleaned_reads/!{meta.id}_Short_Reads_Cleaned/!{meta.id}_clean_reverse_unpaired.fq.gz ILLUMINACLIP:/scratch/bin/cleaner/Trimmomatic/adapters/TruSeq3-PE-2.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:30
		cat !{meta.id}_Cleaned_reads/!{meta.id}_Short_Reads_Cleaned/!{meta.id}_clean_forward_unpaired.fq.gz !{meta.id}_Cleaned_reads/!{meta.id}_Short_Reads_Cleaned/!{meta.id}_clean_reverse_unpaired.fq.gz > !{meta.id}_Cleaned_reads/!{meta.id}_Short_Reads_Cleaned/!{meta.id}_clean_unpaired.fq.gz


		#=================================== PORECHOP =================================== 
		porechop -i !{meta.id}.fq.gz -b !{meta.id}_Cleaned_reads/!{meta.id}_Long_Reads_Cleaned/!{meta.id}_barcodes_reads --threads 12 --min_split_read_size 600
		cat .command.log > !{meta.id}_Cleaned_reads/!{meta.id}_Long_Reads_Cleaned/porechop.log
	

		#=================================== FILTLONG =================================== 
		FILTLONG_SIZE=`ls -S1 !{meta.id}_Cleaned_reads/!{meta.id}_Long_Reads_Cleaned/!{meta.id}_barcodes_reads | head -n1`
		echo "\$FILTLONG_SIZE" > !{meta.id}_Cleaned_reads/!{meta.id}_Long_Reads_Cleaned/filtlong_input_file.txt
	
		filtlong \
			-1 !{meta.id}_R1.fq.gz \
			-2 !{meta.id}_R1.fq.gz \
			--min_length 1000 --keep_percent 90 --target_bases 500000000 \
			!{meta.id}_Cleaned_reads/!{meta.id}_Long_Reads_Cleaned/!{meta.id}_barcodes_reads/$FILTLONG_SIZE | gzip > !{meta.id}_Cleaned_reads/!{meta.id}_Long_Reads_Cleaned/!{meta.id}_filtlong.fq.gz


	fi

	'''
}



//	tuple val(meta), path("${meta.id}_Cleaned/${meta.id}_Short_Reads_Cleaned/${meta.id}_clean_forward_paired.fq.gz"), path("${meta.id}_Cleaned/${meta.id}_Short_Reads_Cleaned/${meta.id}_clean_reverse_paired.fq.gz"), path("${meta.id}_Cleaned/${meta.id}_Short_Reads_Cleaned/${meta.id}_clean_unpaired.fq.gz"), emit: short_preprocessing_results 
