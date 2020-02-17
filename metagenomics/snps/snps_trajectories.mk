# unified snps tables with all libs
SNPS_TRJ_BASE_DONE?=$(SNPS_SET_DIR)/.done_trj_base
$(SNPS_TRJ_BASE_DONE): $(SNPS_VARI_DONE)
	$(call _start,$(SNPS_DIR))
	$(call _time,$(SNPS_DIR),unify_libs) perl $(_md)/pl/select_snp_tables.pl \
		$(SNPS_INPUT_CONTIG_TABLE) \
		$(SNPS_GENE_DETAILS) \
		$(SNPS_VARI_BASE_DIR) \
		$(SNPS_SELECT_ONLY_FIXED) \
		$(SNPS_SELECTED_PREFIX) \
		$(SNPS_IDS)
	$(_end_touch)
snps_trj_base: $(SNPS_TRJ_BASE_DONE)

# limit to fixed positions
SNPS_TRJ_DONE?=$(SNPS_SET_DIR)/.done_trj
$(SNPS_TRJ_DONE): $(SNPS_TRJ_BASE_DONE)
	$(_start)
	$(_R) R/snp_trj.r extract.trj \
		ifn.pos2gene=$(SNPS_GENE_DETAILS) \
		ifn.gene2contig=$(SNPS_GENE_SUMARY) \
		ifn.contig2bin=$(SNPS_INPUT_CONTIG_TABLE) \
		ifn.bins=$(BINS_TABLE) \
		prefix=$(SNPS_SELECTED_PREFIX) \
		ofn.base=$(SNPS_TRJ_BASE) \
		ofn.set=$(SNPS_TRJ_SET) \
		ofn.positions=$(SNPS_TRJ_POSITIONS)
	$(_end_touch)
snps_trj: $(SNPS_TRJ_DONE)

plot_trj_mat:
	$(_R) R/plot_trj.r plot.trj.matrix \
		ifn.bins=$(SNPS_CHANGE_SUMMARY) \
		ifn.pos=$(SNPS_TRJ_POSITIONS) \
		ifn.base=$(SNPS_TRJ_BASE) \
		ifn.set=$(SNPS_TRJ_SET) \
		prefix=$(SNPS_SELECTED_PREFIX) \
		lib.labels=$(SNPS_TRJ_LABELS) \
		fdir=$(SNPS_FDIR)/trajectory_matrices
