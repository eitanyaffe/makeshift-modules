#####################################################################################################
# register module
#####################################################################################################

units:=metaBAT_map.mk metaBAT.mk
$(call _register_module,metaBAT,$(units),)

#####################################################################################################
# general parameters
#####################################################################################################

METABAT_VER?=v1
METABAT_DIR?=$(ASSEMBLY_DIR)/metaBAT/$(METABAT_VER)

# input assembly fasta
METABAT_IN_CONTIGS?=$(CONTIG_FILE)

#####################################################################################################
# mb_map.mk
#####################################################################################################

# single index dir
METABAT_INDEX_DIR?=$(METABAT_DIR)/bwa
METABAT_INDEX_PREFIX?=$(METABAT_INDEX_DIR)/index

# working dir
METABAT_ID?=sg
METABAT_LIB_DIR?=$(METABAT_DIR)/libs/$(METABAT_ID)

# bwa
METABAT_BWA?=/home/eitany/work/download/bwa-0.7.12/bwa

# threads
METABAT_BWA_THREADS?=20
METABAT_SAMTOOLS_THREADS?=20

# two input fastq files
METABAT_IN_DIR?=/relman02/data/relman/gut_hic/assembly
METABAT_IN_R1?=$(wildcard $(METABAT_IN_DIR)/*R1*)
METABAT_IN_R2?=$(wildcard $(METABAT_IN_DIR)/*R2*)

# output
METABAT_LIB_BAM?=$(METABAT_LIB_DIR)/output.bam

#####################################################################################################
# run over bam files creates for a bunch of libs
#####################################################################################################

METABAT_LABEL?=single
METABAT_WORK_DIR?=$(METABAT_DIR)/work/$(METABAT_LABEL)

# use these libs
METABAT_IDS?=$(METABAT_ID)

#####################################################################################################
# metabat docker setup
#####################################################################################################

METABAT_IMAGE=metabat/metabat:latest
METABAT_PARAMS=-v /etc/passwd:/etc/passwd -v /etc/shadow:/etc/shadow -v /etc/group:/etc/group
METABAT_DOCKER?=\
docker run --rm -it \
-v $(METABAT_WORK_DIR):/work \
-u $(USER) \
$(METABAT_PARAMS) \
$(METABAT_IMAGE)

#####################################################################################################
# single coverage table
#####################################################################################################

METABAT_LIB_ID?=pre_lib_sg_simple
METABAT_SINGLE_COVERAGE_IN?=$(call reval,COVERAGE_TABLE,LIB_ID=$(METABAT_LIB_ID))

METABAT_SINGLE_DIR?=$(METABAT_DIR)/single
METABAT_SINGLE_DEPTH?=$(METABAT_SINGLE_DIR)/depth.txt

#####################################################################################################
# single coverage table
#####################################################################################################

# for read counts
METABAT_MULTI_COVERAGE_IN?=$(RESPONSE_CONTIG_OBSERVED)

METABAT_MULTI_DIR?=$(METABAT_DIR)/multi
METABAT_MULTI_DEPTH?=$(METABAT_MULTI_DIR)/depth.txt
