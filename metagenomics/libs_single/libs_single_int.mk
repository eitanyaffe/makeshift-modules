#####################################################################################################
# register module
#####################################################################################################

units:=duplicates.mk trimmomatic.mk split.mk deconseq.mk clean.mk stats_libs.mk

$(call _register_module,libs_single,$(units),)

LIBS_DIR?=$(OUTPUT_DIR)/libs
LIB_DIR?=$(LIBS_DIR)/$(LIB_ID)
LIBS_FDIR?=$(OUTPUT_DIR)/figures_libs

#####################################################################################################
# stats
#####################################################################################################

FREE_PREFIX='*'
FREE_SUFFIX='*'

PP_COUNT_INPUT?=$(LIB_DIR)/.count_input
PP_COUNT_TRIMMOMATIC?=$(LIB_DIR)/.count_trimmomatic
PP_COUNT_DUPS?=$(LIB_DIR)/.count_dups
PP_COUNT_DECONSEQ?=$(LIB_DIR)/.count_deconseq
PP_COUNT_FINAL?=$(LIB_DIR)/.count_final

#####################################################################################################
#####################################################################################################
# DNA library pipeline has 5 steps: (i)-(v)
#####################################################################################################
#####################################################################################################

#####################################################################################################
# (i) trimmomatic.mk
#####################################################################################################

############################################################################
# NOTE:
# to properly trim adapters, please remember to set TRIMMOMATIC_ADAPTER_SFN
# according to the way the library was prepared
############################################################################

# input
# files: LIB_INPUT_R
# dir: LIB_INPUT_DIRS
LIB_INPUT_STYLE?=dir
INPUT_FILE_SUFFIX?=fastq
TRIMMOMATIC_IN_R?=$(LIB_INPUT_R)
TRIMMOMATIC_IN_DIRS?=$(LIB_INPUT_DIRS)

TRIMMOMATIC_VER?=0.38
TRIMMOMATIC_BASEDIR?=/home/eitany/work/download
TRIMMOMATIC_DIR?=$(TRIMMOMATIC_BASEDIR)/Trimmomatic-$(TRIMMOMATIC_VER)
TRIMMOMATIC_JAR?=$(TRIMMOMATIC_DIR)/trimmomatic-$(TRIMMOMATIC_VER).jar

# lib-prep style
#   NexteraPE-PE.fa: Designed for Nextera
#   TruSeq3-PE-2.fa: Cover all TrueSeq options
TRIMMOMATIC_ADAPTER_SFN?=NexteraPE-PE.fa

TRIMMOMATIC_ADAPTER_FN?=$(TRIMMOMATIC_DIR)/adapters/$(TRIMMOMATIC_ADAPTER_SFN)
TRIMMOMATIC_MODE?=SE
TRIMMOMATIC_THREADS?=10
TRIMMOMATIC_LEADING?=20
TRIMMOMATIC_TRAILING?=3
TRIMMOMATIC_ILLUMINACLIP?=2:30:10:1:true
TRIMMOMATIC_MAXINFO?=60:0.1

TRIMMOMATIC_PARAMS?=\
ILLUMINACLIP:$(TRIMMOMATIC_ADAPTER_FN):$(TRIMMOMATIC_ILLUMINACLIP) \
LEADING:$(TRIMMOMATIC_LEADING) \
TRAILING:$(TRIMMOMATIC_TRAILING) \
MAXINFO:$(TRIMMOMATIC_MAXINFO) -phred33

# output
TRIMMOMATIC_OUTDIR?=$(LIB_DIR)/trimmomatic
TRIMMOMATIC_R?=$(TRIMMOMATIC_OUTDIR)/R.fastq

#####################################################################################################
# (ii) duplicates.mk
#####################################################################################################

DUP_DIR=$(LIB_DIR)/dup
DUP_INPUT_DIR?=$(TRIMMOMATIC_OUTDIR)

DUP_R?=$(DUP_DIR)/R.fastq

LIB_COMPLEXITY_TABLE?=$(LIB_DIR)/dup_complexity.table
LIB_SUMMARY_TABLE?=$(LIB_DIR)/dup_summary.table

#####################################################################################################
# (iii) split.mk
#####################################################################################################

LIB_SPLIT_DIR=$(LIB_DIR)/split

# reads per chunk
SPLIT_SIZE?=10000000

SPLIT_INPUT_R?=$(DUP_R)

#####################################################################################################
# (iv) deconseq.mk
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
DECONSEQ_MAX_JOBS?=6

# threads
DECONSEQ_THREADS?=10

# Name of deconseq database to use (human)
DECONSEQ_DBS?=hsref

# output
DECONSEQ_DIR=$(LIB_DIR)/remove_human
DECONSEQ_QSUB_DIR?=$(QSUB_LIB_DIR)/remove_human

DECONSEQ_PATTERN?=*clean.fq

#####################################################################################################
# (v) final paired reads
#####################################################################################################

FINAL_LIB_DIR=$(LIB_DIR)/final

# one united paired file
# NOTE: this is one sided, so R2 is empty 
PAIRED_R1?=$(FINAL_LIB_DIR)/R1.fastq
PAIRED_R2?=$(FINAL_LIB_DIR)/R2.fastq

#####################################################################################################
# stats_libs.mk
#####################################################################################################

LIB_STATS_FDIR?=$(BASE_FDIR)/lib_stats
STATS_COUNTS?=$(STATS_DIR)/counts.txt
STATS_YIELD?=$(STATS_DIR)/yield.txt

LIB_STATS_LABELS?=$(LIB_STATS_IDS)
