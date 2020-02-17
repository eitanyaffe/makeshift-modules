units=snps_varisum.mk snps_basic.mk
$(call _register_module,nlv,$(units),)

#####################################################################################################
# basic input/output
#####################################################################################################

# contig table
SNPS_INPUT_CONTIG_TABLE?=$(CONTIG_TABLE)

# gene table
SNPS_INPUT_GENE_TABLE?=$(GENE_TABLE)

# sample table
SNPS_LIB_TABLE?=$(SUBJECT_SAMPLE_DEFS)

# output
SNPS_DIR?=$(ASSEMBLY_DIR)/snps

SNPS_FDIR?=$(BASE_FDIR)/snps

#####################################################################################################
# delegate to vari module to generate snp profiles per library
#####################################################################################################

# vari profiles are kept under this directory
SNPS_VARI_BASE_DIR?=$(BASEMAP_DIR)

# all lib ids
SNPS_IDS?=i1 i2 i3

#####################################################################################################
# combine libs into lib set
#####################################################################################################

SNPS_SET_BASEDIR?=$(SNPS_DIR)/sets_n$(SNPS_SET_COUNT)

# lib set definitions
SNPS_SET_DEFS?=$(SNPS_SET_BASEDIR)/table

# number of libs in set
SNPS_SET_COUNT?=4

# avoid combining samples with different keys in the same set
SNPS_RESPECT_KEYS?=T

# set label and ids
SNPS_SET_LABEL?=b1
SNPS_SET_IDS?=M3189 M3190 M3191
SNPS_SET_DIR?=$(SNPS_SET_BASEDIR)/sets/$(SNPS_SET_LABEL)

# combine libs: snps
SNPS_SET_TABLE?=$(SNPS_SET_DIR)/snp.set

# combine libs: coverage
SNPS_COVER_SET_DIR?=$(SNPS_SET_DIR)/cov.set

#####################################################################################################
# compare two lib sets
#####################################################################################################

SNPS_SET_LABEL1?=b1
SNPS_SET_LABEL2?=b2

SNPS_SET_TABLE1?=$(call reval,SNPS_SET_TABLE,SNPS_SET_LABEL=$(SNPS_SET_LABEL1))
SNPS_SET_TABLE2?=$(call reval,SNPS_SET_TABLE,SNPS_SET_LABEL=$(SNPS_SET_LABEL2))

SNPS_COVER_SET_DIR1?=$(call reval,SNPS_COVER_SET_DIR,SNPS_SET_LABEL=$(SNPS_SET_LABEL1))
SNPS_COVER_SET_DIR2?=$(call reval,SNPS_COVER_SET_DIR,SNPS_SET_LABEL=$(SNPS_SET_LABEL2))

# single merged snp table
SNPS_SETCMP_DIR?=$(SNPS_DIR)/set_compare/$(SNPS_SET_LABEL1)_$(SNPS_SET_LABEL2)
SNPS_MERGE_TABLE?=$(SNPS_SETCMP_DIR)/snps_merged

#####################################################################################################
# classify position parameters
#####################################################################################################

# min total coverage (both conditions) to determine that nt is fixed (divergence)
SNPS_MIN_FIX_COUNT?=3

# position considered fixed (i.e. diverged) if dominant alleles differ and freqs above threshold
SNPS_FIX_THRESHOLD?=0.95

# min total coverage to determine that nt is polymorphic (segregating)
SNPS_MIN_POLY_COUNT?=10

# position considered poly (i.e. segregating) if dominant allele freq under threshold
SNPS_POLY_THRESHOLD?=0.8

# limit to classified positions (live.base / live.set / fixed)
SNPS_CLASSIFIED_TABLE?=$(SNPS_SETCMP_DIR)/snps_class
