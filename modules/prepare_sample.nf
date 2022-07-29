process PREPARE_SAMPLES {
    /* Gather up input FASTQs for analysis. */

    tag "${meta.id}, ${meta.runtype}"

    errorStrategy 'ignore'
    
    publishDir "results/${sample_id}/${meta.runtype}", 
    mode: 'copy',
    saveAs: { filename -> "$filename" }

    input:
    tuple val(meta), path(r1, stageAs: '*???-r1'), path(r2, stageAs: '*???-r2'), path(extra)

    output:
    tuple val(meta), path("${meta.id}_Raw_reads/Illumina_Raw_reads/*.gz"), emit: fastq_short_rawreads, optional: true
    tuple val(meta), path("${meta.id}_Raw_reads/Nanopore_Raw_reads/*.gz"), emit: fastq_long_rawreads, optional: true
    tuple val(meta), path("${meta.id}_Raw_reads/Assembled_By_Users/*"), emit: assembled_fasta, optional: true
    stdout emit: FileExists

    shell:
    sample_id = meta.id 
    runtype = meta.runtype

    '''
    mkdir -p !{meta.id}_Raw_reads/Illumina_Raw_reads
    mkdir -p !{meta.id}_Raw_reads/Nanopore_Raw_reads

    if [ "!{runtype}" == "hybrid" ]; then
        # Paired-End Reads + Nanopore reads
        if [ -s !{r1[0]} ] && [ -s !{r2[0]} ] && [ -s !{extra} ]; then
        #   echo "Input Upload Sucess ! : Your input file is found and saved in results/!{meta.id}/!{runtype}/!{meta.id}_Raw_reads"
            cp -L !{r1[0]} !{meta.id}_Raw_reads/Illumina_Raw_reads/!{meta.id}_R1.fq.gz
            cp -L !{r2[0]} !{meta.id}_Raw_reads/Illumina_Raw_reads/!{meta.id}_R2.fq.gz
            cp -L !{extra} !{meta.id}_Raw_reads/Nanopore_Raw_reads/!{meta.id}.fq.gz

           ERROR=0
            # Check paired-end reads have same read counts
            OPTS="--sample !{meta.id} --runtype !{runtype}"
 
            gzip -cd !{meta.id}_Raw_reads/Illumina_Raw_reads/!{meta.id}_R1.fq.gz | fastq-scan > !{meta.id}_r1.json
            gzip -cd !{meta.id}_Raw_reads/Illumina_Raw_reads/!{meta.id}_R1.fq.gz | fastq-scan > !{meta.id}_r2.json

            if ! /home/ean/Samples_data/workflow/Samples/separation_nextflow_modules/modules/bin/check-fastqs_r1r2.py --fq1 !{meta.id}_r1.json --fq2 !{meta.id}_r2.json ${OPTS}; then
                ERROR=1
            fi
            rm !{meta.id}_r1.json !{meta.id}_r2.json

            if [ "${ERROR}" -eq "1" ]; then
               mv !{meta.id}_Raw_reads/Illumina_Raw_reads/ failed-tests-fastqs/
               echo "Error : The reads total of Illumina inputs (R1 and R2) are different."
            fi

        elif ! [ -s !{r2[0]} ] && ! [ -s !{r2[0]} ]; then
            echo "Error (Input File not found) : Please check again your input file information that you provide (--samples txt or csv file, separator: \\t ). \nError INFORMATION : sample("!{meta.id}"), runtype("!{runtype}"), reads(r1 and r2) \n(ATTENTION ! Check again the PATH of input files and file name, lowercase and uppercase letters are considered different.)"
        elif ! [ -s !{r1[0]} ] && ! [ -s !{extra} ]; then
            echo "Error (Input File not found) : Please check again your input file information that you provide (--samples txt or csv file, separator: \\t ). \nError INFORMATION : sample("!{meta.id}"), runtype("!{runtype}"), reads(r1 and long_reads) \n(ATTENTION ! Check again the PATH of input files and file name, lowercase and uppercase letters are considered different.)"
        elif ! [ -s !{r2[0]} ] && ! [ -s !{extra} ]; then
            echo "Error (Input File not found) : Please check again your input file information that you provide (--samples txt or csv file, separator: \\t ). \nError INFORMATION : sample("!{meta.id}"), runtype("!{runtype}"), reads(r2 and long_reads) \n(ATTENTION ! Check again the PATH of input files and file name, lowercase and uppercase letters are considered different.)"
        elif ! [ -s !{r1[0]} ]; then
            echo "Error (Input File not found) : Please check again your input file information that you provide (--samples txt or csv file, separator: \\t ). \nError INFORMATION : sample("!{meta.id}"), runtype("!{runtype}"), reads(r1) \n(ATTENTION ! Check again the PATH of input files and file name, lowercase and uppercase letters are considered different.)"
        elif ! [ -s !{r2[0]} ]; then
            echo "Error (Input File not found) : Please check again your input file information that you provide (--samples txt or csv file, separator: \\t ). \nError INFORMATION : sample("!{meta.id}"), runtype("!{runtype}"), reads(r2) \n(ATTENTION ! Check again the PATH of input files and file name, lowercase and uppercase letters are considered different.)"
        elif ! [ -s !{extra} ]; then
            echo "Error (Input File not found) : Please check again your input file information that you provide (--samples txt or csv file, separator: \\t ). \nError INFORMATION : sample("!{meta.id}"), runtype("!{runtype}"), reads(long_reads) \n(ATTENTION ! Check again the PATH of input files and file name, lowercase and uppercase letters are considered different.)"
        fi


    elif [ "!{runtype}" == "long-reads" ]; then
        # Nanopore reads
        if [ -s !{extra} ]; then
            #   echo "Input Upload Sucess ! : Your input file is found and saved in results/!{meta.id}/!{runtype}/!{meta.id}_Raw_reads"
            cp -L !{extra} !{meta.id}_Raw_reads/Nanopore_Raw_reads/!{meta.id}.fq.gz
            touch !{meta.id}_Raw_reads/Illumina_Raw_reads/empty.fna.gz
        else 
            echo "Error (Input File not found) : Please check again your input file information that you provide (--samples txt or csv file, separator: \\t ). \nError INFORMATION : sample("!{meta.id}"), runtype("!{runtype}"), reads(long_reads) \n(ATTENTION ! Check again the PATH of input files and file name, lowercase and uppercase letters are considered different.)"
        fi


    elif  [ "!{runtype}" == "short-reads" ]; then
        # Paired-End Reads
        if [ -s !{r1[0]} ] && [ -s !{r2[0]} ]; then
            #   echo "Input Upload Sucess ! : Your input file is found and saved in results/!{meta.id}/!{runtype}/!{meta.id}_Raw_reads"
            cp -L !{r1[0]} !{meta.id}_Raw_reads/Illumina_Raw_reads/!{meta.id}_R1.fq.gz
            cp -L !{r2[0]} !{meta.id}_Raw_reads/Illumina_Raw_reads/!{meta.id}_R2.fq.gz
            touch !{meta.id}_Raw_reads/Nanopore_Raw_reads/empty.fna.gz

            ERROR=0
            # Check paired-end reads have same read counts
            OPTS="--sample !{meta.id} --runtype !{runtype}"
 
            gzip -cd !{meta.id}_Raw_reads/Illumina_Raw_reads/!{meta.id}_R1.fq.gz | fastq-scan > !{meta.id}_r1.json
            gzip -cd !{meta.id}_Raw_reads/Illumina_Raw_reads/!{meta.id}_R1.fq.gz | fastq-scan > !{meta.id}_r2.json

            if ! /home/ean/Samples_data/workflow/Samples/separation_nextflow_modules/modules/bin/check-fastqs_r1r2.py --fq1 !{meta.id}_r1.json --fq2 !{meta.id}_r2.json ${OPTS}; then
                ERROR=1
            fi
            rm !{meta.id}_r1.json !{meta.id}_r2.json

            if [ "${ERROR}" -eq "1" ]; then
               mv !{meta.id}_Raw_reads/Illumina_Raw_reads/ failed-tests-fastqs/
               echo "Error : The reads total of Illumina inputs (R1 and R2) are different."
            fi
        elif ! [ -s !{r1[0]} ]; then
            echo "Error (Input File not found) : Please check again your input file information that you provide (--samples txt or csv file, separator: \\t ). \nError INFORMATION : sample("!{meta.id}"), runtype("!{runtype}"), reads(r1) \n(ATTENTION ! Check again the PATH of input files and file name, lowercase and uppercase letters are considered different.)"
        elif ! [ -s !{r2[0]} ]; then
            echo "Error (Input File not found) : Please check again your input file information that you provide (--samples txt or csv file, separator: \\t ). \nError INFORMATION : sample("!{meta.id}"), runtype("!{runtype}"), reads(r2) \n(ATTENTION ! Check again the PATH of input files and file name, lowercase and uppercase letters are considered different.)"
        else
            echo "Error (Input File not found) : Please check again your input file information that you provide (--samples txt or csv file, separator: \\t ). \nError INFORMATION : sample("!{meta.id}"), runtype("!{runtype}"), reads(r1 and r2) \n(ATTENTION ! Check again the PATH of input files and file name, lowercase and uppercase letters are considered different.)"
        fi


    elif  [ "!{runtype}" == "assembled" ]; then
        if [ -s !{extra} ]; then
            mkdir -p !{meta.id}_Raw_reads/Assembled_By_Users
            # Users provide Assembled fasta file

            # Check if this file is FASTA
            Line1=$(cat !{extra} | head -n 1)
            Line2=$(cat !{extra} | sed -n '2p' )

            firstletter=${Line1:0:1}
            secondletter=${Line1:1:1}
            espace="[[:space:]]"


            if [[ ${firstletter} == ">" ]] && ! [[ ${secondletter} == ${espace} ]] ; then
                echo "!{meta.id} FASTA file validated... The pipeline continues .... : QUAST and Post-processing analysis"
                cp -L !{extra} !{meta.id}_Raw_reads/Assembled_By_Users/!{meta.id}_assembly.fasta
            else 
                echo "Error (FASTA file not validated): The file of !{meta.id} is NOT FASTA format. Please check the input file."
            fi

        else
            echo "Error (Input File not found) : Please check again your input file information that you provide (--samples txt or csv file, separator: \\t ). \nError INFORMATION : sample("!{meta.id}"), runtype("!{runtype}") \n(ATTENTION ! Check again the PATH of input files and file name, lowercase and uppercase letters are considered different.)"
        fi
    fi

    '''
}
