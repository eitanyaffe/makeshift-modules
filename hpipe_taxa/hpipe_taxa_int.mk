#####################################################################################################
# register module
#####################################################################################################

name:=taxa
units:=taxa.mk seq_compare.mk rep_plots.mk GO.mk sc_ncbi.mk export_mags.mk
$(call _register_module,taxa,$(units),,)

###########################################################
# NCBI taxa files
# [ from ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy ]
###########################################################

NCBI_TAX_ID?=april_2018
NCBI_TAX_DIR?=/relman01/shared/databases/NCBI/taxonomy_$(NCBI_TAX_ID)
NCBI_TAX_NODES?=$(NCBI_TAX_DIR)/nodes.dmp
NCBI_TAX_NAMES?=$(NCBI_TAX_DIR)/names.dmp
NCBI_TAX_MERGED?=$(NCBI_TAX_DIR)/merged.dmp
NCBI_TAX_DELETED?=$(NCBI_TAX_DIR)/delnodes.dmp

###########################################################
# input params
###########################################################

# input table with at least 2 fields: (gene,anchor)
TAXA_SET_GENES?=$(CA_ANCHOR_GENES)
TAXA_SET_CONTIGS?=$(CA_ANCHOR_CONTIGS)
TAXA_SET_FIELD?=anchor

TAXA_CONTIG_FILE?=$(FULL_CONTIG_FILE)

# minimal homology thresholds
TAX_MIN_IDENTITY?=30
TAX_MIN_COVER?=70

# we compute also a tree masking out non-informative taxa, such as "human gut metagenome"
TAX_MASK?="408170"

# should mask taxa containing CAG in name?
CAG_MASK?=F

# force selection to go below these taxa even
TAX_ID_SKIP="0 2 186802"
TAX_NAME_SKIP="environmental.samples"

# portion of first ranked child out of children
TAXA_SELECT_RATIO_1?=0.3

# ratio of first child over second child
TAXA_SELECT_RATIO_12?=0.3

###########################################################
# output params
###########################################################

# NCBI files, downloaded from ftp://ftp.ncbi.nlm.nih.gov/genomes/ASSEMBLY_REPORTS/
# First line (which has an #) was removed manually
GENEBANK_VERSION?=May_2018
GENEBANK_DIR?=/relman01/shared/databases/NCBI/Genomes/$(GENEBANK_VERSION)
GENEBANK_TABLE?=$(GENEBANK_DIR)/assembly_summary_genbank.txt.2

TAXA_VER?=v2
TAXA_ID?=genebank_$(GENEBANK_VERSION)_$(GENE_REF_ID)_taxonomy_$(NCBI_TAX_ID)_maskCAG_$(CAG_MASK)_$(TAXA_VER)

TAXA_DIR?=$(DATASET_ANCHOR_DIR)/uniref_selected/$(TAXA_ID)

# figures
TAXA_BASE_FDIR?=$(ANCHOR_FIGURE_DIR)
TAXA_FDIR?=$(TAXA_BASE_FDIR)/taxa_selected/$(TAXA_ID)

# taxa trees
SET_TAXA_TABLE?=$(TAXA_DIR)/taxa_table
SET_TAXA_TREES?=$(TAXA_DIR)/taxa_trees
SET_TAXA_SUMMARY?=$(TAXA_DIR)/anchor_summary

# path leading to single species with maximal covered genes
SET_TAXA_PATH?=$(TAXA_DIR)/path

# minimal anchor coverage (%) when resolving
SET_TAXA_RESOLVE_MIN_COVERAGE?=5

# minimal ratio of coverage over second branch when resolving (%)
SET_TAXA_RESOLVE_MIN_RATIO?=120

# SET_TAXA_RESOLVE_LEVELS="root phylum order family genus species"
SET_TAXA_RESOLVE?=$(TAXA_DIR)/resolution

# species representative taxa per anchor
SET_TAXA_REPS?=$(TAXA_DIR)/taxa_table.txt

# determine if we have species-level reference
SET_TAXA_REP_MIN_COVERAGE?=50
SET_TAXA_REP_MIN_IDENTITY?=90

SET_TAX_LEVELS?="species genus family order class phylum"
SET_TAX_LEVEL_PREFIX?=$(TAXA_DIR)/level
SET_TAX_LEVEL_SUMMARY_PREFIX?=$(TAXA_DIR)/level_summary

# legend letters
SET_TAX_LETTER_LEVEL?=genus
SET_TAX_LEGEND_LETTER?=$(TAXA_DIR)/legend_letter
SET_TAX_LETTER_ORDER?=by.tree

# legend colors
SET_TAX_COLOR_LEVEL?=family
SET_TAX_LEGEND_COLOR?=$(TAXA_DIR)/legend_color

# force legend colors
# 186803  Lachnospiraceae
# 31979   Clostridiaceae
# 541000  Ruminococcaceae
# 186806  Eubacteriaceae
# 186804  Peptostreptococcaceae
# 815	  Bacteroidaceae
# 128827  Erysipelotrichaceae
# 2092	  Mycoplasmataceae
# 31977	  Veillonellaceae
# 995019  Sutterellaceae

SET_TAX_LEGEND_IDS?=    186803 31979 541000 186806 186804 815 128827 2092 31977 995019
SET_TAX_LEGEND_COLORS?= 652    57    76     552    419    451 610    26   139   128

# legend output
SET_TAX_LEGEND?=$(TAXA_DIR)/legend

# old
SET_TAXA_REP_LEGEND?=$(TAXA_DIR)/rep_table_legend

# single species per anchor
TAXA_REF_LEVEL?=species
TAXA_REF_GENOMES?=$(TAXA_DIR)/ref_genomes

# trim rep tree for plotting tree legend
TRIM_TREE_NAMES=environmental_samples
TRIM_TREE_GREP_NAMES=unclassified
TRIM_TREE_LEVELS="species"

# color by level (rank), '_' are converted to space
NO_LEVEL_COLOR?=grey
LEVEL_NAMES=no_rank superkingdom phylum class order family genus species
LEVEL_COLORS?=gray black darkblue yellow darkgreen purple red orange

# free color of subtrees
NO_BRANCH_COLOR?=grey
#BRANCH_IDS?=80840 1239 1573535 39948 1485 186803 841 1730 459786 541000 84111 816

# to select nodes inspect $(TAXA_FDIR)/representatives/full_raw.png and tree.txt in the same directory
BRANCH_IDS?=            1224 1239 31979 186803 841 186806 541000 201174 976
BRANCH_COLOR_INDICES?=  652  128  76    552    419 26     451    610    139

# P 1224: Proteobacteria
# P 1239: Firmicutes
#   F 31979: Clostridiaceae
#   F 186803: Lachnospiraceae
#     G 841: Roseburia
#   F 186806: Eubacteriaceae
#   F 541000: Ruminococcaceae
# P 201174: Actinobacteria
# P 976: Bacteroidetes
# make depth of nodes zero while plotting, useful for balancing tree
COLLAPSE_DEPTH_IDS?=1783270

###########################################################
# sequence comparison
###########################################################

SC_DIR?=$(TAXA_DIR)/seq_compare

# table with anchor/genome pairs
SC_TABLE?=$(SC_DIR)/anchor_genome_table

# anchor genome sequences
SC_SEQ_DIR?=$(SC_DIR)/genomes
SC_ANCHOR_DIR?=$(SC_SEQ_DIR)/anchors
SC_ANCHOR_ONLY_DIR?=$(SC_SEQ_DIR)/anchors_only
SC_REF_DIR?=$(SC_SEQ_DIR)/refs
SC_REF_FAILED?=$(SC_DIR)/failed_log

# genes
SC_ANCHOR_GENES_DIR?=$(SC_SEQ_DIR)/anchor_genes
SC_UNION_GENES_DIR?=$(SC_SEQ_DIR)/union_genes

# breakdown build/reads into fragments of specified length
SC_FRAGMENT_LENGTH?=100

# fragmentation step
SC_GENOME_STEP?=1
SC_READ_STEP?=$(SC_FRAGMENT_LENGTH)

# short reads input dir
SC_READ_INPUT_DIR?=$(PREPROC_FINAL_BASE)/$(MAP_LIB_ID)
SC_READ_INPUT_EXT?=fq
SC_READ_INPUT_MAX_COUNT?=100000000
SC_READ_INPUT_TAG?=$(SC_READ_STEP)_$(SC_READ_INPUT_MAX_COUNT)

# breakdown input into fragments
SC_FRAGMENT_DIR?=$(SC_DIR)/fragment
SC_FRAGMENT_MAX_JOBS?=5
SC_FRAGMENT_QSUB?=$(SC_QSUB)/fragment
SC_READ_FRAGMENT_DIR?=$(SC_FRAGMENT_DIR)/reads_$(SC_READ_INPUT_TAG)

# use only Major Complete Genome if species has many genomes
SC_COMPLETE_GENOME_THRESHOLD=500

# maximal number of refs per taxa.id, in case using only major complete genomes
SC_MAX_REF_GENOMES_PER_TAXA=4

# qsub root
SC_QSUB=$(QSUB_ANCHOR_DIR)/seq_compare

# number of parallel sc jobs for bwa index creation
SC_BWA_INDEX_QSUB?=$(SC_QSUB)/bwa_index
SC_BWA_INDEX_MAX_JOBS?=40

# number of reads per sc job
SC_SEQ_PER_FILE?=100000000

# jobs/threads per anchor/ref pair
SC_MAX_JOBS?=4
SC_NTHREADS?=10

# jobs/threads per reads/ref pair
SC_MAX_JOBS_READS?=1
SC_NTHREADS_READS?=80

# anchors to refs
SC_ANCHOR2REF_DIR?=$(SC_DIR)/anchor2ref
SC_ANCHOR2REF_QSUB?=$(SC_QSUB)/anchor2ref

# refs to anchors
SC_REF2ANCHOR_DIR?=$(SC_DIR)/ref2anchor
SC_REF2ANCHOR_QSUB?=$(SC_QSUB)/ref2anchor

# reads to refs
SC_READ2REF_DIR?=$(SC_DIR)/read2ref
SC_READ2REF_QSUB?=$(SC_QSUB)/read2ref

# all anchor/ref pairs
SC_SUMMARY?=$(SC_DIR)/summary

# best ref per anchor
SC_SUMMARY_UNIQUE?=$(SC_DIR)/ref_genome_table.txt

###########################################################
# summary over genes
###########################################################

# mean sequence identity over gene/anchor pairs
SC_GENE_TABLE?=$(SC_DIR)/gene.table

# identity threshold to be considered core
SC_IDENTITY_THRESHOLD?=90

# discard if core fraction is too small
SC_MIN_CORE_PERCENTAGE?=50

ELEMENT_VERSION?=v1
ELEMENT_TAG?=elements_id$(SC_IDENTITY_THRESHOLD)_f$(SC_MIN_CORE_PERCENTAGE)_v$(ELEMENT_VERSION)
ELEMENT_DIR?=$(SC_DIR)/$(ELEMENT_TAG)

# checkm parameters
SC_CHECKM_QA?=$(CHECKM_QA)
SC_CHECKM_MIN_COMPLETE?=$(CHECKM_MIN_COMPLETE)
SC_CHECKM_MAX_CONTAM?=$(CHECKM_MAX_CONTAM)

# cores
SC_CORE_BASE_TABLE?=$(ELEMENT_DIR)/core_base.table
SC_CORE_TABLE?=$(ELEMENT_DIR)/core.table
SC_CORE_GENES?=$(ELEMENT_DIR)/gene2anchor

# elements
SC_ELEMENT_TABLE?=$(ELEMENT_DIR)/element.table
SC_GENE_ELEMENT?=$(ELEMENT_DIR)/gene2element
SC_ELEMENT_ANCHOR?=$(ELEMENT_DIR)/element2anchor

# only shared elements
SC_GENE_ELEMENT_SHARED?=$(ELEMENT_DIR)/gene2element.shared

SC_ELEMENT_GENE_TABLE?=$(ELEMENT_DIR)/element_gene_table.txt

# all genes associated with elements or cores
SC_ASSOCIATED_GENES?=$(ELEMENT_DIR)/associated_gene

###########################################################
# submit MAGs to NCBI
###########################################################

SC_NCBI_DIR?=$(ELEMENT_DIR)/NCBI
SC_NCBI_TABLE?=$(SC_NCBI_DIR)/table.txt
SC_NCBI_GENOME_DIR?=$(SC_NCBI_DIR)/genomes

###########################################################
# export MAGs
###########################################################

SC_MAGS_DIR?=$(ELEMENT_DIR)/export_MAGs
SC_MAGS_TABLE?=$(SC_MAGS_DIR)/MAG_summary.txt
SC_MAGS_FASTA_DIR?=$(SC_MAGS_DIR)/fasta

###########################################################
# plotting params
###########################################################

# min genes when plotting trees
SET_TAXA_TREE_PLOT_MIN_GENES?=100

PLOT_AAI_BREAKS=0 45 50 55 60 100

###########################################################
# subtrees
###########################################################

TAXA_SUBTREE_ID?=basic
TAXA_SUBTREE_DIR?=$(OUTDIR)/taxa_trees/$(TAXA_SUBTREE_ID)
TAXA_SUBTREES_INPUT?=input/taxa_tables/basic.taxa
TAXA_SUBTREES_TABLE?=$(TAXA_SUBTREE_DIR)/taxa.tree

#############################################################################
# compare sg/hi-c abundance over genomes
#############################################################################

TAXA_HIC_DATASET?=pre_lib_hic_u_simple
TAXA_SG_DATASET?=pre_lib_sg_simple

TAXA_HIC_TABLE?=$(call reval,COVERAGE_TABLE,DATASET=$(TAXA_HIC_DATASET))
TAXA_SG_TABLE?=$(call reval,COVERAGE_TABLE,DATASET=$(TAXA_SG_DATASET))
