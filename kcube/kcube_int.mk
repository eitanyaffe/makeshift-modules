#####################################################################################################
# register module
#####################################################################################################

units:=hmp.mk kcube.mk kcube_matrix.mk kcube_genome.mk kcube_snps.mk midas.mk
$(call _register_module,kcube,$(units),,)

# left out: canopy.mk

#####################################################################################################
# HMP read libs
#####################################################################################################

HMP_INPUT?=/relman02/data/public/HMP/shotgun_healthy_gut

# all output for lib under this directory
HMP_DIR?=/relman01/projects/popvar/hmp

# number of unique subjects
HMP_LABEL?=all
HMP_LIB_COUNT?=0

# table with all library names
HMP_LIB_TABLE?=$(HMP_DIR)/lib_table_$(HMP_LABEL)

HMP_MAP_INPUT_COMMAND?=cat $(HMP_DIR)/$(LIB_ID)/*fastq

HMP_LIB_TABLE_FIELD?=run.id
HMP_SUBJECT_FIELD?=subject.id

#####################################################################################################
# EBI read libs
#####################################################################################################

EBI_SOURCE_DIR?=/relman04/data/public/EBI_human_gut_microbiome
EBI_LIB_TABLE?=$(EBI_SOURCE_DIR)/ERA000116.txt
EBI_INPUT_COMMAND?="gunzip -c $(EBI_SOURCE_DIR)/download/$(LIB_ID)_*gz"

EBI_LIB_TABLE_FIELD?=run_accession
EBI_SUBJECT_FIELD?=secondary_sample_accession

#####################################################################################################
# unite EBI and HMP
#####################################################################################################

UNITED_LIB_ID?=full
UNITED_LIB_DIR?=$(KCUBE_OUTPUT_DIR)/lib_tables
UNITED_LIB_TABLE?=$(UNITED_LIB_DIR)/$(UNITED_LIB_ID)
UNITED_LIB_TABLE_FIELD=id

#####################################################################################################
# general read libs
#####################################################################################################

# hmp|ebi|united
INPUT_TYPE?=united

# lib id
LIB_ID?=SRR514196

ifeq ($(INPUT_TYPE),hmp)
INPUT_COMMAND?=$(HMP_MAP_INPUT_COMMAND)
LIB_TABLE?=$(HMP_LIB_TABLE)
LIB_TABLE_FIELD?=$(HMP_LIB_TABLE_FIELD)
endif
ifeq ($(INPUT_TYPE),ebi)
INPUT_COMMAND?=$(EBI_INPUT_COMMAND)
LIB_TABLE?=$(EBI_LIB_TABLE)
LIB_TABLE_FIELD?=$(EBI_LIB_TABLE_FIELD)
endif
ifeq ($(INPUT_TYPE),united)
LIB_TABLE?=$(UNITED_LIB_TABLE)
LIB_TABLE_FIELD?=$(UNITED_LIB_TABLE_FIELD)
endif

#####################################################################################################
# kcube parameters
#####################################################################################################

CUBE_KSIZE?=16
CUBE_MAX_READS?=0

CUBE_BASE_DIR?=$(KCUBE_OUTPUT_DIR)/data
CUBE_DIR?=$(CUBE_BASE_DIR)/$(LIB_ID)
CUBE_FILE?=$(CUBE_DIR)/cube.k$(CUBE_KSIZE)

# multi libs
MAX_LIBS=0
MF?=NA
LIB_TARGET?=cube

#####################################################################################################
# project kcube onto assembly
#####################################################################################################

# minimal length of segment, when computing covered portion
CUBE_MIN_SEGMENT=14

# minimal kmer count, when computing covered portion
CUBE_MIN_COUNT=1

# check also edit-1 neighbours
ALLOW_SINGLE_SUB=F

CUBE_PROJECT_TAG?=s$(CUBE_MIN_SEGMENT)_c$(CUBE_MIN_COUNT)_a$(ALLOW_SINGLE_SUB)

CUBE_ASSEMBLY_ID?=NA
CUBE_ASSEMBLY_FILE?=NA

CUBE_ASSEMBLY_BASE_DIR?=$(KCUBE_OUTPUT_DIR)/assembly/$(CUBE_ASSEMBLY_ID)
CUBE_ASSEMBLY_DIR?=$(CUBE_ASSEMBLY_BASE_DIR)/$(CUBE_PROJECT_TAG)

CUBE_PROJECT_DIR?=$(CUBE_ASSEMBLY_DIR)/$(LIB_ID)
CUBE_SUMMARY_FILE?=$(CUBE_PROJECT_DIR)/summary
CUBE_BIN_DIR?=$(CUBE_PROJECT_DIR)/bins
CUBE_BINSIZES?=100 1000 10000 100000

CUBE_DETAIL_DIR?=$(CUBE_PROJECT_DIR)/details

#####################################################################################################
# snps summary over multiple tables
#####################################################################################################

# table or single lib
CUBE_SNP_INPUT_TYPE?=table
CUBE_SNP_SINLGE_LIB_ID?=NA
CUBE_SNP_MIN_COUNT?=4
CUBE_SNP_MIN_SEGMENT?=14

CUBE_SNP_BASE_DIR?=$(CUBE_ASSEMBLY_DIR)/snps/$(INPUT_TYPE)
CUBE_SNP_CUBE_TABLE?=$(CUBE_SNP_BASE_DIR)/cube_table
CUBE_SNP_DIR?=$(CUBE_SNP_BASE_DIR)/items


CUBE_SNP_BINS=10 100 1000
CUBE_SNP_BIN_DIR?=$(CUBE_SNP_BASE_DIR)/bins

#####################################################################################################
# subject/element matrix
#####################################################################################################

CUBE_MATRIX_ID?=$(INPUT_TYPE)_dataset

CUBE_MATRIX_VESRION?=v1

# minimal portion of gene that is covered
CUBE_MATRIX_MIN_IDENTITY?=0.8

# minimal median xcoverage
CUBE_MATRIX_MIN_XCOVERAGE?=2

CUBE_MATRIX_TAG?=p$(CUBE_MATRIX_MIN_IDENTITY)_x$(CUBE_MATRIX_MIN_XCOVERAGE)_$(CUBE_MATRIX_VESRION)

CUBE_MATRIX_BASE_DIR?=$(CUBE_ASSEMBLY_DIR)/matrix/$(CUBE_MATRIX_ID)
CUBE_MATRIX_DIR?=$(CUBE_MATRIX_BASE_DIR)/$(CUBE_MATRIX_TAG)

CUBE_MATRIX_XCOV_BASE?=$(CUBE_MATRIX_DIR)/xcov.mat
CUBE_MATRIX_IDENTITY_BASE?=$(CUBE_MATRIX_DIR)/identity.mat

CUBE_MATRIX_XCOV?=$(CUBE_MATRIX_DIR)/xcov_select.mat
CUBE_MATRIX_IDENTITY?=$(CUBE_MATRIX_DIR)/identity_select.mat
CUBE_ITEM_TABLE?=$(CUBE_MATRIX_DIR)/item_table

#####################################################################################################
# canopy clustering
#####################################################################################################

#CANOPY_DIR?=$(CUBE_MATRIX_DIR)/canopy
#CANOPY_INPUT?=$(CANOPY_DIR)/table
#CANOPY_CLUSTERS?=$(CANOPY_DIR)/clusters
#CANOPY_PROFILES?=$(CANOPY_DIR)/profiles
#CANOPY_PROGRESS?=$(CANOPY_DIR)/progress

#####################################################################################################
# contig/genome median profiles
#####################################################################################################

CUBE_GENOME_INPUT_BASE_DIR?=/relman03/work/users/eitany/bcc/cipro/assembly/pre_big_megahit/fold_0
CUBE_GENE_INPUT_TABLE?=$(CUBE_GENOME_INPUT_BASE_DIR)/genes/genes.txt

# use core genomes
CUBE_GENOME_INPUT_TABLE?=$(CUBE_GENOME_INPUT_BASE_DIR)//datasets/pre_lib_hic_u_simple/anchors/pre_hic_united_v2/uniref/db_uniref100_2018_02_field_anchor_maskCAG_F/seq_compare/gene.core
#CUBE_GENOME_INPUT_TABLE?=$(CUBE_GENOME_INPUT_BASE_DIR)/datasets/pre_lib_hic_u_simple/anchors/pre_hic_united_v2/ca_matrix/model_reg/genes

CUBE_GENOME_INPUT_GENE_FIELD?=gene
CUBE_GENOME_INPUT_GENOME_FIELD?=anchor

CUBE_GENOME_ID?=pre_v2
CUBE_GENOME_DIR?=$(CUBE_MATRIX_DIR)/genomes/$(CUBE_GENOME_ID)
CUBE_GENOME_PROFILE?=$(CUBE_GENOME_DIR)/genome_profile

# profile over all subjects
CUBE_CONTIG_PROFILE?=$(CUBE_GENOME_DIR)/contig_profile

# with prevalence
CUBE_CONTIG_SUMMARY?=$(CUBE_GENOME_DIR)/contig_summary

# pearson between gene profile and genome profile
CUBE_GENOME_CORE_SCORE?=$(CUBE_GENOME_DIR)/core_score

#####################################################################################################
# midas pan-genome analaysis
#####################################################################################################

MIDAS_PANGENOME_INPUT_BASE_DIR?=/relman01/shared/databases/MIDAS_DB/midas_db_v1.2/pan_genomes

MIDAS_PANGENOME_INPUT_DIR?=$(MIDAS_PANGENOME_INPUT_BASE_DIR)/$(CUBE_ASSEMBLY_ID)
MIDAS_REF_DIR?=$(CUBE_ASSEMBLY_BASE_DIR)/midas_files
