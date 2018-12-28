A2B_BLAST?=$(GENEMAP_DIR)/a2b_blast
A2B_TABLE?=$(GENEMAP_DIR)/a2b_table
A2B_DONE?=$(GENEMAP_DIR)/.done_a2b
$(A2B_DONE):
	$(_start)
	@$(MAKE) blast_diamond \
		BLAST_DIR=$(A2B_BLAST) \
		BLAST_QUERY_TABLE=$(GENE_TABLE_A) \
		BLAST_QUERY_FASTA=$(FASTA_A) \
		BLAST_TARGET_TABLE=$(GENE_TABLE_B) \
		BLAST_TARGET_FASTA=$(FASTA_B) \
		BLAST_QUERY_TYPE=aa \
		DIAMOND_INDEX=$(A2B_BLAST)/diamond.index \
		BLAST_RESULT=$(A2B_TABLE)
	$(_end_touch)
a2b: $(A2B_DONE)

B2A_BLAST?=$(GENEMAP_DIR)/b2a_blast
B2A_TABLE?=$(GENEMAP_DIR)/b2a_table
B2A_DONE?=$(GENEMAP_DIR)/.done_b2a
$(B2A_DONE):
	$(_start)
	@$(MAKE) blast_diamond \
		BLAST_DIR=$(B2A_BLAST) \
		BLAST_QUERY_TABLE=$(GENE_TABLE_B) \
		BLAST_QUERY_FASTA=$(FASTA_B) \
		BLAST_TARGET_TABLE=$(GENE_TABLE_A) \
		BLAST_TARGET_FASTA=$(FASTA_A) \
		BLAST_QUERY_TYPE=aa \
		DIAMOND_INDEX=$(B2A_BLAST)/diamond.index \
		BLAST_RESULT=$(B2A_TABLE)
	$(_end_touch)
b2a: $(B2A_DONE)

COLLAPSE_DONE?=$(GENEMAP_DIR)/.done_collpase
$(COLLAPSE_DONE): $(B2A_DONE) $(A2B_DONE)
	$(call _start,$(GENE_CLUSTER_DIR))
	perl $(_md)/pl/map_to_simple.pl \
		$(A2B_TABLE) \
		$(B2A_TABLE) \
		$(COLLAPSE_FIELD) \
		$(COLLAPSE_FUNCTION) \
		$(GENE_MAP)
	$(_end_touch)
gene_map: $(COLLAPSE_DONE)
