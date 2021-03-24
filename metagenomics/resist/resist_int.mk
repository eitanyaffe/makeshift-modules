#####################################################################################################
# register module
#####################################################################################################

units:=resfams.mk card.mk
$(call _register_module,resist,$(units),)

#####################################################################################################

#####################################################################################################
# Resfams
#####################################################################################################

# input
#RESFAM_DB_DIR?=/home/eitany/work/tools/Resfams
RESFAM_DB_DIR?=/relman02/users/eitany/tools/Resfams
RESFAM_HMM?=$(RESFAM_DB_DIR)/Resfams-full.hmm
RESFAM_META?=$(RESFAM_DB_DIR)/resfams_180102_resfams_metadata_updated_v122.tab

HMMER_SEARCH?=/home/eitany/work/tools/hmmer/bin/hmmsearch

RESFAM_HMM_THREADS?=20

# output
RESFAMS_BASE_DIR?=$(ASSEMBLY_DIR)/resfams

RESFAMS_ID?=v1.2
RESFAMS_DIR?=$(RESFAMS_BASE_DIR)/$(RESFAMS_ID)
RESFAMS_RAW?=$(RESFAMS_DIR)/raw.tab
RESFAMS_TABLE$?=$(RESFAMS_DIR)/full.tab

RESFAMS_MIN_EVALUE?=0.0001
RESFAMS_MIN_BITSCORE?=30
RESFAMS_TABLE_SELECTED?=$(RESFAMS_DIR)/selected.tab

#####################################################################################################
# CARD
#####################################################################################################

#RGI_COMMAND=sudo dr run -i finlaymaguire/rgi:latest
#RGI_COMMAND=sudo dr run -i finlaymaguire/rgi:5.1.0
RGI_COMMAND=sudo dr run -i quay.io/biocontainers/rgi:4.2.2--py35ha92aebf_1

# input
CARD_DB_VERSION?=August_2020
#CARD_DB_VERSION?=April_2020
#CARD_DB_VERSION?=June_2018

CARD_DB_DIR?=/relman02/tools/CARD/$(CARD_DB_VERSION)
CARD_JSON?=$(CARD_DB_DIR)/data/card.json
CARD_ARO_INDEX?=$(CARD_DB_DIR)/data/aro_index.tsv
CARD_CATEGORIES_INDEX?=$(CARD_DB_DIR)/data/aro_categories_index.tsv

# output

CARD_VERSION?=v1
CARD_DIR?=$(ASSEMBLY_DIR)/CARD/$(CARD_VERSION)/$(CARD_DB_VERSION)
CARD_OUT_PREFIX?=$(CARD_DIR)/out
CARD_TABLE?=$(CARD_DIR)/out.txt
CARD_THREADS?=40

CARD_DRUG_TABLE?=$(CARD_DIR)/drug.table
CARD_MECH_TABLE?=$(CARD_DIR)/mech.table
CARD_AMR_TABLE?=$(CARD_DIR)/amr.table
CARD_MODEL_TABLE?=$(CARD_DIR)/model.table

########################################################################
# multiple subjects
########################################################################

COLLECT_IDS=S2_003 S2_005 S2_006 S2_009 S2_012 S2_018
CARD_COLLECT_DIR?=$(BASE_OUTPUT_DIR)/CARD

CARD_COLLECT_GENE_TABLE?=$(CARD_COLLECT_DIR)/gene.txt

CARD_COLLECT_ARO_TABLE?=$(CARD_COLLECT_DIR)/aro.txt

# one fasta file per per aro in this dir
CARD_FASTA_DIR?=$(CARD_COLLECT_DIR)/genes.dir

# cluster using cd-hit
CDHIT_BIN?=/home/eitany/work/git_root/cdhit/cd-hit-est
CDHIT_IDENTITY=0.999
CDHIT_DIR?=$(CARD_COLLECT_DIR)/cdhit_$(CDHIT_IDENTITY)

CDHIT_ARO?=3000206
CDHIT_ARO_CLUSTER_FILE?=$(CDHIT_DIR)/$(CDHIT_ARO).clstr

# aro / cluster / infant / gene / identity
CDHIT_ARO_TABLE?=$(CDHIT_DIR)/$(CDHIT_ARO).tab

# over all AROs
CDHIT_UNITED_ARO_TABLE?=$(CDHIT_DIR)/cdhit.tab

# highlight these AROs
ARO_HIGHLIGHT?=3000617 3000215 3003069 3002926 3004684 3004290 3000621

########################################################################
# figures
########################################################################

CARD_FDIR?=$(BASE_FIGURE_DIR)/CARD
