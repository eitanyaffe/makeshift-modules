#######################################################################################
# compute inter-contig matrix
#######################################################################################

CONTIG_MATRIX_DONE=$(CONTIG_MATRIX_BASE_DIR)/.done_base
$(CONTIG_MATRIX_DONE): $(CNT_SIM_DONE)
	$(call _start,$(CONTIG_MATRIX_BASE_DIR))
	@mkdir -p \
		$(CONTIG_CONTACTS) \
		$(CONTIG_MASKED_CONTACTS)
	$(call _time,$(CONTIG_MATRIX_BASE_DIR),matrix) \
		perl $(_md)/pl/contact_map.pl \
			$(CNT_PAIRED_DIR_IN) \
			$(CONTIG_TABLE) \
			$(SIM_RESULT_DIR) \
			$(CONTIG_MATRIX_SIMILARITY_OFFSET) \
			$(CONTIG_CONTACTS) \
			$(CONTIG_MASKED_CONTACTS) \
			$(CONTIG_MATRIX)
	$(_end_touch)
cmatrix_base: $(CONTIG_MATRIX_DONE)

#######################################################################################
# stats
#######################################################################################

CONTIG_MATRIX_STATS_DONE?=$(CONTIG_MATRIX_BASE_DIR)/.done_stats
$(CONTIG_MATRIX_STATS_DONE): $(CONTIG_MATRIX_DONE)
	$(_start)
	$(_R) R/contig_matrix_stats.r stats \
		ifn=$(CONTIG_MATRIX) \
		ofn=$(CONTIG_MATRIX_STATS)
	$(_end_touch)
cmatrix_stats: $(CONTIG_MATRIX_STATS_DONE)

cnt_matrix: $(CONTIG_MATRIX_STATS_DONE)
