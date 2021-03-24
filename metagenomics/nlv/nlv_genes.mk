NLV_GENES_DONE?=$(NLV_GENES_DIR)/.done
$(NLV_GENES_DONE):
	$(call _start,$(NLV_GENES_DIR))
	perl $(_md)/pl/nlv_genes.pl \
		$(NLV_INPUT_GENE_TABLE) \
		$(NLV_INPUT_GENE_UNIREF) \
		$(NLV_GENES_SITES) \
		$(NLV_GENES_TABLE)
	$(_end_touch)
nlv_genes: $(NLV_GENES_DONE)
