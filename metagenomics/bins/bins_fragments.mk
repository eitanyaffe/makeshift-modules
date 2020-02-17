###############################################################################################
# breakdown contigs into short fragments
###############################################################################################

# generate fragment table
FRAGMENT_TABLE_DONE?=$(BINS_FRAGMENT_DIR)/.done_table
$(FRAGMENT_TABLE_DONE):
	$(call _start,$(BINS_FRAGMENT_DIR))
	$(_R) $(_md)/R/bins.r frag.table \
		ifn=$(BINS_IN_CONTIG_TABLE) \
		style=$(BINS_FRAGMENT_SIZE_STYLE) \
		breakdown.size=$(BINS_FRAGMENT_BREAKDOWN_SIZE) \
		ofn=$(BINS_FRAGMENT_TABLE)
	$(_end_touch)
bins_frag_table: $(FRAGMENT_TABLE_DONE)

# generate fragment fasta
FRAGMENT_FASTA_DONE?=$(BINS_FRAGMENT_DIR)/.done_fasta
$(FRAGMENT_FASTA_DONE): $(FRAGMENT_TABLE_DONE)
	$(_start)
	perl $(_md)/pl/generate_fragment_fasta.pl \
		$(BINS_IN_CONTIG_FASTA) \
		$(BINS_FRAGMENT_TABLE) \
		$(BINS_FRAGMENT_FASTA)
	$(_end_touch)
bins_frag_fa: $(FRAGMENT_FASTA_DONE)

# metaBAT contig table, with fragments
BINS_METABAT_IN_DONE?=$(BINS_FRAGMENT_DIR)/.done_metabat_in
$(BINS_METABAT_IN_DONE): $(FRAGMENT_FASTA_DONE)
	$(_start)
	$(_R) $(_md)/R/bins.r metabat.contig.table \
		ifn=$(BINS_FRAGMENT_TABLE) \
		ofn=$(BINS_METABAT_CONTIG_TABLE)
	$(_end_touch)
bins_fragments: $(BINS_METABAT_IN_DONE)
