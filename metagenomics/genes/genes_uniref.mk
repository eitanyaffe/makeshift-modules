
$(UNIREF_TABLE):
	$(call _start,$(UNIREF_TABLE_DIR))
	$(_md)/pl/make_uniref_table.pl \
		$(GENE_REF_IFN) \
		$@
	$(_end)
uniref_table: $(UNIREF_TABLE)

UNIREF_TAX_LOOKUP_DONE?=$(UNIREF_TABLE_DIR)/.done
$(UNIREF_TAX_LOOKUP_DONE):
	$(call _start,$(UNIREF_TABLE_DIR))
	$(call _time,$(UNIREF_TABLE_DIR),lookup_table) \
		$(_md)/pl/make_uniref_lookup.pl \
		$(GENE_REF_XML_IFN) \
		$(UNIREF_TAX_LOOKUP)
	$(_end_touch)
uniref_lookup: $(UNIREF_TAX_LOOKUP_DONE)

$(UNIREF_GENE_TABLE): $(UNIREF_TABLE)
	$(_start)
	cat $(GENE_REF_IFN) | $(_md)/pl/uniref_summary.pl > $@
	$(_end)
uniref_gene_table: $(UNIREF_GENE_TABLE)

UNIREF_BLAST_DONE?=$(UNIREF_DIR)/.done_blast
$(UNIREF_BLAST_DONE): $(UNIREF_GENE_TABLE)
	@mkdir -p $(UNIREF_DIAMOND_DB_DIR)
	$(call _start,$(UNIREF_DIR))
	@$(MAKE) blast_aa \
		BLAST_DIR=$(UNIREF_DIR) \
		BLAST_QUERY_TABLE=$(GENE_TABLE) \
		BLAST_QUERY_FASTA=$(GENE_FASTA_AA) \
		BLAST_TARGET_TABLE=$(UNIREF_GENE_TABLE) \
		BLAST_TARGET_FASTA=$(GENE_REF_IFN) \
		DIAMOND_INDEX=$(UNIREF_DIAMOND_DB) \
		BLAST_RESULT=$(UNIREF_RAW_OFN)
	$(_end_touch)
uniref_blast: $(UNIREF_BLAST_DONE)

UNIREF_UNIQ_DONE?=$(UNIREF_DIR)/.done_uniq
$(UNIREF_UNIQ_DONE): $(UNIREF_BLAST_DONE)
	$(_start)
	$(call _time,$(UNIREF_DIR),uniq) $(_md)/pl/blast_to_uniq.pl \
		$(UNIREF_RAW_OFN) \
		$(UNIREF_OFN_UNIQUE)
	$(_end_touch)
uniref_uniq: $(UNIREF_UNIQ_DONE)

UNIREF_GENE_TAX_DONE?=$(UNIREF_DIR)/.done_gene_taxa
$(UNIREF_GENE_TAX_DONE): $(UNIREF_UNIQ_DONE) $(UNIREF_TABLE) $(UNIREF_TAX_LOOKUP_DONE)
	$(_start)
	$(call _time,$(UNIREF_DIR),lookup_uniref) \
		$(_md)/pl/lookup_uniref.pl \
			$(UNIREF_TABLE) \
			$(UNIREF_OFN_UNIQUE) \
			$(UNIREF_GENE_TAX_TABLE)
	$(_end_touch)
uniref_tax: $(UNIREF_GENE_TAX_DONE)

UNIREF_STATS_DONE?=$(UNIREF_DIR)/.done_stats
$(UNIREF_STATS_DONE): $(UNIREF_GENE_TAX_DONE)
	$(_start)
	$(_R) R/gene_stats.r gene.stats \
		ifn.genes=$(GENE_TABLE) \
		ifn.uniref=$(UNIREF_GENE_TAX_TABLE) \
		poor.annotation.desc=$(UNIREF_POOR_ANNOTATION) \
		ofn=$(UNIREF_STATS)
	$(_end_touch)
gene_stats: $(UNIREF_STATS_DONE)

UNIREF_TOP_DONE?=$(UNIREF_DIR)/.done_top
$(UNIREF_TOP_DONE): $(UNIREF_BLAST_DONE)
	$(_start)
	perl $(_md)/pl/blast_to_all.pl \
		$(UNIREF_RAW_OFN) \
		$(TOP_IDENTITY_RATIO) \
		$(TOP_IDENTITY_DIFF) \
		$(UNIREF_TOP)
	$(_end_touch)
uniref_top: $(UNIREF_TOP_DONE)

genes_uniref: $(UNIREF_GENE_TAX_DONE) $(UNIREF_STATS_DONE) $(UNIREF_TOP_DONE)
