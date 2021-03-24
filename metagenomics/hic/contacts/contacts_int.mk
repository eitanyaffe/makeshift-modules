#####################################################################################################
# register module
#####################################################################################################

units:=contacts_similarity.mk contacts_matrix.mk contact_plots.mk contacts_bins.mk
$(call _register_module,contacts,$(units),,)

#####################################################################################################
# general params
#####################################################################################################

CNT_ROOT_DIR?=$(OUTPUT_DIR)
CNT_ROOT_QSUB_DIR?=$(QSUB_DIR)

# output directory
CNT_VER?=v1
CNT_DIR?=$(CNT_ROOT_DIR)/contacts/$(CNT_VER)
CNT_QSUB_DIR=$(CNT_ROOT_QSUB_DIR)/contacts

# figures
CNT_BASE_FDIR?=$(BASE_FDIR)
CNT_FDIR?=$(CNT_BASE_FDIR)/contacts

#####################################################################################################
# input tables
#####################################################################################################

CNT_CONTIG_TABLE_IN?=$(CONTIG_TABLE)
CNT_CONTIG_FILE_IN?=$(CONTIG_FASTA)

CNT_C2B_IN?=$(METABAT_TABLE)
CNT_BINS_IN?=$(METABAT_BIN_CLASS)

# with number of polysites
CNT_BINS_SITES_IN?=$(STRAIN_BIN_TABLE)

# mapped read pairs
CNT_PAIRED_DIR_IN?=$(PAIRED_DIR)

#####################################################################################################
# similarity
#####################################################################################################

# this is common to all libs
SIM_DIR?=$(CNT_DIR)/similarity
SIM_RESULT_DIR?=$(SIM_DIR)/result
SIM_SPLIT_DIR?=$(SIM_DIR)/split
SIM_QSUB_DIR?=$(CNT_QSUB_DIR)/similarity

# mummer paths
#MUMMER_DIR?=/home/eitany/work/download/MUMmer3.23
#MUMMER?=$(MUMMER_DIR)/mummer
#NUCMER?=$(MUMMER_DIR)/nucmer
#SHOWCOORD?=$(MUMMER_DIR)/show-coords

MUMMER_DOCKER?=sudo dr run -i biocontainers/mummer:v3.23dfsg-4-deb_cv1
MUMMER?=$(MUMMER_DOCKER) mummer
NUCMER?=$(MUMMER_DOCKER) nucmer
SHOWCOORD?=$(MUMMER_DOCKER) show-coords

# number of files
SIM_CHUNKS?=10

#######################################################################################
# contig matrix
#######################################################################################

# extend similarity rects by this offset when masking out contacts between similar regions
CONTIG_MATRIX_SIMILARITY_OFFSET=2000

CONTIG_MATRIX_BASE_DIR?=$(CNT_DIR)/libs/$(LIB_ID)

# contacts
CONTIG_CONTACTS?=$(CONTIG_MATRIX_BASE_DIR)/filtered_contacts
CONTIG_MASKED_CONTACTS?=$(CONTIG_MATRIX_BASE_DIR)/masked_contacts
CONTIG_MATRIX?=$(CONTIG_MATRIX_BASE_DIR)/table

# stats
CONTIG_MATRIX_STATS?=$(CONTIG_MATRIX_BASE_DIR)/cmatrix_stats

#######################################################################################
# !!! all this already implemented in sweep module
# summarize by bins
#######################################################################################

# bin vs. bin matrix
CNT_BIN_DIR?=$(CONTIG_MATRIX_BASE_DIR)/bins
CNT_BIN_MATRIX?=$(CNT_BIN_DIR)/bin_matrix

# compare two maps
CNT_HIC_COMPARE_LABEL?=pre_vs_post
RDATASET1?=pre_hic
RDATASET2?=post_hic

CNT_LEGEND1?=pre
CNT_LEGEND2?=post

CNT_BIN_MATRIX1?=$(call reval,CNT_BIN_MATRIX,LIB_ID=$(RDATASET1))
CNT_BIN_MATRIX2?=$(call reval,CNT_BIN_MATRIX,LIB_ID=$(RDATASET2))
CNT_MIN_FIT_SUPPORT?=5

CNT_COMPARE_DIR?=$(CNT_DIR)/compare/$(CNT_HIC_COMPARE_LABEL)
CNT_BIN_TABLE_COMPARE?=$(CNT_COMPARE_DIR)/bins
CNT_MAP_COMPARE?=$(CNT_COMPARE_DIR)/map

# for plotting
CNT_MIN_CONTACTS?=5
