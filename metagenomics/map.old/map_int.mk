units:=map.mk map_bwa.mk
$(call _register_module,map,$(units),,)

#####################################################################################################
# input files and working directory
#####################################################################################################

# we use all the assembly as reference, including shorter discarded contigs
MAP_SEQ_FILE?=$(FULL_CONTIG_FILE)

# input fastq files
MAP_PATTERN?=$(PREPROC_FINAL_BASE)/$(MAP_LIB_ID)/R*
MAP_INPUT?=$(wildcard $(MAP_PATTERN))

# which lib to use for mapping
MAP_LIB_ID?=$(LIB_ID)

# work under these paths
MAP_ROOT_DIR?=$(BASE_OUTPUT_DIR)
MAP_ROOT_TMP_DIR?=$(QSUB_DIR)

#####################################################################################################
# mapping
#####################################################################################################

# currently support only bwa
MAP_TYPE?=bwa

# one index file for each assembly+mapper pair
INDEX_DIR?=$(MAP_ROOT_DIR)/map_index/$(MAP_TYPE)

# for mapping use by default only part of read
MAP_SPLIT_TRIM?=T
MAP_SPLIT_READ_OFFSET=0
MAP_READ_LENGTH=100
MAP_TAG?=$(MAP_SPLIT_TRIM)_$(MAP_SPLIT_READ_OFFSET)_$(MAP_READ_LENGTH)

# map uses two directories
MAP_DIR?=$(MAP_ROOT_DIR)/map_$(MAP_TAG)/$(MAP_LIB_ID)
MAP_TMPDIR?=$(MAP_ROOT_TMP_DIR)/map_$(MAP_TAG)/$(MAP_LIB_ID)

SPLIT_DIR?=$(MAP_DIR)/split
MAPPED_DIR?=$(MAP_DIR)/mapped_$(MAP_TYPE)
PARSE_DIR?=$(MAP_DIR)/parsed

# split input reads before mapping
MAP_SPLIT_READS_PER_FILE?=10000000

# number of parallel map jobs
NUM_MAP_JOBS?=10

# Phred of read
MAP_MIN_QUALITY_SCORE?=30

# in nt, the total length of all M segments in the CIGAR
MAP_MIN_LENGTH?=$(MAP_READ_LENGTH)

# The sam NM score as reported by bwa
MAP_MIN_EDIT_DISTANCE?=1

FILTER_ID?=s$(MAP_MIN_QUALITY_SCORE)_l$(MAP_MIN_LENGTH)_d$(MAP_MIN_EDIT_DISTANCE)

FILTER_DIR?=$(MAP_DIR)/filter_$(FILTER_ID)

PAIRED_DIR?=$(MAP_DIR)/pair_$(FILTER_ID)

PARSE_DONE?=$(MAP_DIR)/.done_parse_$(MAP_TYPE)
VERIFY_PARSE_DONE?=$(MAP_DIR)/.done_verify_$(MAP_TYPE)

#####################################################################################################
# stats
#####################################################################################################

# input reads
MAP_INPUT_STAT?=$(MAP_DIR)/stats_input

# parse reads
PARSE_STAT_DIR?=$(MAP_DIR)/parse_stat
PARSE_STAT_FILE?=$(MAP_DIR)/parse_stat.table

# filtering reads
FILTER_STAT_DIR?=$(MAP_DIR)/filter_stat_$(FILTER_ID)
FILTER_STAT_FILE?=$(MAP_DIR)/filter_stat_$(FILTER_ID).table

# pairing reads
PAIRED_STAT_DIR?=$(MAP_DIR)/pair_stat_$(FILTER_ID)
PAIRED_STAT_FILE?=$(MAP_DIR)/pair_stat_$(FILTER_ID).table

#####################################################################################################
# coverage
#####################################################################################################

MAP_BINSIZE?=100
COVERAGE_DIR?=$(MAP_ROOT_DIR)/coverage_$(MAP_TAG)/contigs
COVERAGE_TABLE=$(MAP_ROOT_DIR)/coverage_$(MAP_TAG)/table

