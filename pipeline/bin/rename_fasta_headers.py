#!/usr/bin/env python3
# usage: ./rename_fasta_headers.py <input_dir> <output_dir>

import re
import sys
import os

input_dir  = sys.argv[1]
output_dir = sys.argv[2]

os.makedirs(output_dir, exist_ok=True)

for filename in os.listdir(input_dir):
    if filename.endswith('.faa'):
        input_file  = os.path.join(input_dir, filename)
        output_file = os.path.join(output_dir, filename)
        
        with open(input_file) as f_in, open(output_file, 'w') as f_out:
            for line in f_in:
                if line.startswith('>'):
                    match = re.search(r'\[locus_tag=([^\]]+)\]', line)
                    if match:
                        f_out.write(f'>{match.group(1)}\n')
                    else:
                        f_out.write(line)
                else:
                    f_out.write(line)