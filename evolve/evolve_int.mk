units=elements.mk element_plots.mk mkt.mk subjects.mk wf.mk
$(call _register_module,evolve,$(units),)

#####################################################################################################
# input
#####################################################################################################

# relevant genes
EVO_IN_GA?=$(CA_ANCHOR_GENES)

# cores
EVO_IN_SC_CORE_TABLE?=$(SC_CORE_TABLE)
EVO_IN_SC_CORE_GENES?=$(SC_CORE_GENES)

# elements
EVO_IN_SC_ELEMENT_TABLE?=$(SC_ELEMENT_TABLE)
EVO_IN_SC_GENE_ELEMENT?=$(SC_GENE_ELEMENT)

# used for a leaf
EVO_IN_SC_ELEMENT_ANCHOR?=$(SC_ELEMENT_ANCHOR)

# used for a plot leaf
EVO_IN_SC_SUMMARY_UNIQUE?=$(SC_SUMMARY_UNIQUE)

#####################################################################################################
# basic ids and directories
#####################################################################################################

# poly over sg used for assembly
EVO_POLY_SG_ID?=pre_lib_sg_simple
EVO_POLY_SG_DIR?=$(ASSEMBLY_DIR)/datasets/$(EVO_POLY_SG_ID)/poly/$(ASSEMBLY_ID)/map/F_0_40_0_40_100000000/$(EVO_POLY_SG_ID)

# defined in config file
EVO_POLY_INPUT_BASE_DIR?=$(EVO_POLY_SG_DIR)
EVO_POLY_REF_INPUT_BASE_DIR?=NA

EVO_POLY_INPUT_DIR?=$(EVO_POLY_INPUT_BASE_DIR)/output_full
EVO_POLY_REF_INPUT_DIR?=$(EVO_POLY_REF_INPUT_BASE_DIR)/output_full

EVO_POLY_ID?=current
EVO_VERSION_ID?=v2
EVO_BASE_POLY_DIR?=$(ASSEMBLY_DIR)/evolve_$(EVO_VERSION_ID)/$(ANCHOR)_$(ANCHOR_LABEL)_selected
EVO_POLY_DIR?=$(EVO_BASE_POLY_DIR)/$(EVO_POLY_ID)

#####################################################################################################
# summary over genes
#####################################################################################################

# trim sides of contigs
EVO_EDGE_MARGIN?=200

# consider snp only if supported by enough reads
EVO_MIN_COUNT?=3

# live snps
EVO_MIN_LIVE_FREQ?=0.2
EVO_MAX_LIVE_FREQ?=0.8

# fixed snps
EVO_FIXED_FREQ?=0.95

# used to estimate sd of xcoverage, does not have to be precise
EVO_READ_LENGTH?=150

# snp counts and median xcov per gene
EVO_GENE_TABLE?=$(EVO_POLY_DIR)/gene.table

# detailed table with poly and substitutions
EVO_GENE_SUB_TABLE?=$(EVO_POLY_DIR)/gene_sub.table
EVO_GENE_POLY_TABLE?=$(EVO_POLY_DIR)/gene_poly.table

#####################################################################################################
# summary over elements and cores
#####################################################################################################

# xcov element detection threshold
EVO_ELEMENT_DETECTION_COV?=1

EVO_POLY_ELEMENT_DIR?=$(EVO_POLY_DIR)/$(ELEMENT_TAG)_cov$(EVO_ELEMENT_DETECTION_COV)

# summary over cores and accessory elements
EVO_ELEMENT_TABLE_BASE?=$(EVO_POLY_ELEMENT_DIR)/element.table
EVO_CORE_TABLE?=$(EVO_POLY_ELEMENT_DIR)/core.table

# distribution of snps within genes
EVO_CORE_POLY_DISTRIB?=$(EVO_POLY_ELEMENT_DIR)/core_poly_distrib
EVO_CORE_FIX_DISTRIB?=$(EVO_POLY_ELEMENT_DIR)/core_fix_distrib

# select non-chimeric elements for which the sd of the z-score of genes compared to the mean element x-coverage is below this limit
EVO_MAX_COVERAGE_SCORE?=4

# table of ids generated using current library, in top dir
EVO_ELEMENT_TABLE_SELECTED?=$(EVO_BASE_POLY_DIR)/element.selected

# filtering elements
EVO_ELEMENT_TABLE?=$(EVO_POLY_ELEMENT_DIR)/selected_element_t$(EVO_MAX_COVERAGE_SCORE).table

#####################################################################################################
# classify live
#####################################################################################################

EVO_CLASS_VER?=v11
EVO_CLASSIFY_DIR?=$(EVO_POLY_ELEMENT_DIR)/classify_$(EVO_CLASS_VER)

# plot snp/fix denisitied if xcov is at least (threshold_cov)
EVO_MIN_COV?=10

# fraction of gene set with median cov > 0 (threshold_detect)
EVO_DETECT_FRACTION?=0.9

# source: Genome-scale rates of evolutionary change in bacteria, Duchene et al. 2016
# max clonal accumulated fixed snps/bp per year: 10^-5
EVO_FIX_DENSITY_THRESHOLD?=10e-05

# max clonal accumulated snps/bp over a 40 year period (bound on time in gut)
EVO_POLY_DENSITY_THRESHOLD?=40e-05

# classify colonization history (live)
# chimeric: coverage_score > threshold_chimeric
# simple: detected.fraction > threshold_detect && cov > threshold_cov && snp/bp < threshold_100y
# complex: detected.fraction > threshold_detect && cov > threshold_cov && snp/bp > threshold_100y
# unknown: otherwise
# NOTE: hosts are never classified as chimeric

EVO_CORE_LIVE_CLASS?=$(EVO_CLASSIFY_DIR)/core_live
EVO_ELEMENT_LIVE_CLASS?=$(EVO_CLASSIFY_DIR)/element_live

# classify longterm fate (fate)
# chimeric: coverage_score > threshold_chimeric
# not-detected: detected.fraction < threshold_detected
# persist: detected.fraction > threshold_detect && cov > threshold_cov && snp/bp < threshold_100y
# turn: detected.fraction > threshold_detect && cov > threshold_cov && snp/bp > threshold_100y

EVO_CORE_FATE_CLASS?=$(EVO_CLASSIFY_DIR)/core_fate
EVO_ELEMENT_FATE_CLASS?=$(EVO_CLASSIFY_DIR)/element_fate

# combined element and host fates
EVO_ELEMENT_HOST_FATE?=$(EVO_POLY_DIR)/host_element_combined_fate

# explode genes
EVO_ELEMENT_FATE_PREFIX?=$(EVO_CLASSIFY_DIR)/explode_fate
EVO_ELEMENT_LIVE_PREFIX?=$(EVO_CLASSIFY_DIR)/explode_live

# sharing matrix between hosts
EVO_ELEMENT_HOST_MATRIX?=$(EVO_POLY_DIR)/host_matrix

#####################################################################################################
# fate summary
#####################################################################################################

# how many years
EVO_FATE_YEARS?=10

# all genes gained per host
EVO_CORE_DETECT_SUMMARY?=$(EVO_CLASSIFY_DIR)/host_detect_summary

# elements gained per host
EVO_CORE_FATE_SUMMARY?=$(EVO_CLASSIFY_DIR)/host_fate_summary

# complete table with host-fate and associated element fates
EVO_CORE_FATE_DETAILED?=$(EVO_CLASSIFY_DIR)/host_fate_detailed

# detailed gene fate table
EVO_CORE_GENE_FATE?=$(EVO_CLASSIFY_DIR)/host_gene_fate

# focus on gained/lost genes over persistent hosts
EVO_CORE_GENE_SELECT?=$(EVO_CLASSIFY_DIR)/host_gene_select

#####################################################################################################
# useful aliases
#####################################################################################################

EVO_CORE_TABLE_CURRENT=$(call reval,EVO_CORE_TABLE,EVO_POLY_ID=$(POLY_CURRENT_ID))
EVO_ELEMENT_TABLE_CURRENT=$(call reval,EVO_ELEMENT_TABLE,EVO_POLY_ID=$(POLY_CURRENT_ID))
EVO_ELEMENT_TABLE_BASE_CURRENT=$(call reval,EVO_ELEMENT_TABLE_BASE,EVO_POLY_ID=$(POLY_CURRENT_ID))
EVO_ELEMENT_HOST_MATRIX_CURRENT=$(call reval,EVO_ELEMENT_HOST_MATRIX,EVO_POLY_ID=$(POLY_CURRENT_ID))

EVO_CORE_LIVE_CLASS_CURRENT=$(call reval,EVO_CORE_LIVE_CLASS,EVO_POLY_ID=$(POLY_CURRENT_ID))
EVO_ELEMENT_LIVE_CLASS_CURRENT=$(call reval,EVO_ELEMENT_LIVE_CLASS,EVO_POLY_ID=$(POLY_CURRENT_ID))

EVO_CORE_TABLE_10Y=$(call reval,EVO_CORE_TABLE,EVO_POLY_ID=$(POLY_10Y_ID))
EVO_ELEMENT_TABLE_10Y=$(call reval,EVO_ELEMENT_TABLE,EVO_POLY_ID=$(POLY_10Y_ID))
EVO_CORE_GENE_SELECT_10Y=$(call reval,EVO_CORE_GENE_SELECT,EVO_POLY_ID=$(POLY_10Y_ID))

EVO_CORE_FATE_CLASS_10Y=$(call reval,EVO_CORE_FATE_CLASS,EVO_POLY_ID=$(POLY_10Y_ID))
EVO_ELEMENT_FATE_CLASS_10Y=$(call reval,EVO_ELEMENT_FATE_CLASS,EVO_POLY_ID=$(POLY_10Y_ID))

EVO_ELEMENT_HOST_FATE_10Y=$(call reval,EVO_ELEMENT_HOST_FATE,EVO_POLY_ID=$(POLY_10Y_ID))

EVO_CORE_FATE_SUMMARY_CURRENT=$(call reval,EVO_CORE_FATE_SUMMARY,EVO_POLY_ID=$(POLY_CURRENT_ID))
EVO_CORE_FATE_SUMMARY_10Y=$(call reval,EVO_CORE_FATE_SUMMARY,EVO_POLY_ID=$(POLY_10Y_ID))

EVO_FIX_TABLE=$(call reval,EVO_GENE_SUB_TABLE,EVO_POLY_ID=$(POLY_10Y_ID))
EVO_POLY_TABLE=$(call reval,EVO_GENE_POLY_TABLE,EVO_POLY_ID=$(POLY_CURRENT_ID))

# post
EVO_CORE_FATE_CLASS_POST=$(call reval,EVO_CORE_FATE_CLASS,EVO_POLY_ID=$(POLY_POST_ID))
EVO_CORE_FATE_SUMMARY_POST=$(call reval,EVO_CORE_FATE_SUMMARY,EVO_POLY_ID=$(POLY_POST_ID))
EVO_ELEMENT_FATE_CLASS_POST=$(call reval,EVO_ELEMENT_FATE_CLASS,EVO_POLY_ID=$(POLY_POST_ID))
EVO_CORE_FATE_DETAILED_POST=$(call reval,EVO_CORE_FATE_DETAILED,EVO_POLY_ID=$(POLY_POST_ID))

#####################################################################################################
# mcdonald kreitman analysis
#####################################################################################################

# from https://www.ncbi.nlm.nih.gov/Taxonomy/Utils/wprintgc.cgi?chapter=cgencodes#SG11
MKT_INPUT_CODON_TABLE?=input/genetic_code/table11

MKT_VERSION?=v3
MKT_DIR?=$(EVO_BASE_POLY_DIR)/mkt/$(MKT_VERSION)

# codon ka/ks distrib
MKT_CODON_TABLE?=$(MKT_DIR)/codon_table
MKT_CODON_SUB?=$(MKT_DIR)/codon_sub

MKT_GENE_BG?=$(MKT_DIR)/gene_bg

MKT_GENE_FIX_DETAILS?=$(MKT_DIR)/gene_fix_details
MKT_GENE_FIX_SUMMARY?=$(MKT_DIR)/gene_fix_summary
MKT_CORE_FIX_DETAILS?=$(MKT_DIR)/core_fix_details
MKT_CORE_FIX?=$(MKT_DIR)/core_fix

MKT_GENE_POLY_DETAILS?=$(MKT_DIR)/gene_poly_details
MKT_GENE_POLY_SUMMARY?=$(MKT_DIR)/gene_poly_summary
MKT_CORE_POLY_DETAILS?=$(MKT_DIR)/core_poly_details
MKT_CORE_POLY?=$(MKT_DIR)/core_poly

# when averaging all strains include up to this threshold on poly density
MKT_MAX_POLY_DENSITY?=1e-04

# core summary
MKT_TABLE?=$(MKT_DIR)/core_table

# gene details
MKT_GENE_TABLE?=$(MKT_DIR)/core_table_genes

#####################################################################################################
# wright-fisher
#####################################################################################################

# mutations (u = WF_MUTATION_BP_RATE * WF_GENOME_SIZE)
WF_GENOME_SIZE?=5e06
WF_MUTATION_BP_RATE?=1e-9

# population size (2N = WF_POP_SIZE)
WF_POP_SIZE?=10000

# end at 2N*WF_END_FACTOR generations
WF_END_FACTOR?=4

# step at 2N*WF_STEP_FACTOR generations
WF_STEP_FACTOR?=0.1

# sampling
WF_SAMPLE_SIZE?=1000

# temporal
WF_TAG?=n$(WF_POP_SIZE)_s$(WF_SAMPLE_SIZE)
WF_DIR?=$(OUTDIR)/wright_fisher/$(WF_TAG)
WF_TABLE?=$(WF_DIR)/table

# N gradient
WF_POP_SIZE_BEGIN?=1000
WF_POP_SIZE_END?=10000
WF_POP_SIZE_LOG_STEP?=0.05
WF_POP_SAMPLE_SIZE?=1000
WF_POP_FACTOR?=4
WF_POP_TAG?=pop_b$(WF_POP_SIZE_BEGIN)_e$(WF_POP_SIZE_END)_s$(WF_POP_SIZE_LOG_STEP)_n$(WF_POP_SAMPLE_SIZE)
WF_POP_DIR?=$(OUTDIR)/wright_fisher/$(WF_POP_TAG)
WF_POP_TABLE?=$(WF_POP_DIR)/table

#####################################################################################################
# merge subjects
#####################################################################################################

SUBJECTS_DIR?=$(EVO_BASE_POLY_DIR)/subjects

# non-syn fixated genes
AAB_MKT_GENE_TABLE=$(call reval,MKT_GENE_TABLE,c=$(CFG1))
FP_MKT_GENE_TABLE=$(call reval,MKT_GENE_TABLE,c=$(CFG2))

# final fixated genes
SUBJECTS_FIX_TABLE?=$(SUBJECTS_DIR)/fix_table

# hgt table
AAB_HGT_TABLE=$(call reval,EVO_CORE_GENE_SELECT,c=$(CFG1) EVO_POLY_ID=$(POLY_10Y_ID))
FP_HGT_TABLE=$(call reval,EVO_CORE_GENE_SELECT,c=$(CFG2) EVO_POLY_ID=$(POLY_10Y_ID))

# final fixated genes
SUBJECTS_HGT_TABLE?=$(SUBJECTS_DIR)/hgt_table

#####################################################################################################
# plotting
#####################################################################################################

# discard short elements when plotting
EVO_MIN_LENGTH?=10000

# compare turnover time AAB and FP
AAB_CORE_SUMMARY=$(call reval,EVO_CORE_FATE_SUMMARY,c=$(CFG1) EVO_POLY_ID=$(POLY_10Y_ID))
FP_CORE_SUMMARY=$(call reval,EVO_CORE_FATE_SUMMARY,c=$(CFG2) EVO_POLY_ID=$(POLY_10Y_ID))

EVO_BASE_FDIR?=$(ANCHOR_FIGURE_DIR)/evolve/$(EVO_VERSION_ID)
EVO_FDIR?=$(EVO_BASE_FDIR)/$(EVO_POLY_ID)

AAB_MKT_TABLE=$(call reval,MKT_TABLE,c=$(CFG1))
FP_MKT_TABLE=$(call reval,MKT_TABLE,c=$(CFG2))
