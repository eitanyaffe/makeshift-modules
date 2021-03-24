GENE2BIN_TABLE_DONE?=$(PRODIGAL_DIR)/.done_gene2bin
$(GENE2BIN_TABLE_DONE):
	$(_start)
	$(_R) $(_md)/R/gene2bin.r gene2bin.table \
		ifn.genes=$(GENE_TABLE) \
		ifn.bins=$(BINS_TABLE) \
		ifn.contigs=$(GENES_C2B_TABLE) \
		ofn=$(GENE2BIN_TABLE)
	$(_end_touch)
genes_bintable: $(GENE2BIN_TABLE_DONE)
