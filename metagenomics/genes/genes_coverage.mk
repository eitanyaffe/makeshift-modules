#############################################################################################
# single lib
#############################################################################################

GENES_COVERAGE_LIB_DONE?=$(GENES_COVERAGE_LIB_DIR)/.done_lib
$(GENES_COVERAGE_LIB_DONE):
	$(call _start,$(GENES_COVERAGE_LIB_DIR))
	perl $(_md)/pl/genes_coverage.pl \
		$(PRODIGAL_GENE_TABLE) \
		$(GENES_LIB_INPUT_R1) \
		$(GENES_LIB_INPUT_R2) \
		$(GENES_COVERAGE_REMOVE_CLIP) \
		$(GENES_COVERAGE_MIN_SCORE) \
		$(GENES_COVERAGE_MAX_EDIT_DISTANCE) \
		$(GENES_COVERAGE_MIN_MATCH_LENGTH) \
		$(GENES_COVERAGE_LIB_TABLE) \
		$(GENES_COVERAGE_LIB_STATS)
	$(_end_touch)
genes_cov_lib: $(GENES_COVERAGE_LIB_DONE)

# all libs
S_GENES_COVERAGE_LIBS_DONE?=$(GENES_COVERAGE_INFO_DIR)/.done_libs
$(S_GENES_COVERAGE_LIBS_DONE):
	$(_start)
	$(MAKE) m=par par_tasks_complex \
		PAR_MODULE=genes \
		PAR_NAME=genes_cov_libs \
		PAR_WORK_DIR=$(GENES_COVERAGE_INFO_DIR) \
		PAR_TARGET=genes_cov_lib \
		PAR_TASK_ITEM_TABLE=$(GENES_LIBS_TABLE) \
		PAR_TASK_ITEM_VAR=MAP_LIB_ID \
		PAR_TASK_ODIR_VAR=GENES_COVERAGE_LIB_DIR \
		PAR_PREEMTIBLE=0 \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_genes_cov_libs: $(S_GENES_COVERAGE_LIBS_DONE)

#############################################################################################
# gene matrix over entire assembly
#############################################################################################

# RPK gene trajectory
GENES_COVERAGE_MATRIX_DONE?=$(GENES_COVERAGE_OUT_DIR)/.done_gene_matrix
$(GENES_COVERAGE_MATRIX_DONE): $(GENES_COVERAGE_LIBS_DONE)
	$(call _start,$(GENES_COVERAGE_OUT_DIR))
	$(_R) $(_md)/R/gene_matrix.r gene.matrix \
		ifn.genes=$(PRODIGAL_GENE_TABLE) \
		ifn.libs=$(GENES_LIBS_TABLE) \
		idir=$(GENES_COVERAGE_DIR) \
		ofn=$(GENES_COVERAGE_GENE_MATRIX)
	$(_end_touch)
genes_cov: $(GENES_COVERAGE_MATRIX_DONE)

# wrapper VM 
S_GENES_COVERAGE_MATRIX_DONE?=$(GENES_COVERAGE_INFO_DIR)/.done_matrix
$(S_GENES_COVERAGE_MATRIX_DONE): $(S_GENES_COVERAGE_LIBS_DONE)
	$(_start)
	$(MAKE) m=par par \
		PAR_MODULE=genes \
		PAR_NAME=genes_cov_mat \
		PAR_WORK_DIR=$(GENES_COVERAGE_INFO_DIR) \
		PAR_ODIR_VAR=GENES_COVERAGE_OUT_DIR \
		PAR_TARGET=genes_cov \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_genes_cov_mat: $(S_GENES_COVERAGE_MATRIX_DONE)

#############################################################################################
# all assemblies
#############################################################################################

# compute gene coverage matrices
GENES_MULTI_COV_DONE?=$(GENES_COVERAGE_MULTI_DIR)/.done_genes_matrices
$(GENES_MULTI_COV_DONE):
	$(_start)
	$(MAKE) m=par par_tasks_complex \
		PAR_MODULE=genes \
		PAR_NAME=genes_cov_task \
		PAR_TARGET=s_genes_cov_mat \
		PAR_WORK_DIR=$(GENES_COVERAGE_MULTI_DIR) \
		PAR_TASK_ITEM_TABLE=$(GENES_ASSEMBLY_TABLE) \
		PAR_TASK_ITEM_VAR=ASSEMBLY_ID \
		PAR_TASK_ODIR_VAR=GENES_COVERAGE_INFO_DIR \
		PAR_PREEMTIBLE=3 \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_genes_cov_multi: $(GENES_MULTI_COV_DONE)
