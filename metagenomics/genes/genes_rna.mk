# UNIREF_RNA_INPUT_DONE?=$(RNA_UNIREF_DIR)/.done_input
# $(UNIREF_RNA_INPUT_DONE):
# 	$(call _start,$(RNA_UNIREF_DIR))
# 	cat $(RNA_UNIREF_INPUT) >> $(RNA_UNIREF_QUERY)
# 	$(_end_touch)
# rna_uniref_input: $(UNIREF_RNA_INPUT_DONE)

# UNIREF_RNA_DB_DONE?=$(RNA_UNIREF_DIR)/.done_db
# $(UNIREF_RNA_INPUT_DONE):
# 	$(call _start,$(RNA_UNIREF_DIR))
# 	cat $(RNA_UNIREF_INPUT) >> $(RNA_UNIREF_QUERY)
# 	$(_end_touch)
# rna_uniref_input: $(UNIREF_RNA_INPUT_DONE)

UNIREF_RNA_BLAST_DONE?=$(RNA_UNIREF_DIR)/.done_rna_diamond_blast
$(UNIREF_RNA_BLAST_DONE):
	@mkdir -p $(UNIREF_DIAMOND_DB_DIR)
	$(call _start,$(RNA_UNIREF_DIR))
	@$(MAKE) reads_diamond_blast \
		BLAST_DIR=$(RNA_UNIREF_DIR) \
		BLAST_QUERY=$(RNA_UNIREF_QUERY) \
		BLAST_TARGET_TABLE=$(UNIREF_GENE_TABLE) \
		BLAST_TARGET_FASTA=$(GENE_REF_IFN) \
		DIAMOND_INDEX=$(UNIREF_DIAMOND_DB) \
		DIAMOND_COMMAND=blastx \
		BLAST_RESULT_SAM=$(RNA_UNIREF_SAM)
	$(_end_touch)
rna_uniref: $(UNIREF_RNA_BLAST_DONE)
