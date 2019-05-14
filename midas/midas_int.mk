
#####################################################################################################
# register module
#####################################################################################################

units=midas.mk midas_analysis.mk

$(call _register_module,midas,$(units),)

#####################################################################################################

# midas database
MIDAS_DB=/relman01/shared/databases/MIDAS_DB/midas_db_v1.2

MIDAS_SPECIES_INFO?=$(MIDAS_DB)/species_info.txt
MIDAS_GENOME_TAXA?=$(MIDAS_DB)/genome_taxonomy.txt

MIDAS_ID?=full
MIDAS_INPUT_PATTERN?=R*

#MIDAS_ID?=short
#MIDAS_INPUT_PATTERN?=R1_1.*

# MIDAS_ID?=medium
# MIDAS_INPUT_PATTERN=R1_1*
MIDAS_INPUT_DIR?=/relman03/work/users/eitany/bcc/cipro/libs_final/pre_lib_sg_simple

MIDAS_BASE_DIR?=$(ASSEMBLY_DIR)/midas
MIDAS_DIR?=$(MIDAS_BASE_DIR)/$(MIDAS_ID)

MIDAS_THREADS?=40

MIDAS_INPUT_FILES?=$(wildcard $(MIDAS_INPUT_DIR)/$(MIDAS_INPUT_PATTERN))

MIDAS_UNITED_INPUT?=$(MIDAS_DIR)/$(MIDAS_ID).fq

# midas docker
MIDAS_IMAGE=ummidock/midas_metagenomics:1.3.0
MIDAS_BASIC_PATHS?=-v /etc/passwd:/etc/passwd -v /etc/shadow:/etc/shadow -v /etc/group:/etc/group
MIDAS_PATHS?=-v $(MIDAS_DB):/data -v $(MIDAS_DIR):/work
MIDAS_DOCKER?=\
docker run --rm -it \
-u $(USER) \
$(MIDAS_BASIC_PATHS) \
$(MIDAS_PATHS) \
$(MIDAS_IMAGE)

MIDAS_PARAMS?=/work -1 /work/$(MIDAS_ID).fq -d /data -t $(MIDAS_THREADS)

MIDAS_SEQ_DIR?=$(MIDAS_DIR)/sequences

# MIDAS tables
MIDAS_TAXA?=$(MIDAS_DB)/genome_taxonomy.txt
MIDAS_GENOMES?=$(MIDAS_DB)/genome_info.txt

################################################################################
# merge
################################################################################

MIDAS_MERGE_IDS?=$(LIB_IDS)
MIDAS_MERGE_ID?=default
# MIDAS_MERGE_INPUT_DIRS?=$(addprefix $(MIDAS_BASE_DIR)/,$(MIDAS_MERGE_IDS))
MIDAS_MERGE_INPUT_DIRS?=$(addprefix /work/,$(MIDAS_MERGE_IDS))
MIDAS_MERGE_DIR?=$(MIDAS_BASE_DIR)/merge/$(MIDAS_MERGE_ID)
MIDAS_MERGE_PATHS=-v $(MIDAS_DB):/data -v $(MIDAS_MERGE_DIR):/output -v $(MIDAS_BASE_DIR):/work
MIDAS_MERGE_DOCKER?=\
docker run --rm -it \
-u $(USER) \
$(MIDAS_BASIC_PATHS) \
$(MIDAS_MERGE_PATHS) \
$(MIDAS_IMAGE)

################################################################################
# analysis
################################################################################

# ANALYSIS_VERSION?=all
# MIDAS_ANALYSIS_IDS?=$(LIB_IDS)

ANALYSIS_VERSION?=selected
MIDAS_ANALYSIS_IDS?=$(LIB_IDS_SELECTED)

MIDAS_ANALYSIS_DIR?=$(MIDAS_BASE_DIR)/analysis/$(ANALYSIS_VERSION)

# minimal abundance in any sample
MIDAS_MIN_ABUNDANCE?=0.01

# limited matrices
MIDAS_ABUNDANCE?=$(MIDAS_ANALYSIS_DIR)/relative_abundance.txt

# table with id and order
MIDAS_ORDER_TABLE?=NA

MIDAS_FDIR?=$(MIDAS_BASE_FDIR)/$(ANALYSIS_VERSION)
