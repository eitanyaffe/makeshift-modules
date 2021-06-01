s_genes:
	$(MAKE) m=par par \
		PAR_WORK_DIR=$(GENES_INFO_DIR) \
		PAR_MODULE=genes \
		PAR_NAME=genes_single \
		PAR_ODIR_VAR=PRODIGAL_DIR \
		PAR_TARGET=prodigal \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"

# predict genes
GENES_MULTI_DONE?=$(GENES_MULTI_DIR)/.done_genes
$(GENES_MULTI_DONE):
	$(_start)
	$(MAKE) m=par par_tasks_complex \
		PAR_MODULE=genes \
		PAR_NAME=genes_task \
		PAR_WORK_DIR=$(GENES_MULTI_DIR) \
		PAR_TARGET=prodigal \
		PAR_TASK_ITEM_TABLE=$(GENES_ASSEMBLY_TABLE) \
		PAR_TASK_ITEM_VAR=ASSEMBLY_ID \
		PAR_TASK_ODIR_VAR=PRODIGAL_DIR \
		PAR_PREEMTIBLE=3 \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_genes_multi: $(GENES_MULTI_DONE)
