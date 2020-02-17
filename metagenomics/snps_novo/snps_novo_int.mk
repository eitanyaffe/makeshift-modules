units=snps_basic.mk
$(call _register_module,snps_novo,$(units),)

#####################################################################################################
# basic input/output
#####################################################################################################

# contig table
SNPS_INPUT_CONTIG_TABLE?=$(CONTIG_TABLE)

# gene table
SNPS_INPUT_GENE_TABLE?=$(GENE_TABLE)

# output
SNPS_DIR?=$(ASSEMBLY_DIR)/snps

#####################################################################################################
# run vari binary and merge results
#####################################################################################################

# all lib ids
SNPS_IDS?=i1 i2 i3

# base lib ids, shared by all sets
SNPS_BASE_IDS?=full_S1 full_S2 full_S3 full_S4 full_S5

# set label and ids
SNPS_SET_LABEL?=post
SNPS_SET_IDS?=full_S16 full_S17 full_S18 full_S19 full_S20 full_S21 full_S22 full_S23

SNPS_SET_DIR?=$(SNPS_DIR)/sets/$(SNPS_SET_LABEL)

# vari profiles are kept under this directory
SNPS_VARI_BASE_DIR?=$(BASEMAP_DIR)

# unified table
SNPS_UNIFIED_PREFIX?=$(SNPS_DIR)/unified

#####################################################################################################
# Classify positions
#####################################################################################################

# classify position
# segragating: if at least in one lib it is segrating (0.2 < M < 0.8)
# swept: if more than one major allele nt (>0.95)

# min total coverage of position at lib needed to classify
SNPS_MIN_TOTAL_COUNT?=10

# position considered fixed (i.e. diverged) if dominant alleles differ and freqs above threshold
SNPS_FIX_THRESHOLD?=0.95

# position considered poly (i.e. segregating) if dominant allele freq under threshold
SNPS_POLY_THRESHOLD?=0.8

# limit to classified positions
# segrating count: number of libs in which position was segragating
# fixed count: number of different nts that were fixed in any lib
SNPS_CLASSIFIED_TABLE?=$(SNPS_DIR)/snps_class_pos

#####################################################################################################
# associate positions with bins
#####################################################################################################

# add bin field to snp table
# limits to positions that have >1 fixated libs or >1 segrated libs
SNPS_BINS?=$(SNPS_DIR)/snps_bins

SNPS_SELECTED_PREFIX?=$(SNPS_DIR)/unified.selected

#####################################################################################################
# plotting
#####################################################################################################

SNPS_FDIR?=$(BASE_FDIR)/snps
