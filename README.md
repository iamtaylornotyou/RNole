# RNole: RNA-seq Multi-Reference Pipeline
RNole is an extension of [nf-core/rnaseq](https://github.com/nf-core/rnaseq) that supports mutliple reference genomes and ortholog mapping across species. Like nf-core/rnaseq, RNole accepts a samplesheet (`.csv`) as input — with an additional `reference` column specifying the desired reference genome for each sample. Internally, RNole acts as a wrapper, invoking nf-core/rnaseq, once per unique reference genome. Optionally, RNole will produce a merged, ortholog-matched count matrix using either an [OrthoFinder](https://github.com/OrthoFinder/OrthoFinder/tree/main) run, or a user-supplied ortholog file. 

## Table of Contents

- [Installation](#installation)
- [Simple Usage](#simple-usage)
- [Test Case](#test-case)
- [Versioning](#versioning)
- [Output Files](#output-files)
- [System Requirements](#system-requirements)
- [Acknowledgements](#acknowledgements)

## Installation
**Install via github**
```

```

## Simple Usage
1. First, prepare a samplesheet with your input data

**Samplesheet Format**
| sample | fastq_1 | fastq_2 | strandedness | reference |
|---------|---------|---------|---------|---------|
| sample_id | exact/path/to/R1 | exact/path/to/R2 | one of: `forward`,`reverse`,`unstranded`,`auto` | ref_name |
| sample IDs must be unique from reference names | path cannot contain spaces | path cannot contain spaces | strandedness refers to the library preparation and will be automatically inferred if set to `auto` | all files associated with the reference must be named with same convention |

**samplesheet.csv**:
```csv
sample,fastq_1,fastq_2,strandedness,reference
SagCer_01,/Users/iamtaylornotyou/Desktop/RNole/fastq/SacCer_R1_1M.fastq,/Users/iamtaylornotyou/Desktop/RNole/fastq/SacCer_R2_1M.fastq,unstranded,SagCer
SchPom_01,/Users/iamtaylornotyou/Desktop/RNole/fastq/SchPom_R1_1M.fastq,/Users/iamtaylornotyou/Desktop/RNole/fastq/SchPom_R2_1M.fastq,unstranded,SchPom
```

2. Download reference data: FASTA, GTF annotation, and deposit in ref/ directory

3. Download proteome files and store in a separate directory

4. 

**Command line call**

Local machine (macOS 13.7.3)
```
NXF_VER=25.10.4 nextflow run pipeline/main.nf \
    --input <path/to/samplesheet.csv> \
    --outdir <path/to/output/dir> \
    --container_engine 'docker' \
    --rnaseq_config 'config/local.config' \
    --orthofinder 'path/to/proteome/dir' \
    --gene_names_from <ref> \
    -c 'config/local.config' \
    -profile 'docker'
```

## Test Case


### Data Availability
Raw FASTQ files, reference genomes, proteomes, and annotation files are not stored in this repository due to file size. Data is available via [Dropbox](https://www.dropbox.com/scl/fo/hlbu0mx9g30xrtqv96jxu/ALl8nR8Vlhk72odw69lmSuM?rlkey=ylql3zp2q2wpfpcz7nhgnyo0a&st=7d5hajyr&dl=1)

*Note: Dropbox link expires 8/2/2026. Contact _____ if access is needed after this date.*
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