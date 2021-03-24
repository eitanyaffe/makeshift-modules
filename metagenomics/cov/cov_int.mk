units=cov_binary.mk cov_construct.mk cov.mk cov_plots.mk
$(call _register_module,cov,$(units),)

#####################################################################################################
# cov binary
#####################################################################################################

COV_BIN=$(_md)/bin.$(shell hostname)/cov

#####################################################################################################
# basic input/output
#####################################################################################################

# contig table
COV_INPUT_CONTIG_TABLE?=$(ASSEMBLY_CONTIG_TABLE)

# contig fasta
COV_INPUT_CONTIG_FASTA?=$(ASSEMBLY_CONTIG_FILE)

# output dir
COV_VER?=v3
COV_DIR?=$(ASSEMBLY_DIR)/cov_$(COV_VER)

# figure dir
COV_FDIR?=$(BASE_FDIR)/cov_$(COV_VER)

#####################################################################################################
# construct COV per library
#####################################################################################################

COV_MAP_ROOT?=$(COV_DIR)/map
COV_BASEMAP_DIR?=$(call reval,BASEMAP_DIR,MAP_ROOT=$(COV_MAP_ROOT))

# map fastq results are here
#COV_MAPDIR?=$(call reval,PARSE_DIR,MAP_ROOT=$(COV_MAP_ROOT))
#COV_MAPDIR?=$(PARSE_DIR)
COV_PARSE_DIR?=$(COV_BASEMAP_DIR)/$(LIB_ID)/parsed

COV_MIN_SCORE?=30
COV_MIN_MATCH_LENGTH?=50
COV_MAX_EDIT_DISTANCE?=3
COV_DISCARD_CLIPPED?=T

COV_LIB_DIR?=$(COV_DIR)/libs/$(LIB_ID)

# COV data-structure
COV_DS?=$(COV_LIB_DIR)/lib.cov

# go over multiple libs
COV_IDS?=i1 i2 i3

# table with all cov files
COV_LIB_TABLE?=$(COV_DIR)/cov.table

#####################################################################################################
# breakdown contigs
#####################################################################################################

# outlier: if the observed coordinate frequency vector (across samples) deviates from the expected
# covtribution assuming a chi-square read covtribution around the mean contig coverage vector
COV_PVALUE?=0.00001

# fraction of outliers to consider in each covsolve round
COV_OUTLIER_FRACTION=0.01

# add pseudo-counts to avoid poorly defined probablities
COV_PSEUDO_COUNT=0.1

# uniform|marginal
COV_WEIGHT_STYLE?=marginal

# reject center segments under this length
COV_MIN_CENTER_SEGMENT_LENGTH?=147

COV_ANALYSIS_VER?=v1
COV_ANALYSIS_DIR?=$(COV_DIR)/analysis/$(COV_WEIGHT_STYLE)_$(COV_ANALYSIS_VER)

COV_MAX_LIB_COUNT?=0

#####################################################################################################
# break contigs
#####################################################################################################

COV_CONTIG_SUMMARY?=$(COV_ANALYSIS_DIR)/contigs.summary
COV_SEGMENT_TABLE?=$(COV_ANALYSIS_DIR)/segments.tab

#####################################################################################################
# corrected assembly
#####################################################################################################

# contig name and length
COV_CONTIG_TABLE?=$(COV_ANALYSIS_DIR)/contigs.tab
COV_CONTIG_FASTA?=$(COV_ANALYSIS_DIR)/contigs.fa
