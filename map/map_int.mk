units:=map.mk map_bwa.mk coverage.mk

$(call _register_module,map,$(units),,)

#####################################################################################################
# input
#####################################################################################################

# input reference fasta sequence
MAP_SEQ_FILE=$(CONTIG_FASTA)

# input fastq files
MAP_INPUT_PREFIX?=R
MAP_PATTERN?=$(LIBRARY_DIR)/$(LIB_ID)/$(MAP_INPUT_PREFIX)*
MAP_INPUT?=$(wildcard $(MAP_PATTERN))

# write output under here
MAP_ROOT?=$(OUTPUT_DIR)
MAP_ROOT_TMP?=$(OUTPUT_TMP_DIR)

#####################################################################################################
# mapping
#####################################################################################################

# currently support only bwa
MAP_TYPE?=bwa

MAP_VER?=v2
BASEMAP_DIR?=$(MAP_ROOT)/map_$(MAP_VER)
MAP_TMPDIR?=$(MAP_ROOT_TMP)/map_$(MAP_VER)/$(LIB_ID)

# index file
INDEX_DIR?=$(BASEMAP_DIR)/$(MAP_TYPE)_index

# output here
MAP_DIR?=$(BASEMAP_DIR)/$(LIB_ID)

# by default use all read
MAP_SPLIT_TRIM?=F
MAP_SPLIT_READ_OFFSET1?=0
MAP_READ_LENGTH1?=40
MAP_SPLIT_READ_OFFSET2?=$(MAP_SPLIT_READ_OFFSET1)
MAP_READ_LENGTH2?=$(MAP_READ_LENGTH1)

# set to zero to include all reads
MAP_MAX_READS?=10000000

SPLIT_DIR?=$(MAP_DIR)/split
MAPPED_DIR?=$(MAP_DIR)/mapped_$(MAP_TYPE)
PARSE_DIR?=$(MAP_DIR)/parsed

# split input reads before mapping
MAP_SPLIT_READS_PER_FILE?=1000000

# number of parallel map jobs
NUM_MAP_JOBS?=20

# should purge split directory
MAP_PURGE_SPLIT?=T

#####################################################################################################
# filtering
#####################################################################################################

# Phred of read
MAP_MIN_QUALITY_SCORE?=30

# in nt, the total length of all M segments in the CIGAR
MAP_MIN_LENGTH?=50

# The sam NM score as reported by bwa
MAP_MIN_EDIT_DISTANCE?=5

FILTER_ID?=s$(MAP_MIN_QUALITY_SCORE)_l$(MAP_MIN_LENGTH)_d$(MAP_MIN_EDIT_DISTANCE)

FILTER_DIR?=$(MAP_DIR)/filter_$(FILTER_ID)

#####################################################################################################
# pairing
#####################################################################################################

MAP_IS_PAIRED?=T

PAIRED_DIR?=$(MAP_DIR)/pair_$(FILTER_ID)

PARSE_DONE?=$(MAP_DIR)/.done_parse_$(MAP_TYPE)
VERIFY_PARSE_DONE?=$(MAP_DIR)/.done_verify_$(MAP_TYPE)

REMOVE_MAP_TRANSIENT?=F

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
COVERAGE_TABLE=$(MAP_DIR)/coverage.table
CONTIG_FIELD?=contig
