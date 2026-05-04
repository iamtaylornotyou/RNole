# RNole: RNA-seq Multi-Reference Pipeline
RNole is extended from nf-core/rnaseq to support mutliple reference genomes and ortholog mapping. RNole accepts a samplesheet (.csv) similar to nf-core/rnaseq, but with an additional "reference" column specifying the desired reference genome for each sample. RNole acts as a wrapper around nf-core/rnaseq, calling the pipeline as many times as there are unique references specified. Optionally, RNole will produce a merged, ortholog-matched count matrix with an OrthoFinder call, or a user-supplied ortholog file. 

## Table of contents

- [Installation](#installation)
- [Simple Usage](#simple-usage)
- [Test Case](#test-case)
- [Versioning](#versioning)
- [Output file](#output-files)

## Installation


## Simple Usage


## Test Case


### Data Availability
Raw FASTQ files, reference genomes, proteomes, and annotation files are not stored in this repository due to file size. 
Data is available via Dropbox: [link]

## Versioning
- Base pipline: nf-core/rnaseq v3.24.0
- NXF_VER=25.10.4

## Output files