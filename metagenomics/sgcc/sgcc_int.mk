units=sgcc_manager.mk sgcc.mk sgcc_export.mk
$(call _register_module,sgcc,$(units),)

SGCC_VER?=v1.08

#####################################################################################################
# basic input/output
#####################################################################################################

# base directory of input files
SGCC_INPUT_DIR?=$(INPUT_DIR)

SGCC_BASE_DIR?=$(OUTPUT_DIR)/sgcc/$(SGCC_VER)

#####################################################################################################
# single lib params
#####################################################################################################

# sequencing lib identifer
SGCC_LIB_ID?=specify_lib_id
SGCC_R1_GZ_FN?=specify_fastq_R1
SGCC_R2_GZ_FN?=specify_fastq_R2

SGCC_INPUT_R1_GZ?=$(INPUT_DIR)/$(SGCC_R1_GZ_FN)
SGCC_INPUT_R2_GZ?=$(INPUT_DIR)/$(SGCC_R2_GZ_FN)

SGCC_LIBS_DIR?=$(SGCC_BASE_DIR)/libs
SGCC_DIR?=$(SGCC_LIBS_DIR)/$(SGCC_LIB_ID)

# manager over all libs works here
SGCC_INFO_DIR?=$(SGCC_BASE_DIR)/info

SGCC_LIB_INFO_DIR?=$(SGCC_DIR)/info
SGCC_LIB_WORK_DIR?=$(SGCC_DIR)/work

#####################################################################################################
# multiple libs
#####################################################################################################

# raw seq table
SGCC_INPUT_TABLE?=$(LIBS_INPUT_TABLE)

#####################################################################################################
# table of libs
#####################################################################################################

# script must contain function generate.sgcc.table that extracts fields:
# SGCC_LIB_ID, SGCC_R1_GZ_FN, SGCC_R2_GZ_FN 
SGCC_TABLE_SCRIPT?=$(LIBS_INPUT_SCRIPT)

SGCC_TABLE_DIR?=$(SGCC_BASE_DIR)/tables

# with SGCC_LIB_ID, SGCC_R1_GZ_FN, SGCC_R2_GZ_FN
SGCC_TABLE?=$(SGCC_TABLE_DIR)/libs.txt

# with extra fields
SGCC_TABLE_EXTRA?=$(SGCC_TABLE_DIR)/libs_extra.txt

# VM disk size, can be defined in SGCC_TABLE
SGCC_DISK_GB?=128

#####################################################################################################
# get input and compute signature
#####################################################################################################

# local copies 
SGCC_SEQ_R1_GZ=$(SGCC_LIB_WORK_DIR)/R1.fastq.gz
SGCC_SEQ_R2_GZ=$(SGCC_LIB_WORK_DIR)/R2.fastq.gz

SGCC_SEQ_R1=$(SGCC_LIB_WORK_DIR)/R1.fastq
SGCC_SEQ_R2=$(SGCC_LIB_WORK_DIR)/R2.fastq

# fastq
SGCC_FASTQ?=$(SGCC_LIB_WORK_DIR)/reads.fq

# number of reads per lib
SGCC_READ_COUNT_FILE?=$(SGCC_LIB_WORK_DIR)/read_count

# random seed
SGCC_SUBSAMPLE_SEED?=1

SGCC_PIGZ_THREADS?=2

#####################################################################################################
# compute signature
#####################################################################################################

# use up to this number of reads from each library (in millions)
SGCC_FASTQ_MREADS?=5

# half from each read side 
SGCC_FASTQ_COUNT=$(shell echo $(SGCC_FASTQ_MREADS)\*2000000 | bc)

# sourmash installed via docker
SOURMASH=sourmash

# kmer size
SGCC_KMER_SIG?=77

SGCC_SIG?=$(SGCC_LIB_WORK_DIR)/sourmash.sig

#####################################################################################################
# compare
#####################################################################################################

SGCC_COMPARE_DIR?=$(SGCC_BASE_DIR)/compare

# matrix
SGCC_COMPARE_TABLE=$(SGCC_COMPARE_DIR)/matrix.tab

# summary of read counts
SGCC_STATS_TABLE=$(SGCC_COMPARE_DIR)/read_counts.summary

#####################################################################################################
# export data
#####################################################################################################

SGCC_EXPORT_DIR?=$(BASE_EXPORT_DIR)/sgcc_$(SGCC_VER)
