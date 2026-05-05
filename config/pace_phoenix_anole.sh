#!/bin/bash
#SBATCH --job-name=rnole_pipeline
#SBATCH --account=gts-jstroud36
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
eval "$(/storage/project/r-jstroud36-0/tcooper84/miniconda3/bin/conda shell.bash hook)"
conda activate rnole-hpc

# Run pipeline
cd /storage/project/r-jstroud36-0/tcooper84/RNole

NXF_VER=25.10.4 nextflow run pipeline/main.nf \
    --input samplesheets/anole_multi_ref_pace.csv \
    --outdir 'results/anole_pace' \
    --rnaseq_config 'config/pace_phoenix.config' \
    --orthofinder 'proteome_anole/' \
    --gene_names_from AnoCar \
    --with_indexing_file \
    -c 'config/pace_phoenix.config'
