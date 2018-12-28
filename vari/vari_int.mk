units:=vari.mk
$(call _register_module,vari,$(units),,)

##########################################################################
# General parameters
##########################################################################

# must define input variables
# VAR_INPUT_CONTIG_TABLE: contig table

# by default us as input the output of the map module
VAR_INPUT_PARSE_DIR?=$(PARSE_DIR)

# minimal read score and length
VAR_MIN_SCORE?=30
VAR_MIN_MATCH_LENGTH?=50
VAR_MAX_EDIT_DISTANCE?=3

# we use the table with selected cag genes
VAR_INPUT_ITEM_FIELD?=contig

# reads that mapped completely
VAR_OUTPUT_FULL_DIR?=$(MAP_DIR)/output_full

# clipped reads
VAR_OUTPUT_CLIPPED_DIR?=$(MAP_DIR)/output_clipped

# bin sizes
VAR_BIN_SIZES=100 1000 10000

# when binning, a snp is called per position if the snp count S satisifes T < S < 1-T, where T is:
VAR_POLY_PERCENT_THRESHOLD=0.1
VAR_POLY_COUNT_THRESHOLD=3

# fixed threshold
VAR_POLY_FIXED_PERCENT_THRESHOLD=0.95

##########################################################################
# contig summary params
##########################################################################

# avoid contig egdes (distance in nt)
VAR_SUMMARY_MARGIN?=100

VAR_SUMMARY?=$(MAP_DIR)/summary.table


