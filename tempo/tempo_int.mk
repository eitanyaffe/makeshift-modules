#####################################################################################################
# register module
#####################################################################################################

units:=tempo_libs.mk tempo_snps.mk

$(call _register_module,tempo,$(units),)

#####################################################################################################

#####################################################################################################
# There are two distinct input types
# TEMPO_INPUT_TYPE=hmd
#  - Pre-processed by Les
#  - Libraries pre-trimmed with trimmomatic
#  - Library paths inferred using the sample and measure tables
# TEMPO_INPUT_TYPE=raw
#  - Raw data, such as AAB
#  - Libraries are raw, under the subject input directory: TEMPO_SUBJECT_INPUT_BASE_DIR
#  - Library ids: defined in a file called ids in the subject directory
#  - Raw library fastq files: in a subdirectory within the subject directory
# TEMPO_INPUT_TYPE=pass
#  - Passaginng data, coming from biohub sequencing
#####################################################################################################

# input type
TEMPO_INPUT_TYPE?=hmd

####################################
# for TEMPO_INPUT_TYPE=raw
####################################

TEMPO_SUBJECT_INPUT_BASE_DIR?=/relman04/projects/HiC/rawdata/Run9/files
TEMPO_SUBJECT_INPUT_LIB_IDS?=$(TEMPO_SUBJECT_INPUT_BASE_DIR)/ids

# lib set definitions for snps
SUBJECT_LIB_DEF_TABLE_INPUT?=$(CUSTOM_LIB_DEF_TABLE)

####################################
# for TEMPO_INPUT_TYPE=hmd
####################################

TEMPO_SAMPLE_TABLE_IN?=$(CURDIR)/tables/sample_table.txt
TEMPO_MEASURE_TABLE_IN?=$(CURDIR)/tables/measure_table.txt

# by default attempt both types
TEMPO_TYPES?=DNA RNA

# this is generated only for the trimmed input type
SUBJECT_DNA_LIB_TABLE?=$(SUBJECT_DIR)/dna_libs.txt

# RNA
SUBJECT_RNA_LIB_TABLE?=$(SUBJECT_DIR)/rna_libs.txt

# how many libs per set (base or post)
SUBJECT_LIBSET_COUNT?=5

####################################
# for TEMPO_INPUT_TYPE=pass
####################################

TEMPO_PASS_SAMPLE_TABLE_IN?=$(CURDIR)/passaging_tables/pilot_sample_table.txt
TEMPO_PASS_SEQ_TABLE_IN?=$(CURDIR)/passaging_tables/pilot_biohub_summary.txt
TEMPO_PASS_SUBJECT_LOOKUP_IN?=$(CURDIR)/passaging_tables/subject_lookup.txt

TEMPO_PASS_FASTQ_DIR_IN?=/relman04/projects/temporal_metagenomics/youlim_pilot

####################################
# shared parameters from here
####################################

# sample/dna/rna/definition
SUBJECT_SAMPLE_DEFS?=$(SUBJECT_DIR)/sample.defs

SUBJECT_DNA_LIB_IDS_FILE?=$(SUBJECT_DIR)/dna_lib_ids
SUBJECT_RNA_LIB_IDS_FILE?=$(SUBJECT_DIR)/rna_lib_ids

SUBJECT_DNA_LIB_IDS?=$(shell cat $(SUBJECT_DNA_LIB_IDS_FILE))
SUBJECT_RNA_LIB_IDS?=$(shell cat $(SUBJECT_RNA_LIB_IDS_FILE))

TEMPO_LIB_TYPE?=DNA
ifeq ($(TEMPO_LIB_TYPE),DNA)
SUBJECT_LIB_IDS_FILE?=$(SUBJECT_DNA_LIB_IDS_FILE)
SUBJECT_LIB_TABLE?=$(SUBJECT_DNA_LIB_TABLE)
else
SUBJECT_LIB_IDS_FILE?=$(SUBJECT_RNA_LIB_IDS_FILE)
SUBJECT_LIB_TABLE?=$(SUBJECT_RNA_LIB_TABLE)
endif

SUBJECT_LIB_IDS?=$(shell cat $(SUBJECT_LIB_IDS_FILE))

# base and post table
SUBJECT_LIB_DEF_TABLE?=$(SUBJECT_DIR)/lib_defs.txt

# explode base and post ids
SUBJECT_BASE_IDS_FILE?=$(SUBJECT_DIR)/base_ids
SUBJECT_MID_IDS_FILE?=$(SUBJECT_DIR)/mid_ids
SUBJECT_POST_IDS_FILE?=$(SUBJECT_DIR)/post_ids

SUBJECT_BASE_IDS?=$(shell cat $(SUBJECT_BASE_IDS_FILE))
SUBJECT_MID_IDS?=$(shell cat $(SUBJECT_MID_IDS_FILE))
SUBJECT_POST_IDS?=$(shell cat $(SUBJECT_POST_IDS_FILE))

# shortcut start from trimmo results
TEMPO_R1?=$(TRIMMOMATIC_OUTDIR)/R1.fastq
TEMPO_R2?=$(TRIMMOMATIC_OUTDIR)/R2.fastq

# dry run
DRY?=F
