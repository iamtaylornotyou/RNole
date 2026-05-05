# RNole [![Nextflow](https://img.shields.io/badge/nextflow-%E2%89%A525.10.4-brightgreen)](https://www.nextflow.io/) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
RNole (**R**eference-aware **N**extflow-based **o**rtholog-**l**evel **e**xpression) is an extension of [nf-core/rnaseq](https://github.com/nf-core/rnaseq) that supports comparative transcriptomics across species. Like nf-core/rnaseq, RNole accepts a samplesheet (`.csv`) as input — with an additional `reference` column specifying the desired reference genome for each sample. Internally, RNole acts as a wrapper, invoking nf-core/rnaseq once per unique reference genome. Optionally, RNole will produce a merged, ortholog-matched count matrix using either an [OrthoFinder](https://github.com/OrthoFinder/OrthoFinder/tree/main) run, or a user-supplied ortholog file. 

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Test Case](#test-case)
- [Command-Line Options](#command-line-options)
- [Output Files](#output-files)
- [Versioning](#versioning)
- [System Requirements](#system-requirements)
- [Limitations](#limitations)
- [Acknowledgements](#acknowledgements)

## Installation

### Dependencies
- [Nextflow](https://www.nextflow.io/docs/latest/install.html) ≥ 25.10.4
- [conda](https://docs.conda.io/en/latest/miniconda.html)
- [Docker](https://docs.docker.com/get-docker/) (local) or [Singularity](https://docs.sylabs.io/guides/3.5/user-guide/introduction.html#) (HPC)

### Install via github
```
git clone https://github.com/iamtaylornotyou/RNole.git
cd RNole
```

## Usage
1. **First, prepare a samplesheet with your input data**

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

2. **Download reference data: FASTA, GTF annotation, and deposit in `ref/` directory**
    - reference data is expected in `ref/` but can be supplied via `--ref_path`
    - ALL files associated with a reference must have same naming convention (i.e., `AnoSag.fna.gz`, `AnoSag.gtf.gz`, `AnoSag.faa.gz`)
    - pre-built salmon indexing files can be supplied in the `ref/` directory, include the flag `--with_indexing_file`, files are expected to match reference convention (i.e., `AnoSag_salmon_index`)

3. **Download proteome files and store in a separate directory**
    - must use the `translated_cds.faa.gz` proteome, so gene naming conventions match count matrices
    - files must be unzipped

4. **Run the pipeline**
    ### Local machine (macOS 13.7.3)

    **Activate conda environment**
    ```bash
    conda env create -f config/rnole-local.yml
    conda activate rnole-local
    ```

    **Command line call**
    ```bash
    NXF_VER=25.10.4 nextflow run pipeline/main.nf \
        --input <path/to/samplesheet.csv> \
        --outdir <path/to/output/dir> \
        --container_engine 'docker' \
        --rnaseq_config 'config/local.config' \
        --orthofinder 'path/to/proteome/dir' \
        -c 'config/local.config' \
        -profile 'docker'
    ```

    ### HPC (Georgia Tech PACE)

    **Create conda environment**
    ```bash
    conda env create -f config/rnole-hpc.yml
    ```

    **Slurm Submission**: 
    ```sh
    #!/bin/bash
    #SBATCH --job-name=rnole_pipeline
    #SBATCH --account=YOUR_ACCOUNT_HERE
    #SBATCH --partition=cpu-large
    #SBATCH --qos=inferno
    #SBATCH --nodes=1
    #SBATCH --ntasks=1
    #SBATCH --cpus-per-task=24
    #SBATCH --mem=128G
    #SBATCH --time=24:00:00
    #SBATCH --output=logs/rnole_%j.out
    #SBATCH --error=logs/rnole_%j.err

    # Activate conda environment
    eval "$(conda shell.bash hook)"
    conda activate rnole-hpc

    # Run pipeline
    cd /PATH/TO/RNole

    NXF_VER=25.10.4 nextflow run pipeline/main.nf \
        --input PATH/TO/samplesheet.csv \
        --outdir <output_dir> \
        --container_engine 'singularity' \
        --rnaseq_config 'config/pace_phoenix.config' \
        --orthofinder 'PATH/TO/proteome/' \
        -c 'config/pace_phoenix.config'
    ```

## Test Case

### Data Availability
Raw FASTQ files, reference genomes, proteomes, and annotation files are not stored in this repository due to file size. Data is available via [Dropbox](https://www.dropbox.com/scl/fo/hlbu0mx9g30xrtqv96jxu/ALl8nR8Vlhk72odw69lmSuM?rlkey=ylql3zp2q2wpfpcz7nhgnyo0a&st=7d5hajyr&dl=1)

*Note: Dropbox link expires 8/2/2026. Please [open an issue](https://github.com/iamtaylornotyou/RNole/issues) to request access after this date.*
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
**files need to be unpacked into main directory before running**
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
**change samplesheet directories to local paths**
```

```
**activate local conda environment**
```bash
cd RNole
conda env create -f config/rnole-local.yml
```
**run pipeline**
```bash
NXF_VER=25.10.4 nextflow run pipeline/main.nf \
    --input samplesheets/yeast_multi_ref.csv \
    --outdir 'results/yeast_test' \
    --container_engine 'docker' \
    --rnaseq_config 'config/local.config' \
    --orthofinder 'proteome/' \
    --with_indexing_file \
    -c 'config/local.config' \
    -profile 'docker'
```

## Command-Line Options
Command-line options for RNole
| Parameter | Description | Default |
|-----------|-------------|---------|
| `--input` | Path to samplesheet `.csv` | `null` |
| `--outdir` | Path to output directory | `results/unnamed_results` |
| `--ref_path` | Path to reference data directory | `ref/` |
| `--profile` | Nextflow profile | `singularity` |
| `--rnaseq_config` | Path to nf-core/rnaseq config file | `config/pace_phoenix.config` |
| `--rnaseq_pipeline` | Path to nf-core/rnaseq `main.nf` | `projectDir/../nf-core-rnaseq/main.nf` |
| `--container_engine` | Container engine | `singularity` |
| `--orthofinder` | Path to proteome directory for OrthoFinder run | `false` |
| `--ortholog_file` | Path to user-supplied ortholog file | `false` |
| `--gene_names_from` | Species gene names to use in merged matrix | first species in samplesheet.csv |
| `--gene_field` | Select gene field in proteome `.faa` to match gene name in `.gtf` file. `gene` and `locus_tag` are common | `gene` |
| `--with_indexing_file` | If salmon indexing files are available, pipeline expects them in `/ref` | `false` |


## Output files

**```/final_count_matrices```**
- `ortholog_merged_counts.tsv` the primary output – merged, ortholog-matched count matrices
- `REF1_sample_counts.tsv` reference-specific count matrix for all quantified genes (unfiltered)
- `REF2...` count matrix files names come from `samplesheet.csv`

**```/orthofinder```**
- `one_to_one_orthologs.csv` one-to-one orthologs filtered from `Orthogroups/Orthogroups.tsv`
- `orthofinder_summary.txt` reports orthologue statistics in human-readable format
- `/orthofinder_out` default output files from OrthoFinder

**```/REF1...```**
- results from each nf-core/rnaseq call will populate in a reference-specific directory
- name comes from `samplesheet.csv`
- `/fastqc` 
- `/fq_lint`
- `/multiqc`
- `/pipeline_info`
- `/salmon`
- `/trimgalore`

## Versioning

- [nf-core/rnaseq](https://github.com/nf-core/rnaseq) version: `3.24.0`
- [Nextflow](https://www.nextflow.io/) version: `25.10.4`
- [OrthoFinder](https://github.com/OrthoFinder/OrthoFinder) version: `3.1.4`

## System Requirements

**Operating System**

RNole was designed to run on an HPC due to large memory requirements.
- RNole is verified to run on macOS 13.7.3 with small test files.

## Limitations

- all species must have a corresponding reference genome, annotation, and proteome file — partial references are not supported
- the pipeline assumes all samples in the samplesheet are RNA-seq data from species with available reference genomes
- the flexibility of nf-core/rnaseq is somewhat lost in this configuration, pseudoalignment with salmon is hardcoded
- ortholog merging is limited to 1:1 single-copy orthologs; many-to-many relationships and species-specific genes are excluded
- tested with nf-core/rnaseq v3.24.0 only; compatibility with other versions is not guaranteed

### Common Mistakes
- paths cannot contain spaces
- all reference files must have the same name: e.g., `AnoSag.fna.gz`, `AnoSag.gtf.gz`, `AnoSag.faa`, `AnoSag_salmon_index/`
- gene names in `.gtf` annotation file must match protein names in `.faa` file
- proteome files for OrthoFinder must be in `.faa` format; headers must contain a bracket-style field (e.g., `[gene=]`, `[locus_tag=]`, or a user-specified `--gene_field`) for gene name extraction



## Acknowledgements

This pipeline was produced as part of BIOL 8802 Reproducible Bioinformatics. Thank you to Dr. King Jordan, Shikhar Verma, and all other participants for feedback that improved this pipeline. 