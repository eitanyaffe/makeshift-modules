#####################################################################################################
# register module
#####################################################################################################

units:=cag.mk
$(call _register_module,cag,$(units),,)

TRANSEQ?=/relman02/tools/EMBOSS-6.6.0/emboss/transeq

#####################################################################################################
# Catalog
#####################################################################################################

CATALOG_ID?=Nielsen
OMIT_MGS?=F

# input genes and associated CAGs
CATALOG_INPUT_GENES?=$(CATALOG_INPUT_DIR)/CAG_map

# sequence of CAGs
CATALOG_INPUT_FILES?=$(CATALOG_INPUT_DIR)/files

# cag table (not used)
SMALL_CAG_TABLE?=$(CATALOG_INPUT_DIR)/small_CAG_table

# CAG-CAG dependency table
CATALOG_INPUT_DEPEND_TABLE?=$(CATALOG_INPUT_DIR)/CAG_depend

# catalog directory
CATALOG_DIR?=$(OUTPUT_DIR)/$(CATALOG_ID)

# united fasta file
CATALOG_FASTA?=$(CATALOG_DIR)/catalog.fasta
CATALOG_FASTA_AA?=$(CATALOG_DIR)/catalog_aa.fasta

# map from gene to entity (CAG)
CATALOG_GENE_TABLE?=$(CATALOG_DIR)/gene_table

#####################################################################################################
# uniref annotation of cags
#####################################################################################################

CATALOG_TAXA_DIR?=$(CATALOG_DIR)/taxa
CATALOG_TAXA?=$(CATALOG_TAXA_DIR)/table

#####################################################################################################
# kcube summary over CAGs
#####################################################################################################

CAG_SUMMARY?=$(CATALOG_DIR)/cag.table

CAG_SELECTION_ID?=top
CAG_MIN_FRACTION?=0.5
CAG_MIN_IDENTITY?=0.9
CAG_MIN_XCOV?=1
CAG_SELECTION_FORCE?=NA
CAG_SELECTION_DIR?=$(CATALOG_DIR)/selection/$(CAG_SELECTION_ID)

CAG_SUMMARY_SELECT?=$(CAG_SELECTION_DIR)/cag_select
CAG_SUMMARY_SELECT_GENES?=$(CAG_SELECTION_DIR)/genes_select
CAG_SUMMARY_SELECT_GENES_FASTA?=$(CAG_SELECTION_DIR)/genes_select.fasta

# matrix analysis
CUBE_ASSEMBLY_ID?=CAGs
CUBE_ASSEMBLY_FILE?=$(CATALOG_FASTA)
CUBE_GENOME_INPUT_TABLE?=$(CAG_SUMMARY_SELECT_GENES)
CUBE_GENOME_INPUT_GENE_FIELD?=gene
CUBE_GENOME_INPUT_GENOME_FIELD?=cag
CUBE_GENOME_ID?=cags

# snp analysis
CUBE_ASSEMBLY_SNP_ID?=CAGs_selected
CUBE_ASSEMBLY_SNP_FILE?=$(CAG_SUMMARY_SELECT_GENES_FASTA)
CUBE_ASSEMBLY_SNP_TABLE?=$(CAG_SUMMARY_SELECT_GENES)

CUBE_ASSEMBLY_SNP_DIR?=$(CAG_SELECTION_DIR)/kcube

# variables for kcube
CUBE_ASSEMBLY_BASE_DIR=$(CUBE_ASSEMBLY_SNP_DIR)
CUBE_ASSEMBLY_ID=$(CUBE_ASSEMBLY_SNP_ID)
CUBE_ASSEMBLY_FILE=$(CUBE_ASSEMBLY_SNP_FILE)
CUBE_ASSEMBLY_TABLE=$(CUBE_ASSEMBLY_SNP_TABLE)
CUBE_ASSEMBLY_TABLE_FIELD=gene

CUBE_SNP_INPUT_TYPE=table
CUBE_LIB_ID=NA
