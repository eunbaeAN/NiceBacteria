def create_input_channel(runtype) {
    if (runtype == "multiples_samples") {
        return Channel.fromPath( params.samples )
            .splitCsv(header: true, strip: true, sep: '\t')
            .map { row -> process_fofn(row) }
    } else {
        def meta = [:]
        meta.id = params.sample
        meta.runtype = runtype
        if (runtype == "short-reads") {
            return Channel.fromList([tuple(meta, [file(params.R1)], [file(params.R2)], file(params.empty_long_reads))])
        } else if (runtype == "hybrid") {
            return Channel.fromList([tuple(meta, [file(params.R1)], [file(params.R2)], file(params.LR))])
        } else if (runtype == "assembled") {
            return Channel.fromList([tuple(meta, [params.empty_r1], [params.empty_r2], file(params.assembled_fasta))])
        } else if (runtype == "long-reads") { //"long-reads" 
            return Channel.fromList([tuple(meta, [params.empty_r1], [params.empty_r2], file(params.LR))])
        }
    }
}


def process_fofn(line) {
    /* Parse line and determine if long-reads or short-reads or hybrid or assembled */
    def meta = [:]
    meta.id = line.sample
    meta.runtype = line.runtype
    if (line.sample) {
        if (line.runtype == 'long-reads') {
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

