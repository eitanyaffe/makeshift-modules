#####################################################################################################
# register module
#####################################################################################################

units:=cr_base.mk cr_network.mk cr_plots.mk cr_network_plots.mk
$(call _register_module,cr,$(units),,)

#####################################################################################################
# basic input
#####################################################################################################

CR_IN_SC_CORE_GENES?=$(SC_CORE_GENES)
CR_IN_SC_GENE_ELEMENT?=$(SC_GENE_ELEMENT)
CR_IN_SC_ELEMENT_ANCHOR?=$(SC_ELEMENT_ANCHOR)

#####################################################################################################

CR_ID?=full_temporal
CR_DATASETS?=\
cipro_full_S1 cipro_full_S2 cipro_full_S3 cipro_full_S4 cipro_full_S5 cipro_full_S6 cipro_full_S7 cipro_full_S8 cipro_full_S9 cipro_full_S10 cipro_full_S11 cipro_full_S12 \
cipro_full_S13 cipro_full_S14 cipro_full_S15 cipro_full_S16  cipro_full_S17 cipro_full_S18 cipro_full_S19 cipro_full_S20 cipro_full_S21 cipro_full_S22 cipro_full_S23 cipro_full_S24
CR_LABELS?=S1 S2 S3 S4 S5 S6 S7 S8 S9 S10 S11 S12 S13 S14 S15 S16 S17 S18 S19 S20 S21 S22 S23 S24
CR_DAYS=-28 -15 -8 -2 -1 +1 +2 +3 +4 +5 +6 +7 +8 +10 +12 +14 +16 +18 +22 +25 +32 +47 +79 +80
CR_ZOOM_DAYS?=-14 +21
CR_DISTURB_DAYS?=0 5

########################################################################

CR_VERSION?=v3
CR_DIR?=$(ASSEMBLY_DIR)/core_response/$(CR_VERSION)/$(CR_ID)

CR_FDIR?=$(FIGURE_DIR)/cr/$(CR_VERSION)/$(CR_ID)

########################################################################
# select anchors
########################################################################

# by default work on anchors classified by evo as persistent
CR_ANCHORS_TABLE_IN?=$(EVO_CORE_FATE_CLASS_POST)
CR_ANCHORS_FIELD_IN?=fate
CR_ANCHORS_VALUES_IN?=persist
CR_ANCHORS_SELECTED?=$(CR_DIR)/anchors

########################################################################
# bin cores/elements
########################################################################

# segments are 1-based
CR_CORE_SEGMENTS_BASE?=$(CR_DIR)/core.base_segments
CR_ELEMENT_SEGMENTS_BASE?=$(CR_DIR)/element.base_segments
CR_ANCHOR_SEGMENTS_BASE?=$(CR_DIR)/anchor.base_segments

# merge and switch anchor to anchor.id
CR_SEGMENTS_BASE?=$(CR_DIR)/segments.base_table

# bin segments
CR_BINSIZE?=1000
CR_READ_LENGTH=$(MAP_READ_LENGTH)

# select large bins and large segments
CR_MIN_SEGMENT_SIZE?=1000
CR_MIN_BIN_SIZE?=750

# filtered and binned
CR_SETS?=$(CR_DIR)/sets
CR_SEGMENTS?=$(CR_DIR)/segments.table
CR_BINS?=$(CR_DIR)/segments.bins

########################################################################
# library profiles
########################################################################

# binned result per library
CR_LIB_ID=$(LIB_ID)
CR_LIB_DIR?=$(CR_DIR)/libs/$(CR_LIB_ID)
CR_LIB_TABLE?=$(CR_LIB_DIR)/table
CR_LIB_STATS?=$(CR_LIB_DIR)/stats

# aggregate back into matrix
CR_MIN_DETECTED?=1
CR_TOTAL?=$(CR_DIR)/obs.total
CR_OBSERVED?=$(CR_DIR)/obs.bins
CR_EXPECTED?=$(CR_DIR)/exp.bins
CR_NORM?=$(CR_DIR)/norm.bins
CR_NORM_DETECTION?=$(CR_DIR)/norm_detection

# segment profiles
CR_PATTERN_OBS?=$(CR_DIR)/pattern_obs
CR_PATTERN_EXP?=$(CR_DIR)/pattern_exp
CR_PATTERN_MEAN?=$(CR_DIR)/pattern_mean
CR_PATTERN_MEDIAN?=$(CR_DIR)/pattern_median
CR_PATTERN_TOP95?=$(CR_DIR)/pattern_top95
CR_PATTERN_TOP75?=$(CR_DIR)/pattern_top75
CR_PATTERN_TOP100?=$(CR_DIR)/pattern_top100
CR_PATTERN_BOTTOM0?=$(CR_DIR)/pattern_bottom0
CR_PATTERN_BOTTOM05?=$(CR_DIR)/pattern_bottom05
CR_PATTERN_BOTTOM25?=$(CR_DIR)/pattern_bottom25
CR_PATTERN_SD?=$(CR_DIR)/pattern_sd

# distance of bins from set median
CR_BIN_DIST?=$(CR_DIR)/bin.dist

# set summary of bin of distances
CR_SET_DIST?=$(CR_DIR)/set.dist

# anchor order
CR_BASE_IDS?="cipro_full_S1 cipro_full_S2 cipro_full_S3 cipro_full_S4 cipro_full_S5"
CR_DISTURB_IDS?="cipro_full_S6 cipro_full_S7 cipro_full_S8 cipro_full_S9 cipro_full_S10"
CR_N_CLASSES?=15
CR_CLASS_MAX_HEIGHT?=0.15
CR_CLASS_TYPE=count
CR_ANCHOR_ORDER?=$(CR_DIR)/anchor_order

# single host analysis
CR_MIN_BASE_CORRELATION?=-2

########################################################################
# cr_network.mk
########################################################################

CR_HIC_DIR?=$(CR_DIR)/hic
CR_HIC_SEGMENTS?=$(CR_HIC_DIR)/segments

# see code in ee_map.mk
CR_HIC_LIB?=pre_lib_hic_u_simple
CR_DATASET_ANCHOR_DIR?=$(call reval,DATASET_ANCHOR_DIR,LIB_ID=$(CR_HIC_LIB))
CR_HIC_LIB_DIR?=$(CR_HIC_DIR)/libs/$(CR_HIC_LIB)
CR_EE_MAP_DIR?=$(CR_HIC_DIR)/libs/$(CR_HIC_LIB)/ee_map
CR_HIC_MATRIX?=$(CR_EE_MAP_DIR)/result
CR_HIC_FENDS?=$(CR_EE_MAP_DIR)/fends

# count fend per set
CR_SET_FENDS?=$(CR_HIC_LIB_DIR)/set_fends

# element-anchor association definition
# e: expected, o; observed, score: log10(0/e)
# connected: (score >= connected_min_score) && (o >= connected_min_o)
# separated: (score <= separated_max_score) && (e*10^separated_max_score >= separated_min_o)

# connection: minimal number of supporting contacts
CR_NETWORK_MIN_CONTACTS?=10

# connection: minimal score
CR_NETWORK_MIN_ENRICHMENT?=1

# separation: minimal number of expected contacts
CR_NETWORK_SEPARATE_MIN_CONTACTS?=0.5

# separation: maximal score
CR_NETWORK_SEPARATE_MAX_SCORE?=0.33

# element-anchor association matrix
CR_ANCHOR_MATRIX?=$(CR_HIC_LIB_DIR)/matrix

# compare two maps
CR_HIC_COMPARE_LABEL?=pre_vs_post
RDATASET1?=pre_lib_hic_u_simple
RDATASET2?=post_lib_hic_u_simple

CR_LEGEND1?=pre
CR_LEGEND2?=post

CR_ANCHOR_MATRIX1?=$(call reval,CR_ANCHOR_MATRIX,CR_HIC_LIB=$(RDATASET1))
CR_ANCHOR_MATRIX2?=$(call reval,CR_ANCHOR_MATRIX,CR_HIC_LIB=$(RDATASET2))
CR_HIC_COMPARE_DIR?=$(CR_HIC_DIR)/compare/$(CR_HIC_COMPARE_LABEL)
CR_MIN_FIT_SUPPORT?=5
CR_ANCHOR_TABLE_COMPARE?=$(CR_HIC_COMPARE_DIR)/anchors
CR_MAP_COMPARE?=$(CR_HIC_COMPARE_DIR)/map

####################################################################################
# temporal.mk
####################################################################################

# TBD

CR_ANCHOR_ELEMENTS?=$(CR_HIC_LIB_DIR)/anchor_elements

