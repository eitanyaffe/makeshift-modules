
#####################################################################################################
# register module
#####################################################################################################

units=checkm.mk
$(call _register_module,checkm,$(units),)

#####################################################################################################

# taxa | lineage
CHECKM_STYLE?=lineage

# in case we use taxa
CHECKM_RANK?=domain
CHECKM_TAXON?=Bacteria

# A(anchor) | U(union) | X(accessory)
CHECKM_TYPE?=U

# discard all genes that reach close to start/end of contig
CHECKM_GENE_GAP?=0

# bin parameters
CHECKM_EXT?=fasta

CHECKM_TAG?=$(CHECKM_STYLE)_$(CHECKM_TYPE)_$(CHECKM_GENE_GAP)

# base dir
CHECKM_BASE_DIR?=$(CA_MAP_DIR)/checkm
CHECKM_DIR?=$(CHECKM_BASE_DIR)/$(CHECKM_TAG)

# threads
CHECKM_THREADS?=40
CHECKM_PPLACER_THREADS?=20

# input
CHECKM_BINS?=$(CHECKM_DIR)/input/bins

# output
CHECKM_OUTPUT?=$(CHECKM_DIR)/output
CHECKM_MARKER_SET?=$(CHECKM_OUTPUT)/main.ms

# tree qa
CHECKM_TREE_QA?=$(CHECKM_OUTPUT)/tree.qa

# AAI threshold used to identify strain heterogeneity
CHECKM_AAI?=0.9

# qa
CHECKM_QA_TYPE?=1
CHECKM_QA_PREFIX?=$(CHECKM_OUTPUT)/qa.table
CHECKM_QA?=$(CHECKM_QA_PREFIX).$(CHECKM_QA_TYPE)
CHECKM_MULTI_FILE?=$(CHECKM_OUTPUT)/multi.table

# select
CHECKM_MIN_COMPLETE?=50
CHECKM_MAX_CONTAM?=10

# selected anchors
# CHECKM_ANCHORS?=$(CHECKM_OUTPUT)/selected_anchors.$(CHECKM_QA_TYPE)
# CA_ANCHOR_GENES_SELECTED?=$(CHECKM_OUTPUT)/selected_ga.$(CHECKM_QA_TYPE)
# CA_ANCHOR_CONTIGS_SELECTED?=$(CHECKM_OUTPUT)/selected_ca.$(CHECKM_QA_TYPE)

CHECKM_FDIR?=$(ANCHOR_FIGURE_DIR)/checkm/$(CHECKM_TAG)
