units=snps_basic.mk snps_genes.mk snps_bins.mk snps_trajectories.mk
$(call _register_module,snps,$(units),)

#####################################################################################################
# basic input/output
#####################################################################################################

# contig table
SNPS_INPUT_CONTIG_TABLE?=$(CONTIG_TABLE)

# gene table
SNPS_INPUT_GENE_TABLE?=$(GENE_TABLE)

# output
SNPS_DIR?=$(ASSEMBLY_DIR)/snps

SNPS_FDIR?=$(BASE_FDIR)/snps

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

# merge libs: snps
SNPS_BASE_TABLE?=$(SNPS_DIR)/snps.base
SNPS_SET_TABLE?=$(SNPS_SET_DIR)/snp.set

# merge libs: coverage
SNPS_COVER_BASE_DIR?=$(SNPS_DIR)/cov.base
SNPS_COVER_SET_DIR?=$(SNPS_SET_DIR)/cov.set

# single merged snp table
SNPS_MERGE_TABLE?=$(SNPS_SET_DIR)/snps_merged

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
SNPS_CLASSIFIED_TABLE?=$(SNPS_SET_DIR)/snps_class

#####################################################################################################
# gene-level summary
#####################################################################################################

# trim sides of contigs
SNPS_EDGE_MARGIN?=200

# genes
SNPS_GENE_SEGMENTS?=$(SNPS_DIR)/gene_segments

# gene coverage
SNPS_GENE_BASE_COVERAGE?=$(SNPS_DIR)/gene_base_coverage
SNPS_GENE_COVERAGE?=$(SNPS_SET_DIR)/gene_coverage

# gene summary of segregating and fixed snps counts
SNPS_GENE_SUMARY?=$(SNPS_SET_DIR)/gene_summary

# supporting snps for gene table
SNPS_GENE_DETAILS?=$(SNPS_SET_DIR)/gene_snps_details

#####################################################################################################
# bin-level summary
#####################################################################################################

# min gene detection coverage
SNPS_MIN_GENE_COVERAGE?=1

SNPS_BIN_TABLE?=$(SNPS_SET_DIR)/bin_table

#####################################################################################################
# minor genetic changes
#####################################################################################################

# select bins with change below this threshold (fixations/bp)
SNPS_CHANGE_MAX_FIX_DENSITY?=10e-05
SNPS_CHANGE_MIN_COVERAGE?=5

# bin summary of change
SNPS_CHANGE_SUMMARY?=$(SNPS_SET_DIR)/changed_summary

# annotated genes of change
SNPS_CHANGE_GENES?=$(SNPS_SET_DIR)/changed_genes

#####################################################################################################
# snp trajectories
#####################################################################################################

# limit trajectories to fixed positions
SNPS_SELECT_ONLY_FIXED?=T

# limited to relevant postions
SNPS_SELECTED_PREFIX?=$(SNPS_SET_DIR)/unified.selected

# fixed positions, with associated bins
SNPS_TRJ_POSITIONS?=$(SNPS_SET_DIR)/snp_table.trj

# trajectory of dominant allele in base library
SNPS_TRJ_BASE?=$(SNPS_SET_DIR)/trajectory.base
SNPS_TRJ_SET?=$(SNPS_SET_DIR)/trajectory.set

SNPS_TRJ_LABELS?=T-28 T-15 T-8 T-2 T-1 T+1 T+2 T+3 T+4 T+5 T+6 T+7 T+8 T+10 T+12 T+14 T+16 T+18 T+22 T+25 T+32 T+47 T+79 T+80

