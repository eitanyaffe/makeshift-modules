#####################################################################################################
# register module
#####################################################################################################

units:=\
duplicates.mk trimmomatic.mk split.mk deconseq.mk pair.mk stats_metabase.mk \
megahit.mk prodigal.mk kraken.mk spades.mk

$(call _register_module,metabase,$(units),)

LIB_DIR?=$(METABASE_OUTPUT_DIR)/libs/$(LIB_ID)

#####################################################################################################
# stats
#####################################################################################################

FREE_PREFIX='*'
FREE_SUFFIX='*'

PP_COUNT_INPUT?=$(LIB_DIR)/.count_input
PP_COUNT_DUPS?=$(LIB_DIR)/.count_dups
PP_COUNT_TRIMMOMATIC?=$(LIB_DIR)/.count_trimmomatic
PP_COUNT_DECONSEQ?=$(LIB_DIR)/.count_deconseq
LIB_COMPLEXITY_TABLE?=$(LIB_DIR)/complexity.table

#####################################################################################################
# duplicates.mk
#####################################################################################################

# files: LIB_INPUT_R1 and LIB_INPUT_R2
# dir: LIB_INPUT_DIRS
LIB_INPUT_STYLE?=dir
INPUT_FILE_SUFFIX?=fastq

DUP_DIR=$(LIB_DIR)/dup
DUP_R1?=$(DUP_DIR)/R1.fastq
DUP_R2?=$(DUP_DIR)/R2.fastq

#####################################################################################################
# trimmomatic.mk
#####################################################################################################

TRIMMOMATIC_VER?=0.38
TRIMMOMATIC_BASEDIR?=/home/eitany/work/download
TRIMMOMATIC_DIR?=$(TRIMMOMATIC_BASEDIR)/Trimmomatic-$(TRIMMOMATIC_VER)
TRIMMOMATIC_JAR?=$(TRIMMOMATIC_DIR)/trimmomatic-$(TRIMMOMATIC_VER).jar

# parameters
TRIMMOMATIC_ADAPTER_SFN?=NexteraPE-PE.fa
TRIMMOMATIC_ADAPTER_FN?=$(TRIMMOMATIC_DIR)/adapters/$(TRIMMOMATIC_ADAPTER_SFN)
TRIMMOMATIC_MODE?=PE
TRIMMOMATIC_THREADS?=10
TRIMMOMATIC_LEADING?=20
TRIMMOMATIC_TRAILING?=3
TRIMMOMATIC_ILLUMINACLIP?=2:30:10:1:true
TRIMMOMATIC_MAXINFO?=60:0.1

# input/output
TRIMMOMATIC_IN_R1?=$(DUP_R1)
TRIMMOMATIC_IN_R2?=$(DUP_R2)
TRIMMOMATIC_OUTDIR?=$(LIB_DIR)/trimmomatic

TRIMMOMATIC_PAIRED_R1?=$(TRIMMOMATIC_OUTDIR)/paired_R1.fastq
TRIMMOMATIC_NONPAIRED_R1?=$(TRIMMOMATIC_OUTDIR)/nonpaired_R1.fastq
TRIMMOMATIC_PAIRED_R2?=$(TRIMMOMATIC_OUTDIR)/paired_R2.fastq
TRIMMOMATIC_NONPAIRED_R2?=$(TRIMMOMATIC_OUTDIR)/nonpaired_R2.fastq

#####################################################################################################
# split.mk
#####################################################################################################

LIB_SPLIT_DIR=$(LIB_DIR)/split

# reads per chunk
SPLIT_SIZE?=10000000

SPLIT_INPUT_R1?=$(TRIMMOMATIC_PAIRED_R1)
SPLIT_INPUT_R2?=$(TRIMMOMATIC_PAIRED_R2)

#####################################################################################################
# deconseq.mk
#####################################################################################################

DECONSEQ_BIN_DIR?=/relman01/shared/tools/deconseq-standalone-0.4.3/
DECONSEQ_SCRIPT?=$(DECONSEQ_BIN_DIR)/deconseq.pl

# input
DECONSEQ_IDIR=$(LIB_SPLIT_DIR)

# Alignment coverage threshold in percentage
DECONSEQ_COVERAGE?=10

# Alignment identity threshold in percentage
DECONSEQ_IDENTITY?=80

# jobs
DECONSEQ_MAX_JOBS?=2

# threads
DECONSEQ_THREADS?=30

# Name of deconseq database to use (human)
DECONSEQ_DBS?=hsref

# output
DECONSEQ_DIR=$(LIB_DIR)/remove_human
DECONSEQ_QSUB_DIR?=$(QSUB_LIB_DIR)/remove_human

DECONSEQ_PATTERN?=*clean.fq

#####################################################################################################
# final paired reads
#####################################################################################################

FINAL_LIB_DIR=$(LIB_DIR)/final
PAIRED_BOTH_DIR?=$(FINAL_LIB_DIR)/pairs
PAIRED_R1_DIR?=$(FINAL_LIB_DIR)/only_R1
PAIRED_R2_DIR?=$(FINAL_LIB_DIR)/only_R2

# one united paired file
PAIRED_R1?=$(FINAL_LIB_DIR)/R1.fastq
PAIRED_R2?=$(FINAL_LIB_DIR)/R2.fastq

# distrib
PAIRED_QSUB_DIR?=$(QSUB_LIB_DIR)/paired
PAIRED_MAX_JOBS?=2

#####################################################################################################
# general assembly
#####################################################################################################

ASSEMBLER?=megahit
ASSEMBLY_ID?=assembly1
ASSEMBLY_BASE_DIR?=$(METABASE_OUTPUT_DIR)/assembly/$(ASSEMBLY_ID)
ASSEMBLY_DIR?=$(ASSEMBLY_BASE_DIR)/$(ASSEMBLER)

# shortcuts
MEGAHIT_DIR?=$(ASSEMBLY_BASE_DIR)/megahit
SPADES_DIR?=$(ASSEMBLY_BASE_DIR)/spades

# which samples go into assembly?
ASSEMBLY_LIB_IDS?=$(LIB_IDS_SELECTED)

# use only files which match pattern
ASSEMBLY_INPUT_NAME_PATTERN?=$(DECONSEQ_PATTERN)

# command that cats the fastq files
ASSEMBLY_INPUT_DIRS?=$(addsuffix /final/pairs,$(addprefix $(METABASE_OUTPUT_DIR)/libs/,$(ASSEMBLY_LIB_IDS)))
ASSEMBLY_INPUT_FILES?=$(shell find $(ASSEMBLY_INPUT_DIRS) -name $(ASSEMBLY_INPUT_NAME_PATTERN))
ASSEMBLY_INPUT_CMD=cat $(ASSEMBLY_INPUT_FILES)

# output
FULL_CONTIG_FILE?=$(ASSEMBLY_DIR)/contigs
FULL_CONTIG_TABLE?=$(ASSEMBLY_DIR)/contig_table

# select long contigs
ASSEMBLY_MIN_LEN?=1000
ASSEMBLY_CONTIG_FILE?=$(ASSEMBLY_DIR)/long_contigs
ASSEMBLY_CONTIG_TABLE?=$(ASSEMBLY_DIR)/long_contig_table

# by default use assembly contigs 
CONTIG_FILE?=$(ASSEMBLY_CONTIG_FILE)
CONTIG_TABLE?=$(ASSEMBLY_CONTIG_TABLE)

#####################################################################################################
# spades.mk
#####################################################################################################

SPADES_BIN?=/home/eitany/work/download/SPAdes-3.12.0-Linux/bin/spades.py

SPADE_YAML?=$(SPADES_DIR)/input.yaml

SPADE_THREADS?=40

# max mem in Gb
SPADE_MEM?=500

#####################################################################################################
# megahit.mk
#####################################################################################################

MEGAHIT_BIN?=/home/dethlefs/bin/megahit

MEGAHIT_MEMORY_CAP?=0.5

MEGAHIT_MIN_CONTIG_LENGTH?=300

MEGAHIT_MIN_KMER?=27
MEGAHIT_MAX_KMER?=147
MEGAHIT_KMER_STEP?=10

# other parameters here:
MEGAHIT_MISC?=--merge-level 20,0.95

MEGAHIT_FASTG?=$(MEGAHIT_DIR)/k$(MEGAHIT_MAX_KMER).fastg

#####################################################################################################
# prodigal.mk
#####################################################################################################

PRODIGAL_BIN?=/home/dethlefs/Prodigal_2.6.3/prodigal

# directory
PRODIGAL_VER?=v1
PRODIGAL_DIR?=$(ASSEMBLY_DIR)/prodigal/$(PRODIGAL_VER)

# parameters: https://github.com/hyattpd/prodigal/wiki/cheat-sheet
PRODIGAL_SELECT_PROCEDURE?=meta

# i/o
PRODIGAL_INPUT?=$(CONTIG_FILE)
PRODIGAL_AA?=$(PRODIGAL_DIR)/genes.faa
PRODIGAL_NT?=$(PRODIGAL_DIR)/genes.fna
PRODIGAL_OUTPUT_RAW?=$(PRODIGAL_DIR)/prodigal.out

#####################################################################################################
# kraken.mk
#####################################################################################################

# doc: https://ccb.jhu.edu/software/kraken2
# code: https://github.com/DerrickWood/kraken2

KRAKEN_BIN_DIR?=/relman02/users/eitany/tools/kraken2
KRAKEN_BIN?=$(KRAKEN_BIN_DIR)/kraken2
KRAKEN_BUILD_BIN?=$(KRAKEN_BIN_DIR)/kraken2-build

# kraken db
KRAKEN_VERSION?=February_27_2019
KRAKEN_DB_DIR?=$(METABASE_OUTPUT_DIR)/kraken_db/$(KRAKEN_VERSION)
KRAKEN_DB_THREADS?=10

# per lib
KRAKEN_THREADS?=40
KRAKEN_INPUT=$(wildcard $(DECONSEQ_DIR)/*clean.fq)

KRAKEN_VER?=v2
KRAKEN_DIR?=$(LIB_DIR)/kraken/$(KRAKEN_VER)
KRAKEN_OUTPUT?=$(KRAKEN_DIR)/out
KRAKEN_REPORT?=$(KRAKEN_DIR)/report

KRAKEN_MISC?=--use-names

# output files are table.{rank} where rank is P/D/C/O/F/G/S etc.
KRAKEN_MERGE_DIR?=$(METABASE_OUTPUT_DIR)/kraken/$(KRAKEN_VER)

#####################################################################################################
# stats_metabase.mk
#####################################################################################################

STATS_LABEL?=default
STATS_IDS?=$(LIB_IDS)
STATS_DIR?=$(METABASE_OUTPUT_DIR)/stats/$(STATS_LABEL)
STATS_COUNTS?=$(STATS_DIR)/counts.txt
STATS_YIELD?=$(STATS_DIR)/yield.txt
