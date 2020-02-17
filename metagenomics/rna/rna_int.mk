units=rna_basic.mk rna_genes.mk rna_plot.mk rna_compare.mk
$(call _register_module,rna,$(units),)

#####################################################################################################
# basic input/output
#####################################################################################################

# contig table
RNA_INPUT_CONTIG_TABLE?=$(CONTIG_TABLE)

# gene table
RNA_INPUT_GENE_TABLE?=$(GENE_TABLE)

# bins table
RNA_BINS_TABLE?=$(BINS_TABLE)

# gene to bin
RNA_GENE2BIN?=$(GENE2BIN_TABLE)

# table with all samples/libs
RNA_LIB_MAP_TABLE?=$(SUBJECT_RNA_LIB_TABLE)

# table with selected samples
RNA_LIB_DEF_TABLE?=$(SUBJECT_LIB_DEF_TABLE)

# output
RNA_DIR?=$(ASSEMBLY_DIR)/rna_v1
RNA_FDIR?=$(BASE_FDIR)/rna

#####################################################################################################
# run map module
#####################################################################################################

# all lib ids
RNA_IDS?=i1 i2 i3

# filtered reads
RNA_FILTER_DIR?=$(FILTER_DIR)

#####################################################################################################
# summary by gene
#####################################################################################################

# rna-specific filters

# remove if read clipped at all
RNA_REMOVE_CLIP?=T
RNA_MIN_SCORE?=60
RNA_MAX_EDIT_DISTANCE?=2
RNA_MIN_MATCH_LENGTH?=100

RNA_LIB_DIR?=$(RNA_DIR)/libs/$(LIB_ID)

RNA_LIB_TABLE?=$(RNA_LIB_DIR)/gene.table
RNA_LIB_STATS?=$(RNA_LIB_DIR)/gene.stats

# gene RPK trajectory over libs
RNA_GENE_MATRIX?=$(RNA_DIR)/gene.matrix

#####################################################################################################
# summary by bin
#####################################################################################################

# binned genes
RNA_BINNED_GENES?=$(RNA_DIR)/binned_genes

RNA_BIN_DIR?=$(RNA_DIR)/bins

#####################################################################################################
# compare two time points
#####################################################################################################

RNA_SET_LABEL=base_vs_post
RNA_SET1?=base
RNA_SET2?=post

RNA_COMPARE_DIR=$(RNA_DIR)/compare/$(RNA_SET_LABEL)
RNA_COMPARE_TABLE=$(RNA_COMPARE_DIR)/table
