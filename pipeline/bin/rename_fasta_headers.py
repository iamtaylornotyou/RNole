#!/usr/bin/env python3
# usage: ./rename_fasta_headers.py <input_dir> <output_dir> <gene_field>

import re
import sys
import os
from collections import defaultdict

input_dir  = sys.argv[1]
output_dir = sys.argv[2]
gene_field = sys.argv[3]

os.makedirs(output_dir, exist_ok=True)

for filename in os.listdir(input_dir):
    if filename.endswith('.faa'):
        input_file  = os.path.join(input_dir, filename)
        output_file = os.path.join(output_dir, filename)
        
        seen = defaultdict(int)

        with open(input_file) as f_in, open(output_file, 'w') as f_out:
            for line in f_in:
                if line.startswith('>'):
                    match = re.search(rf'\[{gene_field}=([^\]]+)\]', line)
                    if match:
                        locus_tag = match.group(1)
                        seen[locus_tag] += 1
                        if seen[locus_tag] > 1:
                            f_out.write(f'>{locus_tag}_isoform{seen[locus_tag]}\n')
                        else:
                            f_out.write(f'>{locus_tag}\n')
                    else:
                        f_out.write(line)
                else:
                    f_out.write(line)