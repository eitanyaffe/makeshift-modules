#####################################################################################################
# register module
#####################################################################################################

units=ntcmp.mk
$(call _register_module,ntcmp,$(units),,)

#####################################################################################################
# external tools
#####################################################################################################

MUMMER_DIR?=/home/eitany/work/download/MUMmer3.23

# mummer paths
MUMMER?=$(MUMMER_DIR)/mummer
NUCMER?=$(MUMMER_DIR)/nucmer
SHOWCOORD?=$(MUMMER_DIR)/show-coords

#####################################################################################################
# input
#####################################################################################################

# input variables
# NTCMP_FASTA_DIR1: fasta sequence directory 1
# NTCMP_FASTA_PATTERN1: fasta files in dir 1
# NTCMP_FASTA_DIR2: fasta sequence directory 2
# NTCMP_FASTA_PATTERN2: fasta files in dir 2

#####################################################################################################
# output
#####################################################################################################

NTCMP_ROOT?=$(OUTPUT_DIR)
NTCMP_ROOT_TMP?=$(OUTPUT_TMP_DIR)

NTCMP_ID?=main
NTCMP_DIR?=$(NTCMP_ROOT)/$(NTCMP_ID)
NTCMP_QSUB_DIR?=$(NTCMP_ROOT_TMP)/$(NTCMP_ID)

# fasta files
NTCMP_FASTA_FILES1?=$(wildcard $(NTCMP_FASTA_DIR1)/$(NTCMP_FASTA_PATTERN1))
NTCMP_FASTA_FILES2?=$(wildcard $(NTCMP_FASTA_DIR2)/$(NTCMP_FASTA_PATTERN2))

NTCMP_FASTA1?=$(NTCMP_DIR)/1.fasta
NTCMP_FASTA2?=$(NTCMP_DIR)/2.fasta

NTCMP_CONTIG_TABLE1?=$(NTCMP_DIR)/1.table
NTCMP_CONTIG_TABLE2?=$(NTCMP_DIR)/2.table

NTCMP_CHUNKS?=10
NTCMP_SPLIT_DIR1?=$(NTCMP_DIR)/split1
NTCMP_SPLIT_DIR2?=$(NTCMP_DIR)/split2

NTCMP_RESULT_DIR?=$(NTCMP_DIR)/results

# project results on each genome to make unique
NTCMP_UNIQUE_DIR1?=$(NTCMP_DIR)/uniq1
NTCMP_UNIQUE_DIR2?=$(NTCMP_DIR)/uniq2

# binning
NTCMP_BIN_SIZES?=100 1000 10000
NTCMP_BIN_DIR1?=$(NTCMP_DIR)/bin1
NTCMP_BIN_DIR2?=$(NTCMP_DIR)/bin2

# bin only contigs above this threshold
NTCMP_MIN_BIN_CONTIG_LENGTH?=1000

# summary tables
NTCMP_SUMMARY1?=$(NTCMP_DIR)/summary1
NTCMP_SUMMARY2?=$(NTCMP_DIR)/summary2

#####################################################################################################
# test
#####################################################################################################

ifeq ($(TEST),T)
NTCMP_ID=test
NTCMP_ROOT=$(CURDIR)/test/out
NTCMP_FASTA_DIR1=$(CURDIR)/test
NTCMP_FASTA_DIR2=$(CURDIR)/test
NTCMP_FASTA_PATTERN1=input1.fasta
NTCMP_FASTA_PATTERN2=input2.fasta
NTCMP_BIN_SIZES=10
NTCMP_MIN_BIN_CONTIG_LENGTH=0
endif
