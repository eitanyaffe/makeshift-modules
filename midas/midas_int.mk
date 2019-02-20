
#####################################################################################################
# register module
#####################################################################################################

units=midas.mk

$(call _register_module,midas,$(units),)

#####################################################################################################

# midas database
MIDAS_DB=/relman01/shared/databases/MIDAS_DB/midas_db_v1.2

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
DOCKER_PARAMS=-v /etc/passwd:/etc/passwd -v /etc/shadow:/etc/shadow -v /etc/group:/etc/group
MIDAS_DOCKER?=\
docker run --rm -it \
-u $(USER) \
-v $(MIDAS_DB):/data \
$(DOCKER_PARAMS) \
-v $(MIDAS_DIR):/work \
$(MIDAS_IMAGE)

MIDAS_PARAMS?=/work -1 /work/$(MIDAS_ID).fq -d /data -t $(MIDAS_THREADS)

MIDAS_SEQ_DIR?=$(MIDAS_DIR)/sequences
