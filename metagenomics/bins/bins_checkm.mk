# select large bins for checkm
BINS_CHECKM_SELECT_DONE?=$(BINS_CHECKM_DIR)/.done_checkm_input
$(BINS_CHECKM_SELECT_DONE): $(BINS_CONTIG_FASTA_DONE)
	$(call _start,$(BINS_CHECKM_DIR))
	$(_R) $(_md)/R/bins_checkm.r bin.select \
		ifn=$(BINS_SUMMARY_BASIC) \
		min.length=$(BINS_SELECT_BINSIZE) \
		ofn=$(BINS_CHECKM_BIN_SELECT)
	$(_end_touch)
bins_checkm_select: $(BINS_CHECKM_SELECT_DONE)

# generate fasta for checkm
BINS_CHECKM_FASTA_DONE?=$(BINS_CHECKM_DIR)/.done_checkm_fasta
$(BINS_CHECKM_FASTA_DONE): $(BINS_CHECKM_SELECT_DONE)
	$(call _start,$(BINS_CHECKM_FASTA_DIR))
	perl $(_md)/pl/create_bins_fasta.pl \
		$(BINS_CONTIG_FASTA) \
		$(BINS_CHECKM_BIN_SELECT) \
		$(BINS_CONTIG_TABLE) \
		$(BINS_CHECKM_FASTA_DIR)
	$(_end_touch)
bins_checkm_fasta: $(BINS_CHECKM_FASTA_DONE)

# run checkm
BINS_CHECKM_DONE?=$(BINS_CHECKM_DIR)/.done_checkm_main
$(BINS_CHECKM_DONE): $(BINS_CHECKM_FASTA_DONE)
	$(_start)
	rm -rf $(BINS_CHECKM_DIR)/SCG
	$(CHECKM) lineage_wf -t 40 --tab_table \
		-f $(BINS_CHECKM_DIR)/CheckM.txt \
		-x fasta $(BINS_CHECKM_FASTA_DIR) \
		$(BINS_CHECKM_DIR)/SCG
	$(_end_touch)
bins_checkm_main: $(BINS_CHECKM_DONE)

BINS_CHECKM_PARSE_DONE?=$(BINS_CHECKM_DIR)/.done_parse
$(BINS_CHECKM_PARSE_DONE): $(BINS_CHECKM_DONE)
	$(_start)
	$(_R) $(_md)/R/bins_checkm.r checkm.parse \
		ifn.checkm=$(BINS_CHECKM_DIR)/CheckM.txt \
		ifn.bin.table=$(BINS_CHECKM_BIN_SELECT) \
		ofn=$(BINS_CHECKM_RESULT)
	$(_end_touch)
bins_checkm_parse: $(BINS_CHECKM_PARSE_DONE)

# classify bins
BINS_CHECKM_CLASSIFY_DONE?=$(BINS_CHECKM_DIR)/.done_classify
$(BINS_CHECKM_CLASSIFY_DONE): $(BINS_CHECKM_PARSE_DONE)
	$(_start)
	$(_R) $(_md)/R/bins_classify.r bins.classify \
		ifn.bins=$(BINS_SUMMARY_BASIC) \
		ifn.checkm=$(BINS_CHECKM_RESULT) \
		min.genome.complete=$(BINS_MIN_GENOME_COMPLETE) \
		max.genome.contam=$(BINS_MAX_GENOME_CONTAM) \
		max.element.complete=$(BINS_MAX_ELEMENT_COMPLETE) \
		ofn=$(BINS_TABLE)
	$(_end_touch)
bins_classify: $(BINS_CHECKM_CLASSIFY_DONE)

###############################################################################################
###############################################################################################

make_bins: bins_fragments bins_metabat bins_classify
