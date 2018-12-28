#####################################################################################################
# register module
#####################################################################################################

units=export.mk
$(call _register_module,export,$(units),)

#####################################################################################################
# anchor export
#####################################################################################################

EXPORT_DIR?=$(OUTPUT_DIR)/export

# keep original variable name
EXPORT_VARIALBES?=\
CAG_SELECTED \
GENE_SELECTED \
LIB_TABLE

# user evals these variables
EXPORT_VARIALBES_NOEVAL?=

# this table keeps original file names, for local viewing
EXPORT_TABLE?=$(EXPORT_DIR)/table

# copy files, for export to other machine
EXPORT_ODIR?=$(EXPORT_DIR)/export_$(EXPORT_ID)
EXPORT_ODIR_TAR?=$(EXPORT_DIR)/export_$(EXPORT_ID).tar.gz

