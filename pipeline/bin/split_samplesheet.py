#!/usr/bin/env python3
# usage: ./split_samplesheet.py <samplesheet file>

import sys
import pandas as pd

filename = sys.argv[1]
df = pd.read_csv(filename, sep = ',')

references = df['reference'].unique()

for ref in references:
    
    output_file = ref.split('/')[-1]
    
    new_samplesheet = df[df['reference'] == ref].drop(columns=['reference'])

    new_samplesheet.to_csv(output_file+'.csv', sep = ',', index = False)


