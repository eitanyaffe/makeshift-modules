
#####################################################################################################
# register module
#####################################################################################################

units=fends.mk model.mk trim_anchors.mk ca_map.mk \
set_cluster.mk anchor_cluster.mk ref_cluster.mk \
set_compare.mk cc_compare.mk anchor_info.mk \
ee_map.mk groups.mk anchor_variance.mk \
shared_analysis.mk model_cellular.mk

$(call _register_module,anchors,$(units),ccluster)

#####################################################################################################
# Fends
#####################################################################################################

# per assembly
FENDS_ASSEMBLY_DIR?=$(ASSEMBLY_DIR)/fends
FENDS_BASIC?=$(FENDS_ASSEMBLY_DIR)/$(CUTTER_TITLE).basic

# per dataset
FENDS_DIR?=$(CONTIG_MATRIX_DIR)/fends

# min abundance (log10 scale)
FENDS_MIN_RELATIVE_ABUNDANCE?=-2

FENDS_COVERAGE?=$(FENDS_DIR)/$(CUTTER_TITLE).coverage

# support a fixed reference fend table, used when comparing conditions
FENDS_USE_REF?=F
FENDS_REF_ID?=pre_lib_hic_u_simple
FENDS_REF_COVERAGE?=$(call reval,FENDS_COVERAGE,LIB_ID=$(FENDS_REF_ID))

CONTIG_FENDS_SUMMARY?=$(FENDS_DIR)/contig_summary.$(CUTTER_TITLE)

MAT_DIR?=$(CONTIG_MATRIX_DIR)/mat
MAT_SPLIT_DIR?=$(CONTIG_MATRIX_DIR)/mat_split
MAT_FILE?=$(MAT_DIR)/s0.mat

# discard facing reads where the ends face each other and are near.
# These probably lack a ligation junction
DISCARD_FACING_CIS_BELOW?=2000

# discard reads for which the infered segment is short. Relevant for
# the 6 cutter Hi-C variant
SEGMENT_LEN_THRESHOLD?=1000

#####################################################################################################
# model parameters
#####################################################################################################

MDL_FENDS?=$(FENDS_COVERAGE)
MDL_MAT?=$(MAT_FILE)

MDL_VERSION?=reg

#MDL_BINARY?=$(_md)/bin/model_integrate
MDL_BINARY?=$(_md)/bin.$(_binary_suffix)/model_integrate

# model plotting
BIAS_COLORS="black blue white red orange"
BIAS_BREAKS="-3 -1 0 1 3"

#####################################################################################################
# initial model (abundance only)
#####################################################################################################

# use the initial contig clustering
INIT_MDL_ANCHORS?=$(INITIAL_ANCHOR_TABLE)

INIT_MDL_ANCHOR_KEY?=contig
INIT_MDL_ANCHOR_VALUE?=cluster

# table with model parameters
INIT_MDL_MFN?=$(CURDIR)/input/models/abun_len.mdl

# output dir
INIT_MDL_DIR?=$(DATASET_ANCHOR_DIR)/initial_model_$(MDL_VERSION)

# output prefix for all model related files
INIT_MODEL_PREFIX?=$(INIT_MDL_DIR)/main

#####################################################################################################
# final model (abundance + fragment length)
#####################################################################################################

# use a final anchor table
FINAL_MDL_ANCHORS?=$(ANCHOR_TABLE)

# table with model parameters
FINAL_MDL_MFN?=$(CURDIR)/input/models/abun_len.mdl

# output dir
FINAL_MDL_DIR?=$(DATASET_ANCHOR_DIR)/final_model_$(MDL_VERSION)
FINAL_MODEL_PREFIX?=$(FINAL_MDL_DIR)/main

# cellular model
FINAL_CELLULAR_BASE_MDL_MFN?=$(FINAL_MDL_MFN)
FINAL_CELLULAR_MDL_DIR?=$(DATASET_ANCHOR_DIR)/final_cellular_model_$(MDL_VERSION)
FINAL_CELLULAR_MDL_MFN?=$(FINAL_CELLULAR_MDL_DIR)/cellular.mdl
FINAL_CELLULAR_MODEL_PREFIX?=$(FINAL_CELLULAR_MDL_DIR)/main

#####################################################################################################
# set model params according to current stage
#####################################################################################################

MDL_STAGE?=initial

####################################
ifeq ($(MDL_STAGE),initial)
####################################

MDL_ANCHORS=$(INIT_MDL_ANCHORS)
MDL_ANCHOR_KEY=$(INIT_MDL_ANCHOR_KEY)
MDL_ANCHOR_VALUE=$(INIT_MDL_ANCHOR_VALUE)
MDL_MFN=$(INIT_MDL_MFN)

MDL_SCOPE=inter_anchor

MDL_DIR=$(INIT_MDL_DIR)
MDL_QSUB=$(QSUB_ANCHOR_DIR)/initial_model_$(MDL_VERSION)

MDL_FDIR=$(ANCHOR_FIGURE_DIR)/models/initial

####################################
else ifeq ($(MDL_STAGE),final)
####################################

MDL_ANCHORS=$(FINAL_MDL_ANCHORS)
MDL_ANCHOR_KEY=contig
MDL_ANCHOR_VALUE=anchor
MDL_MFN=$(FINAL_MDL_MFN)

MDL_SCOPE=inter_anchor

MDL_DIR=$(FINAL_MDL_DIR)
MDL_QSUB=$(QSUB_ANCHOR_DIR)/final_model

MDL_FDIR=$(ANCHOR_FIGURE_DIR)/models/final

####################################
else ifeq ($(MDL_STAGE),final_cellular)
####################################

MDL_ANCHORS=$(FINAL_MDL_ANCHORS)
MDL_ANCHOR_KEY=contig
MDL_ANCHOR_VALUE=anchor
MDL_MFN=$(FINAL_CELLULAR_MDL_MFN)
MDL_SPURIOUS_PREFIX?=$(FINAL_MDL_DIR)/main

MDL_SCOPE=intra_anchor

MDL_DIR=$(FINAL_CELLULAR_MDL_DIR)
MDL_QSUB=$(QSUB_ANCHOR_DIR)/final_cellular_model

MDL_FDIR=$(ANCHOR_FIGURE_DIR)/models/final_cellular

####################################
else
####################################

$(if $(MDL_STAGE),$(error unkown MDL_STAGE=$(MDL_STAGE)),$(error MDL_STAGE not defined))

####################################
endif
####################################


#####################################################################################################
# abundance model parameters
#####################################################################################################

# table with fends assigned to inclusive clusters
FENDS_CLUSTER_DIR?=$(FENDS_DIR)/$(CUTTER_TITLE)_$(CELL_ID)
FENDS_CLUSTER?=$(FENDS_CLUSTER_DIR)/fends

# number of abundance bins
ABUNDANCE_BINS?=100

ABUNDANCE_BINNED_FENDS?=$(INIT_MODEL_PREFIX).binned
ABUNDANCE_BIN_SIZE?=$(INIT_MODEL_PREFIX).total_counts
ABUNDANCE_COUNTS?=$(INIT_MODEL_PREFIX).counts

#####################################################################################################
# anchor trimming
#####################################################################################################

# paths
AMAP_OUT_DIR?=$(DATASET_ANCHOR_DIR)/trim_anchors/model_$(MDL_VERSION)

# fend table and observed fend pairs
AMAP_IN_FENDS?=$(ABUNDANCE_BINNED_FENDS)
AMAP_IN_MAT?=$(MAT_FILE)

AMAP_IN_CLUSTER_TABLE?=$(INITIAL_ANCHOR_TABLE)
AMAP_IN_CLUSTER_FIELD?=cluster

# model (for expected)
AMAP_IN_MODEL_PREFIX?=$(INIT_MODEL_PREFIX)

AMAP_IN_MODEL_FIELDS?=abundance

AMAP_NUM_SPLIT?=80

# only relevant for SGE
AMAP_REQ_MEM?=4000

# abundance only model file
AMAP_MFN?=$(INIT_MDL_MFN)

# minimal number of contacts
AMAP_MULTI_MIN_CONTACTS?=5

# minimal log10(obs/exp)
AMAP_MULTI_MIN_ENRICHMENT?=0.2

AMAP_TRIM_FDR?=0.000001

# number of bins when computing contig coverage
AMAP_MULTI_BIN_SIZE?=10

# select abundance range up to factor*weighted.sd(abundance) from the weighed.mean(abundance)
AMAP_TRIM_COVERAGE_FACTOR?=1.5

# omit all anchors for which sd of selected abundances is too large (considered mixed clusters)
AMAP_TRIM_COVERAGE_MAX_SD?=0.2

# min anchor size in bp
AMAP_MIN_LENGTH?=200000

CELL_GENE_TAXA_TABLE?=$(AMAP_OUT_DIR)/cell_taxa

ANCHOR_RENAME_LOOKUP_TABLE?=$(AMAP_OUT_DIR)/anchor_lookup

#####################################################################################################
# contig-anchor map (CA)
#####################################################################################################

# output dir
DATASET_ANCHOR_DIR?=$(DATASET_DIR)/anchors/$(ANCHOR)_$(ANCHOR_LABEL)
CA_MAP_DIR?=$(DATASET_ANCHOR_DIR)/ca_matrix/model_$(MDL_VERSION)

# input
CA_MAP_IN_MODEL_PREFIX=$(FINAL_MODEL_PREFIX)
CA_MAP_IN_MODEL_CELL_PREFIX=$(FINAL_CELLULAR_MODEL_PREFIX)
CA_MAP_IN_FENDS=$(CA_MAP_IN_MODEL_PREFIX).binned
CA_MAP_IN_MAT?=$(MAT_FILE)
CA_MAP_IN_MFN=$(FINAL_MDL_MFN)
CA_MAP_IN_CELL_MFN=$(FINAL_CELLULAR_MDL_MFN)

CA_MAP_NUM_SPLIT?=80

# anchor-anchor map
CA_INTER_ANCHOR_MATRIX?=$(CA_MAP_DIR)/inter_anchor_matrix

# complete contig-anchor matrix
CA_MATRIX?=$(CA_MAP_DIR)/united

# complete cluster-anchor matrix, depends on response clusters
EA_MATRIX?=$(CA_MAP_DIR)/ea_matrix_$(RESPONSE_TAG)

# to establish a contig-anchor association a pair must satify all conditions

# T = |anchors|*|contigs|
# N = |inter contacts|
# For each pair (c,a)_i assign a tail probability S_i assuming that obs_i is
# distributed as binomial B(N, P=exp_i/N), and require S_i < FDR / T
CA_ASSIGN_FDR?=0.000001

# min number of contacts required to consider contig-anchor or gene-anchor contact enrichment
CA_MIN_CONTACTS?=8

# minimal log10(obs/exp)
CA_MIN_ENRICHMENT?=1

# min number of anchor contigs required
CA_MIN_ANCHOR_CONTIGS?=2

# number of bins per contig, when computing contig coverage
CA_CONTIG_NBINS?=10

# min coverage of contig bins to associate contig to anchor
CA_CONTIG_COVERAGE?=0.5

# matrix limited to significant associations by thresholds set below
CA_ANCHOR_CONTIGS?=$(CA_MAP_DIR)/contigs
CA_ANCHOR_GENES?=$(CA_MAP_DIR)/genes

# cloud and anchor stats
CA_STATS?=$(CA_MAP_DIR)/stats

#####################################################################################################
# cloud groups
#####################################################################################################

# group identity threshold
GROUP_THRESHOLD?=60

GROUP_DIR=$(DATASET_ANCHOR_DIR)/groups_$(SET_ID)_$(GROUP_THRESHOLD)
GROUP_ANCHOR_TABLE?=$(GROUP_DIR)/anchors
GROUP_TABLE?=$(GROUP_DIR)/groups

GROUP_FDIR?=$(ANCHOR_FIGURE_DIR)/groups

#####################################################################################################
# element-element map, generated in the response directory
#####################################################################################################

# output dir
# set in core_response_int.mk:
# EE_MAP_DATASET: the hi-c map id
# EE_MAP_IN_TABLE: input table (set/contig/start/end)
# EE_MAP_DIR: output dir

EE_MAP_DATASET?=$(LIB_ID)
EE_MAP_IN_MODEL_PREFIX=$(call reval,FINAL_MODEL_PREFIX,LIB_ID=$(EE_MAP_DATASET))
EE_MAP_IN_MODEL_CELL_PREFIX=$(call reval,FINAL_CELLULAR_MODEL_PREFIX,LIB_ID=$(EE_MAP_DATASET))
EE_MAP_IN_MAT?=$(call reval,MAT_FILE,LIB_ID=$(EE_MAP_DATASET))

EE_MAP_IN_FENDS=$(EE_MAP_IN_MODEL_PREFIX).binned
EE_MAP_IN_MFN=$(FINAL_MDL_MFN)
EE_MAP_IN_CELL_MFN=$(FINAL_CELLULAR_MDL_MFN)

# anchored/inter_anchor/intra_anchor/all
EE_MAP_SCOPE?=anchored

EE_MAP_NUM_SPLIT?=80

EE_MATRIX?=$(EE_MAP_DIR)/result

#####################################################################################################
# anchor info
#####################################################################################################

ANCHOR_COVERAGE_BINSIZE?=1000
ANCHOR_COVERAGE_TABLE?=$(CA_MAP_DIR)/anchor_coverage

ANCHOR_PARAMS?=$(CA_MAP_DIR)/anchor_params
CONTIG_LINKAGE?=$(CA_MAP_DIR)/contig_linkage

ANCHOR_GC_BINSIZE?=1000
ANCHOR_GC_TABLE?=$(CA_MAP_DIR)/anchor_gc

# table with various anchor info stats (contig median size, gc content etc)
ANCHOR_INFO_TABLE?=$(CA_MAP_DIR)/info_table
ANCHOR_INFO_TABLE_GENES?=$(CA_MAP_DIR)/info_table_genes
ANCHOR_INFO_TABLE_CONTIGS?=$(CA_MAP_DIR)/info_table_contigs

# anchor,shared,union sizes
ANCHOR_SIZE_STATS?=$(CA_MAP_DIR)/anchor_size_table

#####################################################################################################
# general gene-set comaprison parameters
#####################################################################################################

# cutoffs used when computing average identity
MEAN_IDENTITY_THRESHOLD?=30
COVERAGE_THRESHOLD?=70
MIN_GENE_COUNT?=12
INCLUDE_SHARED?=T
SET_ID?=id_$(MEAN_IDENTITY_THRESHOLD)_cov_$(COVERAGE_THRESHOLD)

#####################################################################################################
# anchor cluster
#####################################################################################################

# working dir
ANCHOR_CLUSTER_DIR?=$(DATASET_ANCHOR_DIR)/cluster_identity_$(SET_ID)_all

# qsub dir
ANCHOR_QSUB_MAP_DIR?=$(QSUB_ANCHOR_DIR)/cluster_anchor/$(SET_ID)

ANCHOR_CLUSTER_INPUT_MATRIX?=$(CA_ANCHOR_GENES)
ANCHOR_CLUSTER_INPUT_FIELD?=anchor

# input map
ANCHOR_CLUSTER_INPUT_MAP?=$(GENE_CLUSTER_MAP)

# output order file
ANCHOR_CLUSTER_TABLE_LOCAL?=$(ANCHOR_CLUSTER_DIR)/table.order
ANCHOR_MATRIX_TABLE?=$(ANCHOR_CLUSTER_DIR)/summary.table

# output figures here
ANCHOR_CLUSTER_FDIR?=$(ANCHOR_FIGURE_DIR)/cluster_identity_$(SET_ID)

#####################################################################################################
# ref cluster
#####################################################################################################

# working dir
REF_CLUSTER_DIR?=$(DATASET_ANCHOR_DIR)/ref_cluster_identity_$(SET_ID)

# input set
REF_CLUSTER_INPUT_MATRIX?=$(GENOME_GENE_TABLE)
REF_CLUSTER_INPUT_FIELD?=genome

# input map
REF_CLUSTER_INPUT_MAP?=$(REF_GENE_CLUSTER_MAP)

# output order file
REF_CLUSTER_TABLE?=$(REF_CLUSTER_DIR)/table.order

# lookup table
REF_CLUSTER_LOOKUP?=$(REF_CLUSTER_DIR)/lookup.table

# qsub dir
REF_QSUB_MAP_DIR?=$(QSUB_ANCHOR_DIR)/cluster_ref

# output figures here
REF_CLUSTER_FDIR?=$(ANCHOR_FIGURE_DIR)/ref_cluster_identity_$(SET_ID)

#####################################################################################################
# comparison of two different gene sets (default: reference and anchor)
#####################################################################################################

SET_COMPARE_DIR?=$(DATASET_ANCHOR_DIR)/ref_compare_$(SET_ID)

# qsub dir
SET_COMPARE_QSUB?=$(QSUB_ANCHOR_DIR)/set_compare_ref_predicted

# gene set 1
REF_SET_INPUT1?=$(REF_CLUSTER_INPUT_MATRIX)
REF_SET_INPUT_GENES1?=$(REF_CLUSTER_INPUT_MATRIX)
REF_FIELD_INPUT1?=$(REF_CLUSTER_INPUT_FIELD)

# gene set 2
REF_SET_INPUT2?=$(ANCHOR_CLUSTER_INPUT_MATRIX)
REF_SET_INPUT_GENES2?=$(GENE_TABLE)
REF_FIELD_INPUT2?=$(ANCHOR_CLUSTER_INPUT_FIELD)

# map from 1 to 2
REF_MAP_INPUT?=$(REF_GENE_MAP)

REF_CLUSTER_TABLE1?=$(REF_CLUSTER_TABLE)
REF_CLUSTER_TABLE2?=$(ANCHOR_CLUSTER_TABLE_LOCAL)

REF_SET_TITLE1?=reference
REF_SET_TITLE2?=predicted

# mean/count
SET_COMPARE_METRIC?=count

SET_COMPARE_FDIR?=$(ANCHOR_FIGURE_DIR)/ref_compare_$(SET_ID)

# compare files
SET_COMPARE_MATRIX_DIR?=$(SET_COMPARE_DIR)/map.dir
SET_COMPARE_PROJECT_DIR?=$(SET_COMPARE_DIR)/project.dir
SET_COMPARE_MATRIX_TABLE?=$(SET_COMPARE_DIR)/summary.table

SET_MATCH_TABLE1?=$(SET_COMPARE_DIR)/match1
SET_MATCH_TABLE2?=$(SET_COMPARE_DIR)/match2

SET_FWD_TABLE?=$(SET_COMPARE_DIR)/fwd.table
SET_BCK_TABLE?=$(SET_COMPARE_DIR)/bck.table
SET_TMP_DIR?=$(SET_COMPARE_DIR)/tmp.dir

#####################################################################################################
# gene project
#####################################################################################################

GENE_PROJECT_IDENTITY_THRESHOLD=$(CLUSTER_IDENTITY_THRESHOLD)
GENE_PROJECT_COVERAGE_THRESHOLD=$(CLUSTER_COVERAGE_THRESHOLD)

GENE_PROJECT_FWD?=$(SET_COMPARE_DIR)/gene_project_fwd
GENE_PROJECT_BCK?=$(SET_COMPARE_DIR)/gene_project_bck

# project genes forward from ref to predicted
GENE_PROJECT_FWD_SOURCE?=$(SET_COMPARE_DIR)/gene_project_fwd_source
GENE_PROJECT_FWD_TARGET?=$(SET_COMPARE_DIR)/gene_project_fwd_target

# project genes backwards from predicted to ref
GENE_PROJECT_BCK_SOURCE?=$(SET_COMPARE_DIR)/gene_project_bck_source
GENE_PROJECT_BCK_TARGET?=$(SET_COMPARE_DIR)/gene_project_bck_target

#####################################################################################################
# anchor variance
#####################################################################################################

ANCHOR_VARIANCE_DIR?=$(DATASET_ANCHOR_DIR)/anchor_variance

# TBD: must add global mapping step over sg that enforces no trim
VARIANCE_DATASET?=pre_lib_sg_simple
ANCHOR_VAR_SUMMARY_BINS=$(call reval,VAR_SUMMARY_BINS,DATASET=$(VARIANCE_DATASET) MAP_SPLIT_TRIM=F)

VARIANCE_DATASET1?=pre_lib_sg_simple
VARIANCE_DATASET2?=post_lib_sg_simple

ANCHOR_SNP_INPUT_TABLE1=$(call reval,VAR_SNP_TABLE,DATASET=$(VARIANCE_DATASET1) MAP_SPLIT_TRIM=F)
ANCHOR_SNP_INPUT_TABLE2=$(call reval,VAR_SNP_TABLE,DATASET=$(VARIANCE_DATASET2) MAP_SPLIT_TRIM=F)

ANCHOR_SNP_TABLE1?=$(ANCHOR_VARIANCE_DIR)/anchors1
ANCHOR_SNP_TABLE2?=$(ANCHOR_VARIANCE_DIR)/anchors2

ANCHOR_VAR_COMPARE_DIR?=$(ANCHOR_VARIANCE_DIR)/anchors

# allele freq changes
ANCHOR_VAR_ALLELE_CHANGES?=$(ANCHOR_VARIANCE_DIR)/allele_change.table

#####################################################################################################
# shared analysis
#####################################################################################################

GS_AAI_SHARED_DIR?=$(CA_MAP_DIR)/shared_analysis/$(GR_ID)_$(GR_SAMPLE_ID)

GS_MIN_TUPLE_SIZE?=2
GS_MAX_TUPLE_SIZE?=3

# reference
GS_REF_GENE_TABLE?=$(GR_GENE_TABLE)
GS_REF_GENE_CLUSTER_TABLE?=$(GR_GENE_CLUSTER_NT_TABLE)
GS_REF_GENE_FIELD?=cgene
GS_REF_GENOME_FIELD?=genome
GS_REF_GENOME_TABLE?=$(GR_GENOME_TABLE)
GS_REF_AAI_TABLE?=$(GR_GENOME_SUMMARY_TABLE)
GS_REF_PREFIX?=$(GS_AAI_SHARED_DIR)/ref_tuples

# anchor
GS_ANCHOR_GENE_TABLE?=$(GENE_TABLE)
GS_ANCHOR_GENE_CLUSTER_TABLE?=$(CA_ANCHOR_GENES)
GS_ANCHOR_GENE_FIELD?=gene
GS_ANCHOR_GENOME_FIELD?=anchor
GS_ANCHOR_GENOME_TABLE?=$(ANCHOR_INFO_TABLE)
GS_ANCHOR_AAI_TABLE?=$(ANCHOR_MATRIX_TABLE)
GS_ANCHOR_PREFIX?=$(GS_AAI_SHARED_DIR)/anchor_tuples

# binning AAI
#GS_AAI_BREAKS_ID?=dense
#GS_AAI_BREAKS?=40 50 60 70 80 90 100
#GS_AAI_BREAKS_ID?=dense2
#GS_AAI_BREAKS?=50 60 70 80 90 100
GS_AAI_BREAKS_ID?=dense3
GS_AAI_BREAKS?=50 60 70 80 90
#GS_AAI_BREAKS_ID?=sparse
#GS_AAI_BREAKS?=40 60 80

#GS_AAI_BREAKS_ID?=zoom
#GS_AAI_BREAKS?=40 50 60 70
#GS_AAI_BREAKS_ID?=sparse_zoom
#GS_AAI_BREAKS?=50 60 70

GS_BIN_DIR?=$(GS_AAI_SHARED_DIR)/bins/$(GS_AAI_BREAKS_ID)
GS_REF_BIN_DIR?=$(GS_BIN_DIR)/refs
GS_ANCHOR_BIN_DIR?=$(GS_BIN_DIR)/anchors

#####################################################################################################
# anchor/union coverage
#####################################################################################################

# ANCHOR_COVERAGE_DIR?=$(DATASET_ANCHOR_DIR)/

#####################################################################################################
# kcube tables
#####################################################################################################

KCUBE_CONTIG_TABLE?=/relman02/work/projects/kcube/assembly/pre_cipro_mega_mgm_genes/s14_c1_aF/matrix/united_dataset/p0.8_x2_v1/genomes/pre_v2/contig_summary

#####################################################################################################
# figures
#####################################################################################################

CA_MAP_FDIR?=$(ANCHOR_FIGURE_DIR)/ca_map
