#####################################################################################################
# register module
#####################################################################################################

units=export.mk
$(call _register_module,export,$(units),)

#####################################################################################################
# anchor export
#####################################################################################################

BASE_EXPORT_DIR?=$(BASE_OUTDIR)/export/$(PROJECT_ID)
EXPORT_DIR?=$(BASE_EXPORT_DIR)/assembly_$(ASSEMBLY_ID)
LIB_EXPORT_DIR?=$(EXPORT_DIR)/lib_$(LIB_ID)
ANCHOR_EXPORT_DIR?=$(LIB_EXPORT_DIR)/anchor_$(ANCHOR)

# keep original variable name
EXPORT_VARIALBES?=\
CONTIG_TABLE \
GENE_TABLE UNIREF_GENE_TAX_TABLE \
CONTIG_TABLE_FILTERED CONTIG_MATRIX_FILTERED CCLUSTER_CONTIGS \
INITIAL_ANCHOR_TABLE ANCHOR_TABLE ANCHOR_COVERAGE_TABLE ANCHOR_GC_TABLE ANCHOR_MATRIX_TABLE ANCHOR_INFO_TABLE \
CA_ANCHOR_CONTIGS \
ANCHOR_CLUSTER_TABLE \
POLY_10Y_DIR POLY_CURRENT_DIR RESFAMS_TABLE_SELECTED \
SC_GENE_TABLE \
KCUBE_BASE_DIR \
SC_CORE_TABLE SC_CORE_GENES \
SC_ELEMENT_TABLE SC_GENE_ELEMENT SC_ELEMENT_ANCHOR \
EVO_ELEMENT_FATE_CLASS_10Y EVO_ELEMENT_TABLE_CURRENT

EXPORT_VARIALBES_NOEVAL?=

# variables which we name here
# DATASET1?=pre_lib_hic_simple
# DATASET2?=post_lib_hic_simple
# EXPORT_VARIALBES_NOEVAL?=\
# PRE_COVERAGE=$(call reval,COVERAGE_TABLE,DATASET=$(DATASET1)) POST_COVERAGE=$(call reval,COVERAGE_TABLE,DATASET=$(DATASET2)) \
# PRE_MATRIX=$(call reval,CA_MATRIX,DATASET=$(DATASET1)) POST_MATRIX=$(call reval,CA_MATRIX,DATASET=$(DATASET2)) \
# PRE_CONTIG_MATRIX_FILTERED=$(call reval,CONTIG_MATRIX_FILTERED,DATASET=$(DATASET1)) POST_CONTIG_MATRIX_FILTERED=$(call reval,CONTIG_MATRIX_FILTERED,DATASET=$(DATASET2)) \
# PRE_VAR_SUMMARY=$(call reval,VAR_SUMMARY,DATASET=pre_lib_sg_simple MAP_SPLIT_TRIM=F) POST_VAR_SUMMARY=$(call reval,VAR_SUMMARY,DATASET=post_lib_sg_simple MAP_SPLIT_TRIM=F)

# this table keeps original file names, for local viewing
EXPORT_TABLE?=$(ANCHOR_EXPORT_DIR)/table_selected

# copy files, for export to other machine
EXPORT_ODIR?=$(ANCHOR_EXPORT_DIR)/files
EXPORT_ODIR_TAR?=$(ANCHOR_EXPORT_DIR)/files.tar.gz

#####################################################################################################
# flat structure, used by the hpipe wrapper
#####################################################################################################

FLAT_DIR?=$(OUTDIR)/result
