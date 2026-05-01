#!/usr/bin/env python3
# usage: ./filter_onetoone.py <ortholog file>

import sys
import pandas as pd 

filename = sys.argv[1]
df = pd.read_csv(filename, sep = '\t')

species_cols = df.columns[1:]
mask = True
for col in species_cols:
    mask = mask & (~df[col].str.contains(',', na=False)) & (df[col].notna())

one_to_one = df[mask]
one_to_one.to_csv('one_to_one_orthologs.csv', sep=',', index=False)