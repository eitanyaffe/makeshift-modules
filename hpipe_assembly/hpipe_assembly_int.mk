#####################################################################################################
# register module
#####################################################################################################

units:=assembly.mk
$(call _register_module,assembly,$(units),global preproc)

#####################################################################################################
# general parameters
#####################################################################################################

ASSEMBLER_FN?=megahit

ASSEMBLY_ID?=pre_big
ASSEMBLY_BASEDIR?=$(OUTDIR)/assembly/$(ASSEMBLY_ID)

ASSEMBLY_DIR?=$(ASSEMBLY_BASEDIR)/fold_$(RARIFY_FOLD)
ASSEMBLY_TMP_DIR?=$(TMPDIR)/assembly/$(ASSEMBLY_ID)_$(RARIFY_FOLD)

# input is a set of directories, by default we use a set of assembly libs
ASSEMBLY_INPUT_DIRS?=$(addprefix $(OUTDIR)/libs_final/,$(ASSEMBLY_LIB_IDS))

# use only files which match pattern
ASSEMBLY_INPUT_NAME_PATTERN?=R*

ASSEMBLY_INPUT_FILES?=$(wildcard $(ASSEMBLY_INPUT_DIRS)/$(ASSEMBLY_INPUT_NAME_PATTERN))

# output contig fasta file
RARIFY_FOLD?=0
FULL_CONTIG_FILE?=$(ASSEMBLY_DIR)/contigs
FULL_CONTIG_TABLE?=$(ASSEMBLY_DIR)/contig_table

# note: only complete bins are reported
CONTIG_GC_BINSIZE?=1000
CONTIG_GC_TABLE?=$(ASSEMBLY_DIR)/contig.gc
CONTIG_GC_BINNED?=$(ASSEMBLY_DIR)/contig.gc.bins

# select long contigs
ASSEMBLY_MIN_LEN?=1000
CONTIG_FILE?=$(ASSEMBLY_DIR)/long_contigs
CONTIG_TABLE?=$(ASSEMBLY_DIR)/long_contig_table

# to assess required depth we optionally assemble on rarified read sets
# factors are fold rarification, in log2 scale
RARIFY_FOLDS?=5 4 3 2 1 0
RARIFY_TABLE?=$(ASSEMBLY_BASEDIR)/rarify_table

#####################################################################################################
# megahit parameters
#####################################################################################################

MEGAHIT_MEMORY_CAP?=0.5

MEGAHIT_MIN_CONTIG_LENGTH?=300

ASSEMBLY_MIN_KMER?=21
ASSEMBLY_MAX_KMER?=141
ASSEMBLY_KMER_STEP?=12

MEGAHIT_MERGE_L?=20
MEGAHIT_MERGE_S?=0.95

# optional megahit parameters:
# --no-mercy: do not add mercy kmers
# --no-bubble: do not merge bubbles
# --no-local: disable local assembly
MEGA_HIT_PARAMS?=

#####################################################################################################
# minia parameters
#####################################################################################################

# in Mb
MINIA_MAX_MEMORY?=200000

# kmer size
MINIA_KSIZE?=101

# discard kmers with coverage below this value
MINIA_MIN_COVERAGE?=2

# T: generate unitigs
# F: generate contigs
MINIA_UNITIG?=F
