#!/bin/bash

# variables
bn=$1
ref_path=$2
outdir=$3
profile=$4
config=$5
rnaseq_pipeline=$6

# nf-core/rnaseq call
nextflow run "${rnaseq_pipeline}" \
    --input "${bn}.csv" \
    --fasta "${ref_path}/${bn}.fna.gz" \
    --gtf "${ref_path}/${bn}.gtf.gz" \
    --outdir "${outdir}" \
    --pseudo_aligner salmon \
    --skip_alignment \
    --salmon_index "${ref_path}/${bn}_salmon_index" \
    -profile "${profile}" \
    -c "${config}"