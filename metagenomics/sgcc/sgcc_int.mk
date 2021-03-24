units=sgcc.mk
$(call _register_module,sgcc,$(units),)

#####################################################################################################
# basic input/output
#####################################################################################################

# contig fasta
SGCC_INPUT_FASTQ?=$(PAIRED_R1)

# table with Meas_Type (MetaG|MetaT), lib, and subject.id
SGCC_SAMPLE_TABLE_IN?=$(TEMPO_COHORT_SAMPLE_TABLE)
SGCC_SAMPLE_TYPE?=MetaG

# use only up to million reads from each library
SGCC_FASTQ_MREADS?=2

# output dir
SGCC_TAG?=$(SGCC_SAMPLE_TYPE)_$(SGCC_FASTQ_MREADS)M
SGCC_DIR?=$(BASE_OUTPUT_DIR)/sgcc/$(SGCC_TAG)

# all lib ids
SGCC_LIB_IDS_FILE?=$(SGCC_DIR)/lib_ids
SGCC_IDS?=$(shell cat $(SGCC_LIB_IDS_FILE))

#####################################################################################################
# docker wrapper
#####################################################################################################

SOURMASH=dr run -i sourmash sourmash

#####################################################################################################
# get input sequence
#####################################################################################################

SGCC_INPUT_DIR?=$(SGCC_DIR)/input
SGCC_FASTQ_COUNT=$(shell echo $(SGCC_FASTQ_MREADS)\*4000000 | bc)
SGCC_FASTQ?=$(SGCC_INPUT_DIR)/$(LIB_ID).fq

#####################################################################################################
# construct hash per library
#####################################################################################################

SGCC_KMER_SIG?=31

SGCC_SIG_DIR?=$(SGCC_DIR)/sig
SGCC_SIG?=$(SGCC_SIG_DIR)/$(LIB_ID).sig

#####################################################################################################
# compare
#####################################################################################################

SGCC_KMER_COMPARE?=31

SGCC_COMPARE_TABLE=$(SGCC_DIR)/matrix.tab
