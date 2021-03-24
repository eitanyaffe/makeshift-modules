# select large bins for checkm
METABAT_CHECKM_SELECT_DONE?=$(METABAT_CHECKM_DIR)/.done_checkm_input
$(METABAT_CHECKM_SELECT_DONE): $(METABAT_BIN_TABLE_DONE)
	$(call _start,$(METABAT_CHECKM_DIR))
	$(_R) $(_md)/R/bins_checkm.r bin.select \
		ifn=$(METABAT_BIN_TABLE) \
		min.length=$(METABAT_SELECT_BINSIZE) \
		ofn=$(METABAT_CHECKM_BIN_SELECT)
	$(_end_touch)
mb_checkm_select: $(METABAT_CHECKM_SELECT_DONE)

# generate fasta for checkm
METABAT_CHECKM_FASTA_DONE?=$(METABAT_CHECKM_DIR)/.done_checkm_fasta
$(METABAT_CHECKM_FASTA_DONE): $(METABAT_CHECKM_SELECT_DONE)
	$(call _start,$(METABAT_CHECKM_FASTA_DIR))
	perl $(_md)/pl/create_bins_fasta.pl \
		$(METABAT_CONTIG_FASTA) \
		$(METABAT_CHECKM_BIN_SELECT) \
		$(METABAT_TABLE) \
		$(METABAT_CHECKM_FASTA_DIR)
	$(_end_touch)
mb_checkm_fasta: $(METABAT_CHECKM_FASTA_DONE)

# run checkm
METABAT_CHECKM_DONE?=$(METABAT_CHECKM_DIR)/.done_checkm_main
$(METABAT_CHECKM_DONE): $(METABAT_CHECKM_FASTA_DONE)
	$(_start)
	rm -rf $(METABAT_CHECKM_DIR)/SCG
	$(CHECKM) lineage_wf -t $(METABAT_CHECKM_THREADS) --tab_table \
		-f $(METABAT_CHECKM_DIR)/CheckM.txt \
		-x fasta $(METABAT_CHECKM_FASTA_DIR) \
		$(METABAT_CHECKM_DIR)/SCG
	$(_end_touch)
mb_checkm_main: $(METABAT_CHECKM_DONE)

METABAT_CHECKM_PARSE_DONE?=$(METABAT_CHECKM_DIR)/.done_parse
$(METABAT_CHECKM_PARSE_DONE): $(METABAT_CHECKM_DONE)
	$(_start)
	$(_R) $(_md)/R/bins_checkm.r checkm.parse \
		ifn.checkm=$(METABAT_CHECKM_DIR)/CheckM.txt \
		ifn.bin.table=$(METABAT_CHECKM_BIN_SELECT) \
		ofn=$(METABAT_CHECKM_RESULT)
	$(_end_touch)
mb_checkm_parse: $(METABAT_CHECKM_PARSE_DONE)

# classify bins
METABAT_CHECKM_CLASSIFY_DONE?=$(METABAT_CHECKM_DIR)/.done_classify
$(METABAT_CHECKM_CLASSIFY_DONE): $(METABAT_CHECKM_PARSE_DONE)
	$(_start)
	$(_R) $(_md)/R/bins_classify.r bins.classify \
		ifn.bins=$(METABAT_BIN_TABLE) \
		ifn.checkm=$(METABAT_CHECKM_RESULT) \
		min.genome.complete=$(METABAT_MIN_GENOME_COMPLETE) \
		max.genome.contam=$(METABAT_MAX_GENOME_CONTAM) \
		max.element.complete=$(METABAT_MAX_ELEMENT_COMPLETE) \
		ofn=$(METABAT_BIN_CLASS)
	$(_end_touch)
mb_checkm: $(METABAT_CHECKM_CLASSIFY_DONE)

mb_all: $(METABAT_CHECKM_CLASSIFY_DONE)
