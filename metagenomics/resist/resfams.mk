RESFAMS_DONE?=$(RESFAMS_DIR)/.done_resfams
$(RESFAMS_DONE):
	$(call _start,$(RESFAMS_DIR))
	$(HMMER_SEARCH) \
		--cut_ga --cpu $(RESFAM_HMM_THREADS) --tblout $(RESFAMS_RAW) \
		$(RESFAM_HMM) \
		$(GENE_FASTA_AA) \
		> $(RESFAMS_DIR)/.log
	$(_end_touch)
resfams_base: $(RESFAMS_DONE)

RESFAM_PARSE_DONE?=$(RESFAMS_DIR)/.done_parse
$(RESFAM_PARSE_DONE): $(RESFAMS_DONE)
	$(_start)
	perl $(_md)/pl/parse_resfams_output.pl \
		$(RESFAMS_RAW) \
		$(RESFAMS_TABLE)
	$(_end_touch)
resfams_parse: $(RESFAM_PARSE_DONE)

RESFAM_FILTER_DONE?=$(RESFAMS_DIR)/.done_filter
$(RESFAM_FILTER_DONE): $(RESFAM_PARSE_DONE)
	$(_start)
	$(_R) R/resfams.r select.hits \
		ifn=$(RESFAMS_TABLE) \
		ifn.genes=$(GENE_TABLE) \
		min.evalue=$(RESFAMS_MIN_EVALUE) \
		min.bitscore=$(RESFAMS_MIN_BITSCORE) \
		ofn=$(RESFAMS_TABLE_SELECTED)
	$(_end_touch)
resfams_filter: $(RESFAM_FILTER_DONE)
