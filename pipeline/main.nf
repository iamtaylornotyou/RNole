#!/usr/bin/env nextflow

// Parameters
params.input              = null
params.outdir             = 'results/unnamed_results'
params.ref_path           = 'ref'
params.profile            = 'singularity'
params.rnaseq_config      = 'config/pace_phoenix.config'
params.rnaseq_pipeline    = "${projectDir}/../nf-core-rnaseq/main.nf"
params.container_engine   = 'docker'

// A process definition
process SPLIT_SAMPLES {
    input:
    path my_file

    output:
    path '*.csv'

    script:
    """
    split_samplesheet.py ${my_file}
    """
}

process RUN_RNASEQ {
    input:
    path my_file
    val rnaseq_config_path
    val ref_full_path

    output:
    path "*/salmon/salmon.merged.gene_counts.tsv"

    script:
    """
    bn=\$(basename ${my_file} .csv)
    run_rnaseq.sh \${bn} "${ref_full_path}" ${params.outdir} ${params.container_engine} "${rnaseq_config_path}" "${params.rnaseq_pipeline}"
    """
}

// The workflow block
workflow {
    // Create a channel from your input
    ch_samplesheet     = Channel.fromPath(params.input)
    rnaseq_config_path = "${projectDir}/../${params.rnaseq_config}"
    ref_full_path      = "${projectDir}/../${params.ref_path}"
    
    // Pass it to a process
    SPLIT_SAMPLES(ch_samplesheet)
    RUN_RNASEQ(SPLIT_SAMPLES.out.flatten(), rnaseq_config_path, ref_full_path)
}