#####################################################################################################
# register module
#####################################################################################################

units:=metaBAT.mk mb_adaptor.mk
$(call _register_module,metaBAT,$(units),)

#####################################################################################################
# general parameters
#####################################################################################################

METABAT_VER?=v1
METABAT_DIR?=$(ASSEMBLY_DIR)/metaBAT/$(METABAT_VER)

# input assembly fasta
METABAT_IN_CONTIGS?=$(ASSEMBLY_CONTIG_FILE)

# we copy the fasta here
METABAT_CONTIGS?=$(METABAT_DIR)/contigs.fa

#####################################################################################################
# mb_map.mk
#####################################################################################################

# index dir
METABAT_INDEX_DIR?=$(ASSEMBLY_DIR)/map_index/bwa
METABAT_INDEX_PREFIX?=$(METABAT_INDEX_DIR)/idx

# working dir
METABAT_ID?=sg
METABAT_LIB_DIR?=$(METABAT_DIR)/libs/$(METABAT_ID)

# bwa
METABAT_BWA?=/home/eitany/work/download/bwa-0.7.12/bwa
METABAT_SAMTOOLS?=/home/eitany/work/tools/bin/samtools

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

METABAT_LABEL?=all
METABAT_WORK_DIR?=$(METABAT_DIR)/output/$(METABAT_LABEL)

METABAT_CHECKM_DIR?=$(METABAT_WORK_DIR)/checkm

# use these libs
METABAT_MERGE_IDS?=$(METABAT_ID)
METABAT_BAMS?=$(addsuffix /output.bam,$(addprefix /work/libs/,$(METABAT_MERGE_IDS)))

#####################################################################################################
# metabat docker setup
#####################################################################################################

# metaBAT min bin size
METABAT_MIN_SIZE?=5000
METABAT_THREADS?=40

# for reproducibility
METABAT_SEED?=1

METABAT_IMAGE=metabat/metabat:latest
METABAT_PARAMS=-v /etc/passwd:/etc/passwd -v /etc/shadow:/etc/shadow -v /etc/group:/etc/group
METABAT_DOCKER?=\
docker run --rm -it \
-v $(METABAT_DIR):/work \
-u $(USER) \
$(METABAT_PARAMS) \
$(METABAT_IMAGE)

#####################################################################################################
# raw results
#####################################################################################################

# table of contigs/bins
METABAT_TABLE?=$(METABAT_WORK_DIR)/contig.table

# bin summary table
METABAT_BIN_TABLE?=$(METABAT_WORK_DIR)/bin.table

#####################################################################################################
# run checkm and select genomes
#####################################################################################################

# adding checkm required fields
METABAT_BIN_TABLE_CHECKM?=$(METABAT_WORK_DIR)/bin_checkm.table

# minimal binsize for checkm
METABAT_SELECT_BINSIZE?=200000
METABAT_CHECKM_FASTA_DIR?=$(METABAT_WORK_DIR)/checkm_input_fasta_dir

# select draft-quality genome bins
METABAT_MIN_GENOME_COMPLETE?=50
METABAT_MAX_GENOME_CONTAM?=10

# select elements
METABAT_MAX_ELEMENT_COMPLETE?=10

# final genome bins
METABAT_GENOME_TABLE?=$(METABAT_WORK_DIR)/genome.table
METABAT_CG?=$(METABAT_WORK_DIR)/contig-genome.table

# final elements
METABAT_ELEMENT_TABLE?=$(METABAT_WORK_DIR)/element.table
METABAT_CE?=$(METABAT_WORK_DIR)/contig-element.table

# united set table (set/type/contig/start/end)
METABAT_SEGMENTS?=$(METABAT_WORK_DIR)/cr_segments
METABAT_SETS?=$(METABAT_WORK_DIR)/cr_sets

#####################################################################################################
# adaptor for taxa
#####################################################################################################

# gene-bin
METABAT_GG?=$(METABAT_WORK_DIR)/gene-genome.table

# required for taxa
METABAT_DUMMY_ATABLE?=$(METABAT_WORK_DIR)/dummy.atable
METABAT_DUMMY_CA?=$(METABAT_WORK_DIR)/dummy.ca

#####################################################################################################
# adaptor for evolve
#####################################################################################################

METABAT_ADAPTOR_DIR?=$(METABAT_WORK_DIR)/adaptor

# list of binnded genes (gene/type/bin)
METABAT_GENE_TABLE?=$(METABAT_ADAPTOR_DIR)/gene.table

METABAT_CORE_TABLE?=$(METABAT_ADAPTOR_DIR)/core.table
METABAT_CORE_GENES?=$(METABAT_ADAPTOR_DIR)/gene2core.table

# elements
METABAT_ELEMENT_TABLE?=$(METABAT_ADAPTOR_DIR)/element.table
METABAT_GENE_ELEMENT?=$(METABAT_ADAPTOR_DIR)/gene2element.table

#####################################################################################################
# figures
#####################################################################################################

METABAT_FDIR?=$(ANCHOR_FIGURE_DIR)/metaBAT/$(METABAT_VER)/$(METABAT_LABEL)

