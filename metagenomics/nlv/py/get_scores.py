import sys, argparse, cPickle, numpy

# Read input arguments
parser = argparse.ArgumentParser()
parser.add_argument('--module_dir', help='StrainFinder module dir')
parser.add_argument('--idir', help='Input directory')
parser.add_argument('--maxN', help='Scan runs executed between 2 and maxN runs of StrainFinder')
parser.add_argument('--ofn', help='Output file with optimal number of strains')
args = parser.parse_args()

sys.path.insert(0, args.module_dir)
from StrainFinder import *

# Get filenames of EM objects
fns = ['%s/N%d/em.cpickle' %(args.idir, N) for N in range(2,1+int(args.maxN))]

# Load EM objects
ems = [cPickle.load(open(fn, 'rb')) for fn in fns]

# Get the best BIC in each EM object
bics = [em.select_best_estimates(1)[0].bic for em in ems]
aics = [em.select_best_estimates(1)[0].aic for em in ems]
fo = open(args.ofn, 'w')
fo.write("N\tBIC\tAIC\n")
for N in range(2,1+int(args.maxN)):
    fo.write("%d\t%f\t%f\n" %(N, bics[N-2], aics[N-2]))
fo.close()

