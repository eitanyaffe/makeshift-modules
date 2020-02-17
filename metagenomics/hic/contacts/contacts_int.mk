#####################################################################################################
# register module
#####################################################################################################

units:=contacts_similarity.mk contacts_matrix.mk
$(call _register_module,contacts,$(units),,)

#####################################################################################################
# general params
#####################################################################################################

CNT_ROOT_DIR?=$(OUTPUT_DIR)
CNT_ROOT_QSUB_DIR?=$(QSUB_DIR)

# output directory
CNT_DIR?=$(CNT_ROOT_DIR)/contacts
CNT_QSUB_DIR=$(CNT_ROOT_QSUB_DIR)/contacts

#####################################################################################################
# input tables
#####################################################################################################

CNT_CONTIG_TABLE_IN?=$(BINS_CONTIG_TABLE)
CNT_CONTIG_FILE_IN?=$(BINS_CONTIG_FASTA)

# mapped read pairs
CNT_PAIRED_DIR_IN?=$(PAIRED_DIR)

MUMMER_DIR?=/home/eitany/work/download/MUMmer3.23

#####################################################################################################
# similarity
#####################################################################################################

# this is common to all libs
SIM_DIR?=$(CNT_DIR)/similarity
SIM_RESULT_DIR?=$(SIM_DIR)/result
SIM_SPLIT_DIR?=$(SIM_DIR)/split
SIM_QSUB_DIR?=$(CNT_QSUB_DIR)/similarity

# mummer paths
MUMMER?=$(MUMMER_DIR)/mummer
NUCMER?=$(MUMMER_DIR)/nucmer
SHOWCOORD?=$(MUMMER_DIR)/show-coords

# number of files
SIM_CHUNKS?=10

#######################################################################################
# contig matrix
#######################################################################################

# extend similarity rects by this offset when masking out contacts between similar regions
CONTIG_MATRIX_SIMILARITY_OFFSET=2000

CONTIG_MATRIX_BASE_DIR?=$(CNT_DIR)/libs/$(LIB_ID)

# contacts
CONTIG_CONTACTS?=$(CONTIG_MATRIX_BASE_DIR)/filtered_contacts
CONTIG_MASKED_CONTACTS?=$(CONTIG_MATRIX_BASE_DIR)/masked_contacts
CONTIG_MATRIX?=$(CONTIG_MATRIX_BASE_DIR)/table

# stats
CONTIG_MATRIX_STATS?=$(CONTIG_MATRIX_BASE_DIR)/cmatrix_stats
