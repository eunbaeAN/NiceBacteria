nextflow.enable.dsl = 2
//params.outdir = 'results'

/*
========================================================================================
    CONFIG FILES
========================================================================================
*/

include { create_input_channel } from '../lib/nf/test_samplename'
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
include { PHYLO_TREE } from '../modules/phylotree'

include { ASSEMBLED_DFAST } from '../modules/assembled/assembled_dfast'
include { ASSEMBLED_ABRICATE } from '../modules/assembled/assembled_abricate'
include { ASSEMBLED_BARRNAP } from '../modules/assembled/assembled_barrnap'
include { ASSEMBLED_FASTANI } from '../modules/assembled/assembled_fastani'
include { ASSEMBLED_MLST } from '../modules/assembled/assembled_mlst'
include { ASSEMBLED_ROARY } from '../modules/assembled/assembled_roary'
include { ASSEMBLED_PHYLO_TREE } from '../modules/assembled/assembled_phylotree'


/*
========================================================================================
    RUN MAIN WORKFLOW
========================================================================================
*/


@Grab('com.xlson.groovycsv:groovycsv:1.1')
import static com.xlson.groovycsv.CsvParser.parseCsv


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
println "Le nombre d'échantillons est ${samples_numbers}" //2


for (int i = 1; i <= samples_numbers; i++){
	//println(samples_info["runtype"][i])
	Run_type = (samples_info["runtype"][i])
	println"Le runtype est ${Run_type}"
}

println"L'adresse mail : ${samples_info["email"][1]}"
//println(samples_info["runtype"][0]) //runtype
//println(samples_info["runtype"][1]) //hybrid
//println(samples_info["runtype"][2]) //hybrid


//count the number of raws and use for loop?? 
/*
if ((samples_info["runtype"]) == "hybrid"){
	println "HIBRYD"
}else {println "QUOI"}

*/
//def info_runtype = parseCsv(info_samples, separator: '\t', readFirstLine: true)
//info_runtype.each { line -> println line["runtype"] }


println "Vous allez  recevoir un mail à ${samples_info["email"][1]} une fois l'exécution est terminée"


workflow TEST_WORKFLOW {
		input_ch = create_input_channel("multiples_samples")
		PREPARE_SAMPLES(input_ch)
		PREPARE_SAMPLES.out.FileExists.view()

        PREPROCESSING(PREPARE_SAMPLES.out.fastq_long_rawreads, PREPARE_SAMPLES.out.fastq_short_rawreads)
 		PROCESSING(PREPROCESSING.out) 		

		BARRNAP(PROCESSING.out.assembly_results_fasta)
		ABRICATE(PROCESSING.out.assembly_results_fasta)
		DFAST(PROCESSING.out.assembly_results_fasta)
		MLST(PROCESSING.out.assembly_results_fasta)
		FASTANI(BARRNAP.out.barrnap_xls_results.join(PROCESSING.out.assembly_results_fasta))
		ROARY(DFAST.out.dfast_gff_results.join(FASTANI.out.fastani_results))
		PHYLO_TREE(BARRNAP.out.barrnap_results)


//When the users provide the assembled fasta files, it starts from QUAST.

 		PROCESSING_ASSEMBLY_QC(PREPARE_SAMPLES.out.assembled_fasta)
		ASSEMBLED_BARRNAP(PREPARE_SAMPLES.out.assembled_fasta)
		ASSEMBLED_ABRICATE(PREPARE_SAMPLES.out.assembled_fasta)
		ASSEMBLED_DFAST(PREPARE_SAMPLES.out.assembled_fasta)
		ASSEMBLED_MLST(PREPARE_SAMPLES.out.assembled_fasta)
		ASSEMBLED_FASTANI(ASSEMBLED_BARRNAP.out.assembled_barrnap_xls_results.join(PREPARE_SAMPLES.out.assembled_fasta))
		ASSEMBLED_ROARY(ASSEMBLED_DFAST.out.assembled_dfast_gff_results.join(ASSEMBLED_FASTANI.out.assembled_fastani_results))
		ASSEMBLED_PHYLO_TREE(ASSEMBLED_BARRNAP.out.assembled_barrnap_results)



}


//take keyword : declare one or more input channels
//when the "take" keyword is used, the beginning of the worflow body must be identified with the "main" keyword  



/*
========================================================================================
    COMPLETION EMAIL AND SUMMARY
========================================================================================
*/

workflow.onComplete {
  	log.info (workflow.success ? "\nDone! " : "Opps . . something went wrong")

    def subject = 'Pipeline execution is finished'
    def recipient = "${samples_info["email"][1]}"
    def attach = "${workflow.launchDir}/REPORT.html"
    ['mail', '-a', attach, '-s', subject, recipient ].execute() << """
 
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
    THE END
========================================================================================
*/