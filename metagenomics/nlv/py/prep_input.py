import numpy as np
import argparse, cPickle, glob, re, sys

# Read input arguments
parser = argparse.ArgumentParser()
parser.add_argument('--ifn', help='First line: number of sites, second line: number of samples')
parser.add_argument('--idir', help='Input directory')
parser.add_argument('--ofn', help='Output file (.cPickle)')
args = parser.parse_args()

fo = open(args.ifn)
n_sites = int(fo.readline())
n_samples = int(fo.readline())

print ('n_samples=%d,n_sites=%d' %(n_samples,n_sites))
result = np.zeros([n_samples, n_sites, 4])

nts = ['A', 'C', 'G', 'T']
for nt_index in range(4):
    for line in open('%s/%s' %(args.idir, nts[nt_index])):
        line = line.rstrip().split()
        if line[0] == "index":
            continue
        site_index = int(line[0])-1
        for sample_index in range(n_samples):
            count = int(line[3+sample_index])
#            print ('sample_index=%d,site_index=%d,nt_index=%d,count=%d' %(sample_index,site_index,nt_index,count))
            result[sample_index,site_index,nt_index] = count
#        if site_index == 4:
#            exit()

# Write numpy arrays to file
cPickle.dump(result, open(args.ofn, 'w'))
