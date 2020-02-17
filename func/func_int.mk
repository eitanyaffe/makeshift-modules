units=func.mk
$(call _register_module,func,$(units),)

FUNC_VERSION?=v8
FUNC_DIR?=$(DATASET_ANCHOR_DIR)/func/$(FUNC_VERSION)

FUNC_COMPARE_DIR?=$(DATASET_ANCHOR_DIR)/func/$(FUNC_VERSION)/compare

#####################################################################################################
# gene sets
#####################################################################################################

# background gene
#FUNC_GENES_BG=$(GENE_TABLE)
FUNC_GENES_BG?=$(SC_ASSOCIATED_GENES)
FUNC_GENES_AA_BG?=$(GENE_FASTA_AA)

# all accessory genes
FUNC_GENES_ACC?=$(SC_GENE_ELEMENT)

# free genes
FUNC_GENES_FREE?=$(POP_FREE_GENES)
FUNC_GENES_DEPEND?=$(POP_DEPEND_GENES)

# 10 year persistant genes
FUNC_GENES_PERSIST?=$(EVO_ELEMENT_FATE_PREFIX)_persist
FUNC_GENES_TURNOVER?=$(EVO_ELEMENT_FATE_PREFIX)_turnover

# shared/single genes (simple only, no chimeric)
FUNC_GENES_SINGLE_SIMPLE?=$(EVO_ELEMENT_LIVE_PREFIX)_single_simple
FUNC_GENES_SHARED_SIMPLE?=$(EVO_ELEMENT_LIVE_PREFIX)_shared_simple

FUNC_ID?=acc
FUNC_INPUT_GENES?=$(FUNC_GENES_ACC)

# work here
FUNC_SET_DIR?=$(FUNC_DIR)/geneset/$(FUNC_ID)

# extract gene fasta
FUNC_GENES_AA?=$(FUNC_SET_DIR)/genes_aa.fa

#####################################################################################################
# basic blast analysis
#####################################################################################################

FUNC_BLAST_VERSION=v1
FUNC_BLAST_BREAKS=0 50 70 90 98 100

FUNC_BLAST_SUMMARY?=$(FUNC_SET_DIR)/blast_summary_$(FUNC_BLAST_VERSION)
FUNC_POOR_RATE?=$(FUNC_SET_DIR)/poor_rate

#FUNC_IDS="bg acc depend free persist turnover single_simple shared_simple fix hgt"
#FUNC_COLORS="gray blue red darkgreen orange yellow purple pink green darkblue"
FUNC_IDS="bg acc depend free fix hgt"
FUNC_COLORS="gray blue red darkgreen orange yellow"

#####################################################################################################
# GO enrichments
#####################################################################################################

# blast hit threshold
GO_MIN_AA_IDENTITY?=50

GO_PREFIX_BG=$(call reval,GO_SUMMARY_PREFIX,FUNC_ID=bg)

GO_TABLE?=$(FUNC_SET_DIR)/genes
GO_SUMMARY_PREFIX?=$(FUNC_SET_DIR)/summary
GO_MERGE?=$(FUNC_SET_DIR)/merge

#####################################################################################################
# AMR
#####################################################################################################

FUNC_AMR_TABLE?=$(GO_SUMMARY_PREFIX)_AMR

#####################################################################################################
# append various stats
#####################################################################################################

# if true append anchor fields to gene table using GO_ELEMENT_ANCHOR table
GO_ELEMENT_ANCHOR?=$(SC_ELEMENT_ANCHOR)
GO_APPEND_ANCHOR?=T

# count stats over various gene fields
GO_STAT_FIELDS?=gene element.id anchor
GO_STATS?=$(FUNC_SET_DIR)/stats

# final go table with stats
GO_FINAL?=$(FUNC_SET_DIR)/final

GO_STAT_FIX_FIELDS?="gene anchor"

# with q-values
GO_QVALS?=$(FUNC_SET_DIR)/table.qvalues

#####################################################################################################
# select significant
#####################################################################################################

GO_SELECT_VERSION?=v4
GO_MIN_MINUS_LOG_PVALUE?=1.3
GO_MIN_GENE_COUNT?=2
GO_MIN_ENRICHMENT?=2

GO_SELECT_DIR?=$(FUNC_SET_DIR)/significant_$(GO_SELECT_VERSION)
GO_SELECT?=$(GO_SELECT_DIR)/table

#####################################################################################################
# leaves abd exploded genes
#####################################################################################################

# limit to leaves
GO_LEAVES?=$(GO_SELECT_DIR)/leaves

# genes that support selected functions
GO_GENES?=$(GO_SELECT_DIR)/genes

#############################################################################
# gene word table
#############################################################################

FUNC_GENE_WORD_MIN_COUNT?=2
FUNC_GENE_WORD_TABLE?=$(FUNC_SET_DIR)/gene_word_table.txt
FUNC_GENE_WORD_BACKTABLE?=$(FUNC_SET_DIR)/gene_word_backtable.txt
FUNC_GENE_WORD_FILTER?="Chromosome Partitioning Associated Proteins Dependent Predicted Modification Alpha C D 4 N Putative Like Core Site MULTISPECIES DNA RNA Protein Domain Subunit Major Cluster Related Region And Type Transcriptional Regulatory System Family I II S Specific Related_cluster Of Site-specific"
FUNC_GENE_WORD_WHOLE?="single-stranded helix-turn-helix DNA-binding transcriptional_regulator related_cluster ABC_transporter 50S_ribosomal_protein 30S_ribosomal_protein"

#####################################################################################################
# matching randomized gene sets
#####################################################################################################

GO_FDR_DIR?=$(FUNC_SET_DIR)/FDR_dir
GO_FDR_PERMUTE_COUNT?=1000
FUNC_DRY?=F

#####################################################################################################
# subjects
#####################################################################################################

FUNC_DIR1?=$(call reval,FUNC_DIR,c=$(CFG1))
FUNC_DIR2=$(call reval,FUNC_DIR,c=$(CFG2))

GO_FINAL1?=$(call reval,GO_FINAL,c=$(CFG1))
GO_FINAL2?=$(call reval,GO_FINAL,c=$(CFG2))

GO_SELECT1?=$(call reval,GO_SELECT,c=$(CFG1))
GO_SELECT2?=$(call reval,GO_SELECT,c=$(CFG2))

GO_LEAVES1?=$(call reval,GO_LEAVES,c=$(CFG1))
GO_LEAVES2?=$(call reval,GO_LEAVES,c=$(CFG2))

SUBJECT1?=$(call reval,SUBJECT,c=$(CFG1))
SUBJECT2?=$(call reval,SUBJECT,c=$(CFG2))

#####################################################################################################
# plotting
#####################################################################################################

ATABLE_DIR?=$(ANCHOR_FIGURE_DIR)/all_tables

FUNC_FDIR?=$(ANCHOR_FIGURE_DIR)/func/$(FUNC_VERSION)_$(GO_SELECT_VERSION)

