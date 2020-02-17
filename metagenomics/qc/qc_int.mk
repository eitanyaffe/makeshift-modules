#####################################################################################################
# register module
#####################################################################################################

units:=qc_basic.mk qc_collect.mk qc_plot.mk

$(call _register_module,qc,$(units),)

#####################################################################################################
# input
#####################################################################################################

QC_IN_SAMPLE_TABLE?=$(CURDIR)/tables/cipro/complete_sample_table.txt
QC_IN_FASTQ_DIR?=/relman04/projects/cipro

#####################################################################################################
# main directories
#####################################################################################################

QC_DIR?=$(OUTPUT_DIR)/qc
LIB_DIR?=$(QC_DIR)/$(LIB_ID)
QC_FDIR?=$(OUTPUT_DIR)/figures_qc

QC_SUMMARY_DIR?=$(BASE_OUTPUT_DIR)/qc
QC_SUMMARY_FDIR?=$(BASE_OUTPUT_DIR)/figures/qc

#####################################################################################################
# dup stats
#####################################################################################################

QC_LIB_GZ_R1?=/relman04/projects/cipro/EBX_55-DNA_61_D10-LIB_12_H6-reprep_S324_R1_001.fastq.gz
QC_LIB_GZ_R2?=/relman04/projects/cipro/EBX_55-DNA_61_D10-LIB_12_H6-reprep_S324_R2_001.fastq.gz

QC_LIB_DIR?=$(QC_DIR)/$(LIB_ID)
QC_LIB_INPUT_DIR?=$(QC_LIB_DIR)/input
QC_LIB_R1?=$(QC_LIB_INPUT_DIR)/R1.fastq
QC_LIB_R2?=$(QC_LIB_INPUT_DIR)/R2.fastq

#####################################################################################################
# collect results from all libs
#####################################################################################################

QC_COUNT_FIELDS?=input trimmomatic dups
QC_COUNT_SUMMARY?=$(QC_SUMMARY_DIR)/counts

QC_YIELD_SUMMARY?=$(QC_SUMMARY_DIR)/yields
