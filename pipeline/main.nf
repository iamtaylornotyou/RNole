#!/usr/bin/env nextflow

// Parameters
params.samplesheet = null
params.outdir      = 'results/unnamed_results'
params.ref_path    = 'ref'
params.profile     = 'singularity'
params.config      = 'config/pace_phoenix.config'

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

    output:
    path "*/star_salmon/salmon.merged.gene_counts.tsv"

    script:
    """
    bn=$(basename ${my_file} .csv)
    nextflow run nf-core-rnaseq/main.nf \
        --input ${my_file} \
        --fasta ${params.ref_path}/${bn}.fna.gz \
        --gtf ${params.ref_path}/${bn}.gtf.gz \
        --outdir ${params.outdir}/${bn} \
        --pseudo_aligner salmon \
        --skip_alignment \
        --salmon_index ${params.ref_path}/${bn}_salmon_index \
        -profile ${params.profile} \
        -c ${params.config}
    """
}

// The workflow block
workflow {
    // Create a channel from your input
    ch_samplesheet = Channel.fromPath(params.samplesheet)
    
    // Pass it to a process
    SPLIT_SAMPLES(ch_samplesheet)
    RUN_RNASEQ(SPLIT_SAMPLES.out)
}