#!/usr/bin/env python3
# usage: ./merge_counts.py --orthologs <file> --counts <file1> <file2> ... --refs <ref1> <ref2> ... --gene_names_from <ref>

#./pipeline/bin/merge_counts.py --orthologs <file> --counts <file1> <file2> ... --refs <ref1> <ref2> ... --gene_names_from <ref>

import sys
import argparse
import pandas as pd 

parser = argparse.ArgumentParser()
parser.add_argument('--orthologs',         required=True)
parser.add_argument('--counts', nargs='+', required=True)
parser.add_argument('--refs',   nargs='+', required=True)
parser.add_argument('--gene_names_from')
args = parser.parse_args()

gene_name       = args.gene_names_from
ref_list        = args.refs
ortho_filename  = args.orthologs
count_file_list = args.counts


# set gene names
if not gene_name:
    gene_name = ref_list[0]

# get the ortholog file
orthos = pd.read_csv(ortho_filename, sep = ',')
# after loading orthos
print("Orthogroup columns:", orthos.columns.tolist())
#print("Orthogroup sample values:", orthos.head())


# iterate through count matrices
for x in range(len(ref_list)):
    
    file = count_file_list[x]
    ref = ref_list[x]

    df = pd.read_csv(file, sep = '\t')
    df = df.drop(columns = ['gene_name'])
    df = df.rename(columns={'gene_id': ref})
    # after loading df
    print("Count matrix columns:", df.columns.tolist())
    print("Count matrix gene_id sample values:", df[ref].head())

    orthos = orthos.merge(df, on=ref, how='left')


other_refs = [r for r in ref_list if r != gene_name]
orthos = orthos.drop(columns = ['Orthogroup'] + other_refs)

orthos.to_csv('merged_counts.csv', sep = ',', index = False)