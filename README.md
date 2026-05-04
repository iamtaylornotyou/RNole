# RNole: RNA-seq Multi-Reference Pipeline
RNole is an extension of nf-core/rnaseq that supports mutliple reference genomes and ortholog mapping across species. Like nf-core/rnaseq, RNole accepts a samplesheet (`.csv`) as input — with an additional `reference` column specifying the desired reference genome for each sample. Internally, RNole acts as a wrapper, invoking nf-core/rnaseq, once per unique reference genome. Optionally, RNole will produce a merged, ortholog-matched count matrix using either an OrthoFinder run, or a user-supplied ortholog file. 

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
