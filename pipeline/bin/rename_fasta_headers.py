#!/usr/bin/env python3
# usage: ./rename_fasta_headers.py <input.faa> <output.faa>

import re
import sys

input_file  = sys.argv[1]
output_file = sys.argv[2]

with open(input_file) as f_in, open(output_file, 'w') as f_out:
    for line in f_in:
        if line.startswith('>'):
            match = re.search(r'\[locus_tag=([^\]]+)\]', line)
            if match:
                f_out.write(f'>{match.group(1)}\n')
            else:
                f_out.write(line)  # keep original if no locus_tag found
        else:
            f_out.write(line)