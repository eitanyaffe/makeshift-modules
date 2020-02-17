
###############################################################################################
# cluster using metaBAT
###############################################################################################

BINS_METABAT_VER?=v3
BINS_METABAT_DONE?=$(BINS_OUTPUT_DIR)/.done_metabat_$(BINS_METABAT_VER)
$(BINS_METABAT_DONE):
	$(call _start,$(BINS_OUTPUT_DIR))
	@$(foreach ID,$(BINS_LIB_IDS),$(MAKE) m=metaBAT METABAT_ID=$(ID) mb_bam; $(ASSERT);)
	@$(MAKE) m=metaBAT mb_final
	$(_end_touch)
bins_run_metabat: $(BINS_METABAT_DONE)

###############################################################################################
# group consecutive fragments of the same cluster into contigs and elements
###############################################################################################

# process metaBAT: create contig table and basic bin table
BINS_SEGMENT_TABLE_DONE?=$(BINS_OUTPUT_DIR)/.done_segments
$(BINS_SEGMENT_TABLE_DONE): $(BINS_METABAT_DONE)
	$(call _start,$(BINS_OUTPUT_DIR))
	perl $(_md)/pl/create_segment_table.pl \
		$(BINS_FRAGMENT_TABLE) \
		$(BINS_FRAGMENT_BIN) \
		$(BINS_SEGMENT_TABLE)
	$(_end_touch)
bins_segment_table: $(BINS_SEGMENT_TABLE_DONE)

# final contig table
BINS_CONTIG_TABLE_DONE?=$(BINS_OUTPUT_DIR)/.done_contigs
$(BINS_CONTIG_TABLE_DONE): $(BINS_SEGMENT_TABLE_DONE)
	$(_start)
	$(_R) $(_md)/R/bins_contigs.r contig.table \
		ifn=$(BINS_SEGMENT_TABLE) \
		ofn.contigs=$(BINS_CONTIG_TABLE) \
		ofn.contigs.associated=$(BINS_CONTIG_TABLE_ASSOCIATED) \
		ofn.bins=$(BINS_SUMMARY_BASIC)
	$(_end_touch)
bins_contig_table: $(BINS_CONTIG_TABLE_DONE)

# create final contig fasta
BINS_CONTIG_FASTA_DONE?=$(BINS_OUTPUT_DIR)/.done_contig_fasta
$(BINS_CONTIG_FASTA_DONE): $(BINS_CONTIG_TABLE_DONE)
	$(_start)
	perl $(_md)/pl/extract_segment_fasta.pl \
		$(BINS_IN_CONTIG_FASTA) \
		$(BINS_CONTIG_TABLE) \
		$(BINS_CONTIG_FASTA)
	$(_end_touch)
bins_contig_fasta: $(BINS_CONTIG_FASTA_DONE)

bins_metabat: $(BINS_CONTIG_FASTA_DONE)
