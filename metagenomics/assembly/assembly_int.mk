#####################################################################################################
# register module
#####################################################################################################

units:=megahit.mk spades.mk

$(call _register_module,assembly,$(units),)

#####################################################################################################
# general parameters
#####################################################################################################

ASSEMBLER?=megahit
ASSEMBLY_ID?=assembly1
ASSEMBLY_BASE_DIR?=$(OUTPUT_DIR)/assembly/$(ASSEMBLY_ID)
ASSEMBLY_DIR?=$(ASSEMBLY_BASE_DIR)/$(ASSEMBLER)

# shortcuts
MEGAHIT_DIR?=$(ASSEMBLY_BASE_DIR)/megahit
SPADES_DIR?=$(ASSEMBLY_BASE_DIR)/spades

# by defaulty all libs are used for the assebmly
ASSEMBLY_LIB_IDS?=$(LIB_IDS)

# use only files which match pattern
ASSEMBLY_INPUT_NAME_PATTERN?=$(DECONSEQ_PATTERN)

# command that cats the fastq files
ASSEMBLY_INPUT_DIRS?=$(addsuffix /final,$(addprefix $(LIBS_DIR)/,$(ASSEMBLY_LIB_IDS)))
ASSEMBLY_INPUT_R1?=$(addsuffix /R1.fastq,$(ASSEMBLY_INPUT_DIRS))
ASSEMBLY_INPUT_R2?=$(addsuffix /R2.fastq,$(ASSEMBLY_INPUT_DIRS))
ASSEMBLY_INPUT_FILES?=$(ASSEMBLY_INPUT_R1) $(ASSEMBLY_INPUT_R2)
ASSEMBLY_INPUT_CMD=cat $(ASSEMBLY_INPUT_FILES)

# output
FULL_CONTIG_FILE?=$(ASSEMBLY_DIR)/contigs
FULL_CONTIG_TABLE?=$(ASSEMBLY_DIR)/contig_table

# select long contigs
ASSEMBLY_MIN_LEN?=1000
ASSEMBLY_CONTIG_FILE?=$(ASSEMBLY_DIR)/long_contigs
ASSEMBLY_CONTIG_TABLE?=$(ASSEMBLY_DIR)/long_contig_table

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
