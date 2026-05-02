#!/usr/bin/env nextflow

// Parameters
params.input              = null
params.outdir             = 'results/unnamed_results'
params.ref_path           = 'ref'
params.profile            = 'singularity'
params.rnaseq_config      = 'config/pace_phoenix.config'
params.rnaseq_pipeline    = "${projectDir}/../nf-core-rnaseq/main.nf"
params.container_engine   = 'docker'
params.orthofinder        = false
params.ortholog_file      = false


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
    publishDir "${params.outdir}/${ref_name}", mode: 'copy', saveAs: { filename -> filename.minus("results/") }
    
    input:
    path my_file
    val rnaseq_config_path
    val ref_full_path
    val ref_name

    output:
    path "**/salmon.merged.gene_counts.tsv", emit: counts
    path "results/**", emit: rnaseq_results

    script:
    """
    run_rnaseq.sh ${ref_name} "${ref_full_path}" "results/" ${params.container_engine} "${rnaseq_config_path}" "${params.rnaseq_pipeline}"
    """
}

process RUN_ORTHOFINDER {
    publishDir "${params.outdir}/orthofinder", mode: 'copy', saveAs: { filename -> filename.replaceAll("orthofinder_out/Results_[^/]+/", "") }
    
    input:
    path my_dir

    output:
    path "orthofinder_out/Results_*/Orthogroups/Orthogroups.tsv", emit: ortholog_file
    path "orthofinder_out/Results_*", emit: orthofinder_results

    script:
    """
    orthofinder -f ${my_dir} -o orthofinder_out
    """
}

process FILTER_ONETOONE {
    publishDir "${params.outdir}/orthofinder", mode: 'copy'

    input:
    path my_file

    output:
    path '*.csv'

    script:
    """
    filter_onetoone.py ${my_file}
    """

}

process MERGE_COUNT_MATRICES {

}

// The workflow block
workflow {
    // Create a channel from your input
    ch_samplesheet     = Channel.fromPath(params.input)
    rnaseq_config_path = "${projectDir}/../${params.rnaseq_config}"
    ref_full_path      = "${projectDir}/../${params.ref_path}"
    
    // Pass it to a process
    SPLIT_SAMPLES(ch_samplesheet)
    split_out = SPLIT_SAMPLES.out.flatten()
    ref_name  = split_out.map { file -> file.baseName }
    
    RUN_RNASEQ(split_out, rnaseq_config_path, ref_full_path,ref_name) 

    // run this block with either the output from above, or a file input by user, or not at all
    if (params.ortholog_file) {
        log.warn "Skipping OrthoFinder — using provided ortholog table: ${params.ortholog_file}"
        ortholog_ch = Channel.fromPath(params.ortholog_file)
        MERGE_COUNT_MATRICES(ortholog_ch,RUN_RNASEQ.out.counts.collect())
        // print a warning to user that we're skipping orthofinder becasue file was provided


    } else if (params.orthofinder) {
        proteomes_ch = Channel.fromPath(params.orthofinder, type: 'dir')
        RUN_ORTHOFINDER(proteomes_ch)
        FILTER_ONETOONE(RUN_ORTHOFINDER.out.ortholog_file)
        MERGE_COUNT_MATRICES(FILTER_ONETOONE.out,RUN_RNASEQ.out.counts.collect())
    }

}