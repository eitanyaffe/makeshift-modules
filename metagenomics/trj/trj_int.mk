#####################################################################################################
# register module
#####################################################################################################

units:=trj.mk trj_plot.mk
$(call _register_module,trj,$(units),)

#####################################################################################################
# input/output
#####################################################################################################

# input contigs and assembly
TRJ_CONTIG_TABLE?=$(CONTIG_TABLE)

# input bin table, from bins module
TRJ_BIN_TABLE_INPUT?=$(BINS_TABLE)

# map contig to bin
TRJ_CONTIG_BIN?=$(BINS_CONTIG_TABLE_ASSOCIATED)

# mapped reads are here
TRJ_BASEMAP_DIR?=$(BASEMAP_DIR)

# all ids
TRJ_IDS?=i1 i2 i3

# baseline ids
TRJ_BASE_IDS?=b1 b2 b3

# disturbed ids
TRJ_MID_IDS?=d1 d2 d3

# define samples for plotting
TRJ_SAMPLE_DEFS?=$(SUBJECT_SAMPLE_DEFS)

# use sample table
TRJ_ANNOTATE?=T

# output
TRJ_BASEDIR?=$(ASSEMBLY_DIR)

TRJ_VER?=v3
TRJ_DIR?=$(TRJ_BASEDIR)/trj_$(TRJ_VER)

# figures
TRJ_FDIR?=$(BASE_FDIR)/trj

#####################################################################################################
# contig summary
#####################################################################################################

TRJ_CONTIG_OBSERVED?=$(TRJ_DIR)/contigs_observed
TRJ_CONTIG_EXPECTED?=$(TRJ_DIR)/contigs_expected

TRJ_CONTIG_OBSERVED_MIN_DETECTED?=1
TRJ_CONTIG_NORM?=$(TRJ_DIR)/contigs_norm
TRJ_CONTIG_NORM_DETECTION?=$(TRJ_DIR)/contigs_norm_detection

#####################################################################################################
# bin summary
#####################################################################################################

TRJ_BIN_TABLE?=$(TRJ_DIR)/bin_table

TRJ_PATTERN_OBS?=$(TRJ_DIR)/pattern_obs
TRJ_PATTERN_EXP?=$(TRJ_DIR)/pattern_exp
TRJ_PATTERN_MEAN?=$(TRJ_DIR)/pattern_mean
TRJ_PATTERN_MEDIAN?=$(TRJ_DIR)/pattern_median
TRJ_PATTERN_TOP95?=$(TRJ_DIR)/pattern_top95
TRJ_PATTERN_TOP75?=$(TRJ_DIR)/pattern_top75
TRJ_PATTERN_TOP100?=$(TRJ_DIR)/pattern_top100
TRJ_PATTERN_BOTTOM0?=$(TRJ_DIR)/pattern_bottom0
TRJ_PATTERN_BOTTOM05?=$(TRJ_DIR)/pattern_bottom05
TRJ_PATTERN_BOTTOM25?=$(TRJ_DIR)/pattern_bottom25
TRJ_PATTERN_SD?=$(TRJ_DIR)/pattern_sd

#####################################################################################################
# order bins using hclust
#####################################################################################################

TRJ_N_CLASSES?=15
TRJ_CLASS_MAX_HEIGHT?=0.15
TRJ_CLASS_TYPE=count
TRJ_BIN_ORDER?=$(TRJ_DIR)/bin_order
