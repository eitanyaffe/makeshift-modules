
#####################################################################################################
# break contig
#####################################################################################################

COV_BREAK_DONE?=$(COV_ANALYSIS_DIR)/.done_break
$(COV_BREAK_DONE): $(COV_TABLE_DONE)
	$(call _start,$(COV_CONTIG_DIR))
	$(COV_BIN) refine \
		-ifn $(COV_LIB_TABLE) \
		-outlier_fraction $(COV_OUTLIER_FRACTION) \
		-p_value $(COV_PVALUE) \
		-pseudo_count $(COV_PSEUDO_COUNT) \
		-max_lib_count $(COV_MAX_LIB_COUNT) \
		-weight_style $(COV_WEIGHT_STYLE) \
		-min_center_segment_length $(COV_MIN_CENTER_SEGMENT_LENGTH) \
		-ofn_contigs $(COV_CONTIG_SUMMARY) \
		-ofn_segments $(COV_SEGMENT_TABLE)
	$(_end_touch)
cov_break: $(COV_BREAK_DONE)

#####################################################################################################
# final assembly
#####################################################################################################

COV_CONTIG_TABLE_DONE?=$(COV_ANALYSIS_DIR)/.done_contig_table
$(COV_CONTIG_TABLE_DONE): $(COV_BREAK_DONE)
	$(_start)
	$(_R) R/cov.r make.contig.table \
		ifn=$(COV_SEGMENT_TABLE) \
		ofn=$(COV_CONTIG_TABLE)
	$(_end_touch)
cov_contig_table: $(COV_CONTIG_TABLE_DONE)

COV_FASTA_DONE?=$(COV_ANALYSIS_DIR)/.done_fasta
$(COV_FASTA_DONE): $(COV_BREAK_DONE)
	$(_start)
	perl $(_md)/pl/generate_segment_fasta.pl \
		$(COV_INPUT_CONTIG_FASTA) \
		$(COV_SEGMENT_TABLE) \
		$(COV_CONTIG_FASTA)
	$(_end_touch)
cov_fasta: $(COV_FASTA_DONE)

cov_all: $(COV_FASTA_DONE) $(COV_CONTIG_TABLE_DONE)
