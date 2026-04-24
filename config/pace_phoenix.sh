#!/bin/bash
#SBATCH --job-name=rnole_pipeline
#SBATCH --account=gts-jstroud36
#SBATCH --partition=cpu-medium
#SBATCH --qos=inferno
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=96G
#SBATCH --time=24:00:00
#SBATCH --output=logs/rnole_%j.out
#SBATCH --error=logs/rnole_%j.err

# Activate conda environment
eval "$(/storage/project/r-jstroud36-0/tcooper84/miniconda3/bin/conda shell.bash hook)"
conda activate rnole-hpc2

# Run pipeline
cd /storage/project/r-jstroud36-0/tcooper84/RNole

nextflow run pipeline/main.nf \
    --input samplesheets/test_1k.csv \
    --fasta ref/AnoSag.fna.gz \
    --gtf ref/AnoSag.gtf.gz \
    --outdir results/test_1k_salmon \
    --pseudo_aligner salmon \
    --skip_alignment \
    -profile singularity \
    -c config/pace_phoenix.config
