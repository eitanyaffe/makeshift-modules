#######################################################################################
# compute inter-contig matrix
#######################################################################################

CONTIG_MATRIX_DONE=$(CONTIG_MATRIX_BASE_DIR)/.done_base
$(CONTIG_MATRIX_DONE): $(SIM_DONE)
	$(call _start,$(CONTIG_MATRIX_BASE_DIR))
	@mkdir -p \
		$(CONTIG_CONTACTS) \
		$(CONTIG_MASKED_CONTACTS)
	$(call _time,$(DATASET_DIR),matrix) \
		perl $(_md)/pl/contig_matrix.pl \
			$(PAIRED_DIR) \
			$(CONTIG_TABLE) \
			$(COVERAGE_TABLE) \
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

contig_matrix: $(CONTIG_MATRIX_STATS_DONE)

#######################################################################################
# plots
#######################################################################################

make_plot_contig_matrix:
	$(_R) R/contig_matrix.r plot.contig.matrix \
		adir=$(ASSEMBLY_DIR) \
		fdir=$(SET_FIGURE_DIR)/cc_matrix \
		aid=$(ASSEMBLY_ID) \
		ids=$(LIB_IDS) \
		ver=$(CONTIG_MATRIX_VERSION) \
		titles=$(LIB_TITLES)
