CNT_BIN_MATRIX_DONE=$(CNT_BIN_DIR)/.done_matrix
$(CNT_BIN_MATRIX_DONE):
	$(call _start,$(CNT_BIN_DIR))
		perl $(_md)/pl/bin_matrix.pl \
		$(CONTIG_MATRIX) \
		$(CNT_C2B_IN) \
		$(CNT_BINS_IN) \
		$(CNT_BIN_MATRIX)
	$(_end_touch)
cbin_matrix: $(CNT_BIN_MATRIX_DONE)

CNT_COMPARE_DONE?=$(CNT_COMPARE_DIR)/.done_compare
$(CNT_COMPARE_DONE):
	$(call _start,$(CNT_COMPARE_DIR))
	$(_R) R/cnt_bins_compare.r cnt.maps.merge \
		ifn.contigs=$(CNT_CONTIG_TABLE_IN) \
		ifn.bins=$(CNT_BINS_IN) \
		ifn.map1=$(CNT_BIN_MATRIX1) \
		ifn.map2=$(CNT_BIN_MATRIX2) \
		min.support=$(CNT_MIN_FIT_SUPPORT) \
		ofn.bins=$(CNT_BIN_TABLE_COMPARE) \
		ofn.map=$(CNT_MAP_COMPARE)
	$(_end_touch)
cnt_hic_compare: $(CNT_COMPARE_DONE)

contact_bins: $(CNT_BIN_MATRIX_DONE)
