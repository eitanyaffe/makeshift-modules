units=sweep.mk
$(call _register_module,sweep,$(units),)

#####################################################################################################
# input/output
#####################################################################################################

# contig2bin table
SWP_CONTIG2BIN?=$(C2B_TABLE)

# all bins
SWP_BINS_TABLE?=$(BINS_TABLE)

# sweep candidate bins
SWP_SELECTED_BINS?=$(BINS_TABLE)
# SWP_SELECTED_BINS?=$(SNPS_CHANGE_SUMMARY)

# contact map
SWP_CONTIG_MATRIX?=$(CONTIG_MATRIX)

# genes/uniref
SWP_GENES_IN?=$(GENE_TABLE)
SWP_CONTIGS_IN?=$(CONTIG_TABLE)
SWP_UNIREF_IN?=$(UNIREF_GENE_TAX_TABLE)

# output dirs
SWP_BASE_DIR?=$(ASSEMBLY_DIR)
SWP_VERSION=v3
SWP_DIR?=$(SWP_BASE_DIR)/sweep/$(SWP_VERSION)

# figures
SWP_BASE_FDIR?=$(BASE_FDIR)
SWP_FDIR?=$(SWP_BASE_FDIR)/sweep/$(SWP_VERSION)

#####################################################################################################
# compute contig-bin summary for a specific lib
#####################################################################################################

SWP_LIB_DIR?=$(SWP_DIR)/libs/$(LIB_ID)

# input: contact map
SWP_CONTIG_MATRIX?=$(CONTIG_MATRIX)

# output: contig-bin contact count
SWP_EB?=$(SWP_LIB_DIR)/contig_bin.table

#####################################################################################################
# compare
#####################################################################################################

# lib ids
SWP_LIB_A?=pre_hic
SWP_LIB_B?=post_hic
SWP_CMP_LABEL?=pre_vs_post

SWP_EB_A?=$(call reval,SWP_EB,LIB_ID=$(SWP_LIB_A))
SWP_EB_B?=$(call reval,SWP_EB,LIB_ID=$(SWP_LIB_B))

SWP_CMP_DIR?=$(SWP_DIR)/$(SWP_CMP_LABEL)
SWP_CMP_TABLE?=$(SWP_CMP_DIR)/table

# compute linear fit ratio
SWP_BIN_RATIO?=$(SWP_CMP_DIR)/bins.ratio

#####################################################################################################
# classify changes
#####################################################################################################

#SWP_MIN_LOG_FOLD_CHANGE=1.69897
#SWP_MIN_CONTACTS=100
SWP_MIN_LOG_FOLD_CHANGE=0.3
SWP_MIN_CONTACTS=100

# min ratio between A/B coverages
SWP_MIN_RATIO?=0.1

SWP_TABLE_CLASS?=$(SWP_CMP_DIR)/eb.class

# genes+uniref for elements that were classified as gain/loss
SWP_GENES?=$(SWP_CMP_DIR)/genes.txt
