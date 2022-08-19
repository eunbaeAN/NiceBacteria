nextflow.enable.dsl = 2
//params.outdir = 'results'

params.help = false
params.dfast_organism = false
params.dfast_strain = false
params.samples = false
/*
========================================================================================
    CONFIG FILES
========================================================================================
*/

include { create_input_channel } from '../lib/nf/input_channel'
//workflow keyword allows the definition of sub-workflow components that enclose the invocation of one or more processes and operators: 

//run_type = WorkflowPipeline.initialise(workflow, params, log)
//WorkflowPipeline = lib/WorkflowPipeline.groovy


/*
========================================================================================
    IMPORT LOCAL MODULES
========================================================================================
*/

include { PREPARE_SAMPLES } from '../modules/prepare_sample'
include { PREPROCESSING } from '../modules/preprocessing'
include { PROCESSING } from '../modules/processing'
include { PROCESSING_ASSEMBLY_QC } from '../modules/processing_assembly_qc'

include { DFAST } from '../modules/dfast'
include { ABRICATE } from '../modules/abricate'
include { BARRNAP } from '../modules/barrnap'
include { FASTANI } from '../modules/fastani'
include { MLST } from '../modules/mlst'
include { ROARY } from '../modules/roary'
include { PHYLO_16S_TREE } from '../modules/phylotree'

include { ASSEMBLED_DFAST } from '../modules/assembled/assembled_dfast'
include { ASSEMBLED_ABRICATE } from '../modules/assembled/assembled_abricate'
include { ASSEMBLED_BARRNAP } from '../modules/assembled/assembled_barrnap'
include { ASSEMBLED_FASTANI } from '../modules/assembled/assembled_fastani'
include { ASSEMBLED_MLST } from '../modules/assembled/assembled_mlst'
include { ASSEMBLED_ROARY } from '../modules/assembled/assembled_roary'
include { ASSEMBLED_PHYLO_16S_TREE } from '../modules/assembled/assembled_phylotree'


/*
========================================================================================
    DISPLAY THE INFORMATION about ryntype and email address 
========================================================================================
*/

@Grab('com.xlson.groovycsv:groovycsv:1.1')
import static com.xlson.groovycsv.CsvParser.parseCsv

if (params.samples){
def samples_info = []
def samples_txt = new File( params.samples )

samples_txt.eachLine { line -> 
	def parts = line.split("\t")
	def tmpMap = [:]
	
	tmpMap.putAt("sample", parts[0])
	tmpMap.putAt("runtype", parts[1])
	tmpMap.putAt("email", parts[6])

	samples_info.add(tmpMap)
}

samples_numbers = (samples_info.size() - 1) //0,1,2 = 3 
println "The number of samples : ${samples_numbers}" //2


for (int i = 1; i <= samples_numbers; i++){
	//println(samples_info["runtype"][i])
	Run_type = (samples_info["runtype"][i])
	println"The runtype is ${Run_type}"
}


email_adresse = "${samples_info["email"][1]}"

println "You will receive an email at : ${email_adresse} once the execution is complete"
}
else if(params.help){
    helpMessage()
    exit 0
}else{
	println "WARN, you need to provide the information of samples by using the parameter '--samples'. Exemple : --samples PATH/my-samples.csv. \n--help if you need more information."
}


/*
========================================================================================
    RUN MAIN WORKFLOW
========================================================================================
*/

workflow TEST_WORKFLOW {
		input_ch = create_input_channel("multiple_samples")
		PREPARE_SAMPLES(input_ch)
		PREPARE_SAMPLES.out.FileExists.view()

        PREPROCESSING(PREPARE_SAMPLES.out.fastq_long_rawreads.join(PREPARE_SAMPLES.out.fastq_short_rawreads))
 		PROCESSING(PREPROCESSING.out) 		

		BARRNAP(PROCESSING.out.assembly_results_fasta)
		ABRICATE(PROCESSING.out.assembly_results_fasta)
		DFAST(PROCESSING.out.assembly_results_fasta)
		MLST(PROCESSING.out.assembly_results_fasta)
		FASTANI(BARRNAP.out.barrnap_xls_results.join(PROCESSING.out.assembly_results_fasta))
		ROARY(DFAST.out.dfast_gff_results.join(FASTANI.out.fastani_results))
		PHYLO_16S_TREE(BARRNAP.out.barrnap_results)


//When the users provide the assembled fasta files, it starts from QUAST.

 		PROCESSING_ASSEMBLY_QC(PREPARE_SAMPLES.out.assembled_fasta)
		ASSEMBLED_BARRNAP(PREPARE_SAMPLES.out.assembled_fasta)
		ASSEMBLED_ABRICATE(PREPARE_SAMPLES.out.assembled_fasta)
		ASSEMBLED_DFAST(PREPARE_SAMPLES.out.assembled_fasta)
		ASSEMBLED_MLST(PREPARE_SAMPLES.out.assembled_fasta)
		ASSEMBLED_FASTANI(ASSEMBLED_BARRNAP.out.assembled_barrnap_xls_results.join(PREPARE_SAMPLES.out.assembled_fasta))
		ASSEMBLED_ROARY(ASSEMBLED_DFAST.out.assembled_dfast_gff_results.join(ASSEMBLED_FASTANI.out.assembled_fastani_results))
		ASSEMBLED_PHYLO_16S_TREE(ASSEMBLED_BARRNAP.out.assembled_barrnap_results)
}


/*
========================================================================================
    COMPLETION EMAIL AND SUMMARY
========================================================================================
*/


workflow.onComplete {
  	log.info (workflow.success ? "\nDone! " : "Opps . . something went wrong")
    def subject = 'Pipeline execution is finished'
    def recipient = "${email_adresse}"
    def attach = "${workflow.launchDir}/REPORT.html"
    [ 'mail', '-a', attach, '-s', subject, recipient ].execute() << """
 
    	Pipeline Execution Summary
    	-----------------------------------------
    	Nextflow Version  : ${nextflow.version}
    	Resumed            : ${workflow.resume}
    	Completed At      : ${workflow.complete}
    	Duration              : ${workflow.duration}
    	Success              : ${workflow.success}
    	Exit Code            : ${workflow.exitStatus}
   		WorkDir  		    : ${workflow.workDir}
	   	PublishDir  	    : ${workflow.launchDir}/results
    	"""
    	.stripIndent()
    
}


/*
========================================================================================
    HELP MESSAGE
========================================================================================
*/
def helpMessage() {
	log.info"""
	=====================================================================================================
	 	.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.NiceBacteria.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.
	=====================================================================================================

	Usage:
	To run this pipeline :
	nextflow run /home/ean/NiceBacteria/main.nf --samples /path/to/my-samples.csv -ansi-log false

	Required arguments:
		--samples : Path to the samplesheet file

	How to prepare the samplesheet file (--samples filename.csv or filename.txt)
		Header : sample \\t runtype \\t r1 \\t r2 \\t long_reads \\t assembled_fasta \\t email (tab delimited file)
		sample : sample name that you want. 
		runtype : you can choose one of these : short-reads, hybrid, long-reads, assembled
		r1 : short reads input file (forward). You should provide the path also.  
		r2 : short reads input file (reverse). You should provide the path also.  
		long_reads : long reads input file. You should provide the path also.
		assembled : the fasta file which is already assembled before.

	Options : 
		-ansi-log false : I recommand you to use the option "-ansi-log false" which allows you to have the information of the process by each sample. (Default : true) 
		-resume : Execute the script using the cached results, useful to continue executions that was stopped by an error. 
		-cpus : 
		-qs, -queue-size : Max number of processes that can be executed in parallel by each executor.
	If you need more information please visit here : https://github.com/eunbaeAN/NiceBacteria
    """.stripIndent()
}
/*
========================================================================================
    THE END
========================================================================================
*/
