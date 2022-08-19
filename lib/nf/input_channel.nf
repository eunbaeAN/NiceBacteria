def create_input_channel(runtype) {
//if_fofn => if (Utils.isLocal(params.samples)) { error += Utils.fileNotFound(params.samples, 'samples', log)}
    if (runtype == "multiple_samples") {
        return Channel.fromPath( params.samples )
            .splitCsv(header: true, strip: true, sep: '\t')
            .map { row -> process_fofn(row) }
    } else {
        log.error("Something went wrong. Please verify workflow/main_workflow.nf")
        exit 1
    }
}


def process_fofn(line) {
    /* Parse line and determine if single end or paired reads*/
    def meta = [:]
    meta.id = line.sample
    meta.runtype = line.runtype
    if (line.sample) {
        if (/*line.runtype == 'single-end' || */line.runtype == 'long-reads') {
            return tuple(meta, [params.empty_r1], [params.empty_r2], file(line.long_reads))
        } else if (line.runtype == 'short-reads') {
            return tuple(meta, [file(line.r1)], [file(line.r2)], file(params.empty_long_reads))
        } else if (line.runtype == 'hybrid') {
            return tuple(meta, [file(line.r1)], [file(line.r2)], file(line.long_reads))
        } else if (line.runtype == 'assembled') {
            return tuple(meta, [params.empty_r1], [params.empty_r2], file(line.assembled_fasta))
        } else {
            log.error("Invalid runtype ${line.runtype} found, please correct to continue. Expected: short-reads, long-reads, hybrid, or assembled")
            exit 1
        }
    } else {
        log.error("Sample name cannot be null: ${line}")
        exit 1
    }
}


