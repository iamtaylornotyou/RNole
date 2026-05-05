#!/usr/bin/env nextflow

// Parameters
params.input              = null
params.outdir             = 'results/unnamed_results'
params.ref_path           = 'ref'
params.profile            = 'singularity'
params.rnaseq_config      = 'config/pace_phoenix.config'
params.rnaseq_pipeline    = "${projectDir}/../nf-core-rnaseq/main.nf"
params.container_engine   = 'singularity'
params.orthofinder        = false
params.ortholog_file      = false
params.gene_names_from    = false
params.gene_field         = 'gene'


// A process definition
process SPLIT_SAMPLES {
    input:
    path my_file

    output:
    path '*.csv'

    script:
    """
    split_samplesheet.py ${my_file}
    """
}

process RUN_RNASEQ {
    publishDir "${params.outdir}/${ref_name}", mode: 'copy', saveAs: { filename -> filename.minus("results/") }
    publishDir "${params.outdir}/final_count_matrices", mode: 'copy', saveAs: { filename -> 
        filename == "results/salmon/salmon.merged.gene_counts.tsv" ? "${ref_name}_sample_counts.tsv" : null 
    }
    
    input:
    path my_file
    val rnaseq_config_path
    val ref_full_path
    val ref_name

    output:
    path "results/salmon/salmon.merged.gene_counts.tsv", emit: counts
    path "results/**", emit: rnaseq_results
    val ref_name, emit: ref_name

    script:
    """
    run_rnaseq.sh ${ref_name} "${ref_full_path}" "results/" ${params.container_engine} "${rnaseq_config_path}" "${params.rnaseq_pipeline}"
    """
}

process RUN_ORTHOFINDER {
    publishDir "${params.outdir}/orthofinder", mode: 'copy', saveAs: { filename -> filename.replaceAll("orthofinder_out/Results_[^/]+/", "") }
    
    input:
    path my_dir

    output:
    path "orthofinder_out/Results_*/Orthogroups/Orthogroups.tsv", emit: ortholog_file
    path "orthofinder_out/Results_*", emit: orthofinder_results
    path "orthofinder_out/Results_*/Comparative_Genomics_Statistics/Statistics_Overall.tsv", emit: orthofinder_stats

    script:
    """
    orthofinder -f ${my_dir} -o orthofinder_out
    """
}

process REPORT_ORTHOFINDER_STATS {
    debug true
    publishDir "${params.outdir}/orthofinder", mode: 'copy'

    input:
    path stats_file

    output:
    path "orthofinder_summary.txt"

    script:
    """
    #!/usr/bin/env python3
    
    stats = {}
    with open("${stats_file}") as f:
        for line in f:
            parts = line.strip().split("\t")
            if len(parts) == 2:
                stats[parts[0]] = parts[1]
    
    total_genes = stats.get("Number of genes", "N/A")
    total_orthogroups = stats.get("Number of orthogroups", "N/A")
    single_copy = stats.get("Number of single-copy orthogroups", "N/A")
    pct_sp_specific_genes = stats.get("Percentage of genes in species-specific orthogroups", "N/A")
    sp_specific_genes = stats.get("Number of genes in species-specific orthogroups", "N/A")

    pct_single_orthogroups = round(int(single_copy) / int(total_orthogroups) * 100, 1) if total_orthogroups != "N/A" and single_copy != "N/A" else "N/A"
    
    lines = [
        f"\\n{'='*50}",
        f"OrthoFinder Summary",
        f"{'='*50}",
        f"Total genes:                  {total_genes}",
        f"Total orthogroups:            {total_orthogroups}",
        f"Single-copy orthogroups:      {single_copy} ({pct_single_orthogroups}%)",
        f"Species-specific genes:       {sp_specific_genes} ({pct_sp_specific_genes}%)",
        f"{'='*50}\\n",
    ]
    
    summary = "\\n".join(lines)
    print(summary)
    
    with open("orthofinder_summary.txt", "w") as out:
        out.write(summary + "\\n")
    """
}

process FILTER_ONETOONE {
    publishDir "${params.outdir}/orthofinder", mode: 'copy'

    input:
    path my_file

    output:
    path '*.csv'

    script:
    """
    filter_onetoone.py ${my_file}
    """

}

process MERGE_COUNT_MATRICES {
    publishDir "${params.outdir}/final_count_matrices", mode: 'copy'

    input:
    path ortholog_file
    path count_files, stageAs: "?/counts.tsv"
    //path count_files, stageAs: "counts_??.tsv" // list of count matrices produced by salmon
    val ref_list

    output:
    path "ortholog_merged_counts.tsv"

    script:
    """
    merge_counts.py --orthologs ${ortholog_file} --counts ${count_files} --refs ${ref_list.join(' ')} --gene_names_from ${params.gene_names_from}
    """

}

process REMOVE_ISOFORMS {
    input:
    path proteome_dir

    output:
    path "${proteome_dir}/primary_transcripts"

    script:
    """
    for f in ${proteome_dir}/*.faa; do
        python ${projectDir}/bin/primary_transcript.py \$f
    done
    """
}

process RENAME_FASTA_HEADERS {

    input:
    path input_dir

    output:
    path "renamed/"

    script:
    """
    rename_fasta_headers.py ${input_dir} renamed/ ${params.gene_field}
    """
}

// The primary workflow block
workflow {
    // Create a channel from your input
    ch_samplesheet     = Channel.fromPath(params.input)
    rnaseq_config_path = "${projectDir}/../${params.rnaseq_config}"
    ref_full_path      = "${projectDir}/../${params.ref_path}"
    
    // Pass it to a process
    SPLIT_SAMPLES(ch_samplesheet)
    split_out = SPLIT_SAMPLES.out.flatten()
    ref_name  = split_out.map { file -> file.baseName }
    
    RUN_RNASEQ(split_out, rnaseq_config_path, ref_full_path,ref_name) 

    // run this block with either the output from above, or a file input by user, or not at all
    if (params.ortholog_file) {
        if (params.orthofinder) {
            // print a warning to user that we're skipping orthofinder becasue file was provided
            log.warn "Skipping OrthoFinder — using provided ortholog table: ${params.ortholog_file}"
        }
        ortholog_ch = Channel.fromPath(params.ortholog_file)
        MERGE_COUNT_MATRICES(ortholog_ch,RUN_RNASEQ.out.counts.collect(),RUN_RNASEQ.out.ref_name.collect())


    } else if (params.orthofinder) {
        proteomes_ch = Channel.fromPath(params.orthofinder, type: 'dir')
        REMOVE_ISOFORMS(proteomes_ch)
        RENAME_FASTA_HEADERS(REMOVE_ISOFORMS.out)
        RUN_ORTHOFINDER(RENAME_FASTA_HEADERS.out)
        REPORT_ORTHOFINDER_STATS(RUN_ORTHOFINDER.out.orthofinder_stats)
        REPORT_ORTHOFINDER_STATS.out.view {in.text}
        FILTER_ONETOONE(RUN_ORTHOFINDER.out.ortholog_file)
        MERGE_COUNT_MATRICES(FILTER_ONETOONE.out,RUN_RNASEQ.out.counts.collect(),RUN_RNASEQ.out.ref_name.collect())
    }

}

// an additional workflow block for testing
workflow TEST_ORTHOFINDER {
    proteomes_ch = Channel.fromPath(params.orthofinder, type: 'dir')
    REMOVE_ISOFORMS(proteomes_ch)
    RENAME_FASTA_HEADERS(REMOVE_ISOFORMS.out)
    RUN_ORTHOFINDER(RENAME_FASTA_HEADERS.out)
    REPORT_ORTHOFINDER_STATS(RUN_ORTHOFINDER.out.orthofinder_stats)
    REPORT_ORTHOFINDER_STATS.out.view {in.text}
    FILTER_ONETOONE(RUN_ORTHOFINDER.out.ortholog_file)
}