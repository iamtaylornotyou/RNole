#!/bin/bash

# variables
bn=$1
ref_path=$2
outdir=$3
profile=$4
config=$5
rnaseq_pipeline=$6
with_indexing_file=$7

CONDA_NO_PLUGINS=true
export CONDA_NO_PLUGINS

if [[ $with_indexing_file == true ]]; then
    # nf-core/rnaseq call
    NXF_CONDA_ENABLED=false nextflow run "${rnaseq_pipeline}" \
        --input "${bn}.csv" \
        --fasta "${ref_path}/${bn}.fna.gz" \
        --gtf "${ref_path}/${bn}.gtf.gz" \
        --outdir "${outdir}" \
        --pseudo_aligner salmon \
        --skip_alignment \
        --salmon_index "${ref_path}/${bn}_salmon_index" \
        -profile "${profile}" \
        -c "${config}"
else
    # nf-core/rnaseq call
    NXF_CONDA_ENABLED=false nextflow run "${rnaseq_pipeline}" \
        --input "${bn}.csv" \
        --fasta "${ref_path}/${bn}.fna.gz" \
        --gtf "${ref_path}/${bn}.gtf.gz" \
        --outdir "${outdir}" \
        --pseudo_aligner salmon \
        --skip_alignment \
        -profile "${profile}" \
        -c "${config}"
fi