#!/usr/bin/env python3

import sys
import yaml
import os
import parasail
import io
import re
import sys
from Bio import SeqIO
import gzip
import csv

gap_open = 10
gap_extend = 1

param_file_path = sys.argv[1]
fastq_path = sys.argv[2]

def parasail_to_sam_cigar( parasail_cigar ):
    sam_cigar1 = re.sub( 'X|=', 'M', parasail_cigar )
    sam_cigar2 = re.sub( 'I', 'd', sam_cigar1 )
    sam_cigar3 = re.sub( 'D', 'I', sam_cigar2 )
    sam_cigar4 = re.sub( 'd', 'D', sam_cigar3 )
    return sam_cigar4

def global_align( seq, ref_profile ):
    result = parasail.nw_trace_scan_profile_16(ref_profile, seq, gap_open, gap_extend )
    return result

def load_params( info_file ):
    with open(info_file,'r') as stream:
        return yaml.safe_load(stream)

params = load_params( param_file_path )

def load_sequence( fasta ):
    return next(SeqIO.parse(fasta,'fasta'))


wt = load_sequence( params['wt'] )
reference = load_sequence( params['reference'] )

wt_profile = parasail.profile_create_16(str(wt.seq), parasail.nuc44 )
reference_profile = parasail.profile_create_16(str(reference.seq), parasail.nuc44 )

result = global_align(str(reference.seq), wt_profile)

fieldnames = [ 
    'readname', 
    'wt_vs_read.score',
    'donor_vs_read.score',
    'wt_vs_read.align_wt',
    'wt_vs_read.align_read',
    'donor_vs_read.align_donor',
    'donor_vs_read.align_read'
]

with gzip.open('out.csv.gz','wt',newline='') as out_file:
    writer = csv.DictWriter(out_file, fieldnames=fieldnames)
    writer.writeheader()
    with gzip.open(params['fastq']['merged'], 'rt') as handle1:
        for record1 in SeqIO.parse(handle1, 'fastq'):
            align_wt = global_align( str(record1.seq), wt_profile )
            align_ref = global_align( str(record1.seq), reference_profile )
            row_data = { 
                'readname': record1.id, 
                'wt_vs_read.score': align_wt.score, 
                'donor_vs_read.score': align_ref.score,
                'wt_vs_read.align_wt': align_wt.traceback.query,
                'wt_vs_read.align_read': align_wt.traceback.ref,
                'donor_vs_read.align_donor': align_ref.traceback.query,
                'donor_vs_read.align_read': align_ref.traceback.ref
            }
            writer.writerow(row_data)
