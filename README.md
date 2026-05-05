# RNole: RNA-seq Multi-Reference Pipeline
RNole is an extension of [nf-core/rnaseq](https://github.com/nf-core/rnaseq) that supports multiple reference genomes and ortholog mapping across species. Like nf-core/rnaseq, RNole accepts a samplesheet (`.csv`) as input — with an additional `reference` column specifying the desired reference genome for each sample. Internally, RNole acts as a wrapper, invoking nf-core/rnaseq, once per unique reference genome. Optionally, RNole will produce a merged, ortholog-matched count matrix using either an [OrthoFinder](https://github.com/OrthoFinder/OrthoFinder/tree/main) run, or a user-supplied ortholog file. 

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Test Case](#test-case)
- [Output Files](#output-files)
- [Versioning](#versioning)
- [System Requirements](#system-requirements)
- [Acknowledgements](#acknowledgements)

## Installation
**Install via github**

RNole is currently hosted on github. 
```
git clone https://github.com/iamtaylornotyou/RNole.git
cd RNole
```

## Usage
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

2. Download reference data: FASTA, GTF annotation, and deposit in `ref/` directory
    - reference data is expected in `ref/` but can be supplied via `--ref_path`
    - ALL files associated with a reference must have same naming convention (i.e., AnoSag.fna.gz, AnoSag.gtf.gz, AnoSag.faa.gz)

3. Download proteome files and store in a separate directory
    - must use the `translated_cds.faa.gz` proteome, so gene naming conventions match count matrices
    - files must be unzipped

4. Run the pipeline 
    ### Local

    **Activate conda environment**
```
    conda env create -f config/rnole-local.yml
    conda activate rnole-local
```

*   *Command line call**: Local machine (macOS 13.7.3)
```
    NXF_VER=25.10.4 nextflow run pipeline/main.nf \
        --input <path/to/samplesheet.csv> \
        --outdir <path/to/output/dir> \
        --container_engine 'docker' \
        --rnaseq_config 'config/local.config' \
        --orthofinder 'path/to/proteome/dir' \
        -c 'config/local.config' \
        -profile 'docker'
```

    ### HPC

    **Create conda environment**
```
    conda env create -f config/rnole-hpc.yml
```

    **Slurm Submission**: Georgia Tech PACE
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
    eval "$(PATH/TO/conda shell.bash hook)"
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
*files need to be unpacked into main directory before running*
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

INCLUDE QUICKSTART RUN INFO HERE


## Output files

**```/final_count_matrices```**
- `merged_counts.csv` the primary output – merged, ortholog-matched count matrices

**```/orthofinder```**
- `one_to_one_orthologs.csv` one-to-one orthologs filtered from Orthogroups/Orthogroups.tsv
- `/orthofinder_out` default output files from OrthoFinder

**```/REF_1...```**
- results from each nf-core/rnaseq call will populate in a reference-specific directory
- `/fastqc` 
- `/fq_lint`
- `/multiqc`
- `/pipeline_info`
- `/salmon`
- `/trimgalore`

## Versioning

- Base pipeline: nf-core/rnaseq v3.24.0
- Nextflow version: 25.10.4
- OrthoFinder version: 

## System Requirements

**Operating System**

RNole was designed to run on an HPC due to large memory requirements.
- RNole is verified to run on macOS 13.7.3 with small test files.

## Acknowledgements

This pipeline was produced as part of BIOL 8802 Reproducible Bioinformatics. Thank you to Dr. King Jordan, Shikhar Verma, and all other participants for feedback that improved this pipeline. 