# RNole: RNA-seq Multi-Reference Pipeline
RNole is an extension of nf-core/rnaseq that supports mutliple reference genomes and ortholog mapping across species. Like nf-core/rnaseq, RNole accepts a samplesheet (`.csv`) as input — with an additional `reference` column specifying the desired reference genome for each sample. Internally, RNole acts as a wrapper, invoking nf-core/rnaseq, once per unique reference genome. Optionally, RNole will produce a merged, ortholog-matched count matrix using either an OrthoFinder run, or a user-supplied ortholog file. 

## Table of Contents

- [Installation](#installation)
- [Simple Usage](#simple-usage)
- [Test Case](#test-case)
- [Versioning](#versioning)
- [Output Files](#output-files)
- [System Requirements](#system-requirements)
- [Acknowledgements](#acknowledgements)

## Installation


## Simple Usage


## Test Case


### Data Availability
Raw FASTQ files, reference genomes, proteomes, and annotation files are not stored in this repository due to file size. Data is available via [Dropbox](https://www.dropbox.com/scl/fo/hlbu0mx9g30xrtqv96jxu/ALl8nR8Vlhk72odw69lmSuM?rlkey=guy52dej43ouwr3qdg006xmhc&st=y90b1e7p&dl=0):
```
test_data/
├── fastq
│   ├── SacCer_R1_1M.fastq
│   ├── SacCer_R2_1M.fastq
│   ├── SchPom_R1_1M.fastq
│   └── SchPom_R2_1M.fastq
├── proteome
│   ├── SagCer.faa
│   └── SchPom.faa
└── ref
    ├── SagCer.fna.gz
    ├── SagCer.gtf.gz
    ├── SagCer_salmon_index
    ├── SchPom.fna.gz
    ├── SchPom.gtf.gz
    └── SchPom_salmon_index
```
files need to be unpacked into main directory before running
```
RNole/
├── README.md
├── config
├── dockerfiles
├── fastq
├── logs
├── nf-core-rnaseq
├── pipeline
├── proteome
├── ref
├── results
├── samplesheets
└── work
```

## Versioning
- Base pipline: nf-core/rnaseq v3.24.0
- NXF_VER=25.10.4

## Output files

**```/final_count_matrices```**
- `merged_counts.csv` the primary output – merged, ortholog-matched count matrices

**```/orthofinder```**
- `one_to_one_orthologs.csv` one-to-one orthologs filtered from Orthogroups/Orthogroups.tsv
- `/orthofinder_out` default output files from OrthoFinder

**```/pipeline_info```**
- THIS MIGHT NOT BE HERE ANYMORE

**```/REF_1...```**
- results from each nf-core/rnaseq call will populate in a reference-specific directory
- `/fastqc` 
- `/fq_lint`
- `/multiqc`
- `/pipeline_info`
- `/salmon`
- `/trimgalore`

## System Requirements
**Operating System**
RNole was designed to run on an HPC due to large memory requirments.
- RNole is verified to run on macOS 13.7.3 with small test files.

**Dependencies**


## Acknowledgements