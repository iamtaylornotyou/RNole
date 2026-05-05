#!/usr/bin/env python3
# usage: ./rename_fasta_headers.py <input_dir> <output_dir> [gene_field]

import re
import sys
import os

input_dir  = sys.argv[1]
output_dir = sys.argv[2]
gene_field = sys.argv[3] if len(sys.argv) > 3 else None

os.makedirs(output_dir, exist_ok=True)

for filename in os.listdir(input_dir):
    if filename.endswith('.faa'):
        input_file  = os.path.join(input_dir, filename)
        output_file = os.path.join(output_dir, filename)

        with open(input_file) as f_in, open(output_file, 'w') as f_out:
            for line in f_in:
                if line.startswith('>'):
                    # Case 1: already a clean gene name, just strip trailing ] (safety net)
                    if re.match(r'^>[A-Za-z0-9_\.]+\]?$', line.strip()):
                        f_out.write(line.strip().rstrip(']') + '\n')
                    else:
                        # Case 2: full header
                        if gene_field and gene_field != 'gene':
                            # strict - only use specified field, no fallback
                            match = re.search(rf'\[{gene_field}=([^\]]+)\]', line)
                        else:
                            # default fallback chain: gene= then locus_tag=
                            match = re.search(r'\[gene=([^\]]+)\]', line) or \
                                    re.search(r'\[locus_tag=([^\]]+)\]', line)
                        if match:
                            f_out.write(f'>{match.group(1)}\n')
                        else:
                            f_out.write(line)
                else:
                    f_out.write(line)