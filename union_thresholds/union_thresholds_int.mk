
#####################################################################################################
# register module
#####################################################################################################

units=unt.mk
$(call _register_module,unt,$(units),)

#####################################################################################################
# basic paths
#####################################################################################################

UNT_DIR?=$(DATASET_ANCHOR_DIR)/union_thresholds
UNT_FDIR?=$(ANCHOR_FIGURE_DIR)/union_thresholds

# complete anchor-union matrix
UNT_MATRIX_IN?=$(CA_MATRIX)

# param table
UNT_PARAM_TABLE=$(CURDIR)/input/union_params.tab

# output dir with all param options
UNT_PARAM_DIR?=$(UNT_DIR)/params

#####################################################################################################
# for going over all parameters
#####################################################################################################

UNT_DRY?=F
UNT_TARGET?=unt_checkm

#####################################################################################################
# specific set
#####################################################################################################

UNT_PARAMETER?=CA_MIN_CONTACTS
UNT_VALUE?=8
UNT_WORK_DIR?=$(UNT_PARAM_DIR)/$(UNT_PARAMETER)/$(UNT_VALUE)

# ca table
UNT_ANCHOR_CONTIGS?=$(UNT_WORK_DIR)/ca.table

# checkm
UNT_CHECKM_DIR?=$(UNT_WORK_DIR)/checkm

#####################################################################################################
# summary tables
#####################################################################################################

UNT_CHECKM_TABLE?=$(UNT_DIR)/checkm.tab

UNT_GENOME_TABLE?=$(UNT_DIR)/genome.tab
