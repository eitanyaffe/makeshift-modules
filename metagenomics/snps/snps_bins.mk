SNPS_BINS_DONE?=$(SNPS_SET_DIR)/.done_bins
$(SNPS_BINS_DONE): $(SNPS_GENE_SNPS_DONE)
	$(_start)
	$(_R) R/snps_bins.r bin.table \
		ifn.genes=$(SNPS_GENE_SUMARY) \
		ifn.bins=$(BINS_TABLE) \
		ifn.contigs=$(BINS_CONTIG_TABLE_ASSOCIATED) \
		min.cov=$(SNPS_MIN_GENE_COVERAGE) \
		ofn=$(SNPS_BIN_TABLE)
	$(_end_touch)
snps_bins: $(SNPS_BINS_DONE)

SNPS_CHANGE_DONE?=$(SNPS_SET_DIR)/.done_changed
$(SNPS_CHANGE_DONE):
	$(_start)
	$(_R) R/snps_change.r get.change \
		ifn.bins=$(SNPS_BIN_TABLE) \
		ifn.genes=$(SNPS_GENE_SUMARY) \
		ifn.uniref=$(UNIREF_GENE_TAX_TABLE) \
		ifn.contigs=$(BINS_CONTIG_TABLE_ASSOCIATED) \
		min.cov=$(SNPS_CHANGE_MIN_COVERAGE) \
		max.fix.density=$(SNPS_CHANGE_MAX_FIX_DENSITY) \
		ofn.summary=$(SNPS_CHANGE_SUMMARY) \
		ofn.genes=$(SNPS_CHANGE_GENES)
	$(_end_touch)
snps_change: $(SNPS_CHANGE_DONE)
