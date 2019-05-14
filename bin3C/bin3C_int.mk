#####################################################################################################
# register module
#####################################################################################################

units:=bin3C.mk
$(call _register_module,bin3C,$(units),)

#####################################################################################################
# general parameters
#####################################################################################################

BIN3C_VER?=v1
BIN3C_DIR?=$(ASSEMBLY_DIR)/bin3C/$(BIN3C_VER)

# input assembly fasta
BIN3C_IN_CONTIGS?=$(CONTIG_FILE)

# we copy the fasta here
BIN3C_CONTIGS?=$(BIN3C_DIR)/contigs.fa

#####################################################################################################
# bin3C.mk
#####################################################################################################

# single index dir
BIN3C_INDEX_DIR?=$(BIN3C_DIR)/bwa
BIN3C_INDEX_PREFIX?=$(BIN3C_INDEX_DIR)/index

# working dir
BIN3C_ID?=hic
BIN3C_LIB_DIR?=$(BIN3C_DIR)/libs/$(BIN3C_ID)

# bwa
BIN3C_BWA?=/home/eitany/work/git_root/bwa/bwa
BIN3C_SAMTOOLS?=/home/eitany/work/tools/bin/samtools

# threads
BIN3C_BWA_THREADS?=20
BIN3C_SAMTOOLS_THREADS?=40

# two input fastq files
BIN3C_IN_DIR?=/relman04/projects/HiC/rawdata/cipro_pre_two_files
BIN3C_IN_R1?=$(wildcard $(BIN3C_IN_DIR)/*R1*)
BIN3C_IN_R2?=$(wildcard $(BIN3C_IN_DIR)/*R2*)

# bwa mapping
BIN3C_BWA_OUT?=$(BIN3C_LIB_DIR)/out.sam
BIN3C_BAM?=$(BIN3C_LIB_DIR)/out.bam

# docker
BIN3C_IMAGE=eitanyaffe/bin3c:latest
BIN3C_PARAMS=-v /etc/passwd:/etc/passwd -v /etc/shadow:/etc/shadow -v /etc/group:/etc/group
BIN3C_DOCKER?=\
docker run --rm -it \
-v $(BIN3C_DIR):/work \
-u $(USER) \
$(BIN3C_PARAMS) \
$(BIN3C_IMAGE)

# min non-self contacts of contig
BIN3C_MIN_SIGNAL?=5

# min size of cluster
BIN3C_MIN_CLUSTER_LENGTH?=100000

BIN3C_MAP_DIR?=$(BIN3C_LIB_DIR)/bin3c_map
BIN3C_CLUSTER_DIR?=$(BIN3C_LIB_DIR)/bin3c_cluster

# checkm
BIN3C_CHECKM_DIR?=$(BIN3C_LIB_DIR)/checkm

# contig-cluster table
BIN3C_CC_TABLE?=$(BIN3C_LIB_DIR)/cc_table

BIN3C_FDIR?=$(ANCHOR_FIGURE_DIR)/bin3C/$(BIN3C_VER)/$(BIN3C_ID)
