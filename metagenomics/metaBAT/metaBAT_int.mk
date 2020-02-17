#####################################################################################################
# register module
#####################################################################################################

units:=metaBAT_main.mk metaBAT_prep.mk metaBAT_post.mk metaBAT_plot.mk
$(call _register_module,metaBAT,$(units),)

#####################################################################################################
# general parameters
#####################################################################################################

METABAT_VER?=v1
METABAT_DIR?=$(ASSEMBLY_DIR)/metaBAT/$(METABAT_VER)

# input assembly fasta
METABAT_IN_CONTIGS?=$(ASSEMBLY_CONTIG_FILE)

# input contig table
METABAT_IN_CONTIG_TABLE?=$(ASSEMBLY_CONTIG_TABLE)

# figures
METABAT_FDIR?=$(BASE_FDIR)/metaBAT

# we copy the fasta here
METABAT_CONTIGS?=$(METABAT_DIR)/contigs.fa

#####################################################################################################
# prep
#####################################################################################################

# index dir
METABAT_INDEX_DIR?=$(METABAT_DIR)/bwa_index
METABAT_INDEX_PREFIX?=$(METABAT_INDEX_DIR)/idx

# lib working dir
METABAT_ID?=sg
METABAT_LIB_DIR?=$(METABAT_DIR)/libs/$(METABAT_ID)

# bwa
METABAT_BWA?=/home/eitany/work/download/bwa-0.7.12/bwa
METABAT_SAMTOOLS?=/home/eitany/work/tools/bin/samtools

# threads
METABAT_IO_THREADS?=20

# two input fastq files
METABAT_IN_DIR?=/relman02/data/relman/gut_hic/assembly
METABAT_IN_R1?=$(wildcard $(METABAT_IN_DIR)/*R1*)
METABAT_IN_R2?=$(wildcard $(METABAT_IN_DIR)/*R2*)

METABAT_OFFSET?=0
METABAT_LENGTH?=40
METABAT_FASTQ?=$(METABAT_LIB_DIR)/reads.fq

# output
METABAT_LIB_BAM?=$(METABAT_LIB_DIR)/output.bam

#####################################################################################################
# run over bam files creates for a bunch of libs
#####################################################################################################

METABAT_SUB_VER?=all
METABAT_WORK_DIR?=$(METABAT_DIR)/output/$(METABAT_SUB_VER)

# use these libs
METABAT_MERGE_IDS?=$(METABAT_ID)
METABAT_BAMS?=$(addsuffix /output.bam,$(addprefix /work/libs/,$(METABAT_MERGE_IDS)))

METABAT_WORK_CONTIGS?=$(METABAT_WORK_DIR)/contigs.fa

#####################################################################################################
# metabat docker setup
#####################################################################################################

METABAT_DCKR_PROFILE=$(METABAT_DIR)/dckr_profile

# metaBAT min bin size
METABAT_MIN_BIN_SIZE?=5000
METABAT_MIN_CONTIG_SIZE?=2500
METABAT_THREADS?=40

# for reproducibility
METABAT_SEED?=1

METABAT_IMAGE=metabat/metabat:latest
METABAT_PARAMS=-v /etc/passwd:/etc/passwd -v /etc/shadow:/etc/shadow -v /etc/group:/etc/group
METABAT_DOCKER?=sudo dckr run -r $(METABAT_DIR) -p dckr_profile -i $(METABAT_IMAGE) nice -n 10

#####################################################################################################
# process metaBAT results
#####################################################################################################

# contig depth table
METABAT_DEPTH_TABLE?=$(METABAT_WORK_DIR)/depth.txt

# raw table of contigs/bins
METABAT_TABLE_RAW?=$(METABAT_WORK_DIR)/contig_raw.table

# raw bin summary table
METABAT_BIN_TABLE_RAW?=$(METABAT_WORK_DIR)/bin_raw.table

#####################################################################################################
# compute inter and intra cluster scores
#####################################################################################################

# metaBAT contig/bin table
METABAT_TABLE_RAW?=$(METABAT_WORK_DIR)/contig.table

# contig vectors
METABAT_CONTIG_VECTORS?=$(METABAT_WORK_DIR)/contig_vectors

# centroid vectors
METABAT_CENTROID_VECTORS?=$(METABAT_WORK_DIR)/centroid_vectors

#####################################################################################################
# filter out low quality contigs and bins
#####################################################################################################

# compute modified z-score per bin using the mean and sd computed on percentiles 10%-90%
# if there are at least 10 contigs in the bin, or all contigs otherwise.
METABAT_CONTIG_SCORE?=$(METABAT_WORK_DIR)/contig_score

# min contig-bin pearson
METABAT_MIN_SCORE?=0.95

# min contig-bin zscore
METABAT_MIN_ZSCORE?=-3

# max fraction of discarded bin
METABAT_MAX_DISCARD_FRACTION?=0.2

METABAT_CONTIG_SELECTED?=$(METABAT_WORK_DIR)/contig_selected
METABAT_BIN_SELECTED?=$(METABAT_WORK_DIR)/bin_selected

#####################################################################################################
# final tables
#####################################################################################################

# final table of contigs/bins
METABAT_TABLE?=$(METABAT_WORK_DIR)/contig_final.table

# bin summary table
METABAT_BIN_TABLE?=$(METABAT_WORK_DIR)/bin_final.table

