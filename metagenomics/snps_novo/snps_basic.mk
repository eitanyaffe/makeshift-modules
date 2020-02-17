#########################################################################################################
# create 1-bp vari profiles
#########################################################################################################

snps_vari_lib:
	@$(MAKE) m=map map
	@$(MAKE) m=vari vari vari_compress

SNPS_VARI_DONE?=$(SNPS_DIR)/.done_vari
$(SNPS_VARI_DONE):
	$(call _start,$(SNPS_DIR))
	@$(foreach ID,$(SNPS_IDS),$(MAKE) LIB_ID=$(ID) snps_vari_lib; $(ASSERT);)
	$(_end_touch)
snps_vari: $(SNPS_VARI_DONE)

#########################################################################################################
# unified snps tables with all libs
#########################################################################################################

SNPS_UNIFIED_DONE?=$(SNPS_DIR)/.done_unify
$(SNPS_UNIFIED_DONE): $(SNPS_VARI_DONE)
	$(call _start,$(SNPS_DIR))
	$(call _time,$(SNPS_DIR),unify_libs) perl $(_md)/pl/unify_snp_tables.pl \
		$(SNPS_INPUT_CONTIG_TABLE) \
		$(SNPS_VARI_BASE_DIR) \
		$(SNPS_UNIFIED_PREFIX) \
		$(SNPS_IDS)
	$(_end_touch)
snps_unified: $(SNPS_UNIFIED_DONE)

#########################################################################################################
# classify positions
#########################################################################################################

SNPS_CLASSIFY_POS_DONE?=$(SNPS_DIR)/.done_classify_pos
$(SNPS_CLASSIFY_POS_DONE): $(SNPS_UNIFIED_DONE)
	$(call _start,$(SNPS_DIR))
	perl $(_md)/pl/snp_classify_pos.pl \
		$(SNPS_UNIFIED_PREFIX) \
		$(SNPS_MIN_TOTAL_COUNT) \
		$(SNPS_FIX_THRESHOLD) \
		$(SNPS_POLY_THRESHOLD) \
		$(SNPS_CLASSIFIED_TABLE)
	$(_end_touch)
snps_class_pos: $(SNPS_CLASSIFY_POS_DONE)

#########################################################################################################
# assign bins
#########################################################################################################

SNPS_BINS_DONE?=$(SNPS_DIR)/.done_bins
$(SNPS_BINS_DONE): $(SNPS_CLASSIFY_POS_DONE)
	$(_start)
	$(_R) R/snps_position.r bin.pos \
		ifn.snps=$(SNPS_CLASSIFIED_TABLE) \
		ifn.contigs=$(BINS_CONTIG_TABLE_ASSOCIATED) \
		ofn=$(SNPS_BINS)
	$(_end_touch)
snps_bins: $(SNPS_BINS_DONE)

# extract trajectories of selected positions
SNPS_BIN_SELECT_DONE?=$(SNPS_DIR)/.done_bins_select
$(SNPS_BIN_SELECT_DONE): $(SNPS_BINS_DONE)
	$(_start)
	perl $(_md)/pl/snp_select_pos.pl \
		$(SNPS_BINS) \
		$(SNPS_UNIFIED_PREFIX) \
		$(SNPS_SELECTED_PREFIX)
	$(_end_touch)
snps_bins_select: $(SNPS_BIN_SELECT_DONE)

snps_basic: $(SNPS_BIN_SELECT_DONE)

#########################################################################################################
# plots
#########################################################################################################

plot_trajectories:
	$(_R) R/plot_snps.r plot.host.trajectories \
		ifn.snps=$(SNPS_BINS) \
		ifn.bins=$(BINS_TABLE) \
		prefix=$(SNPS_SELECTED_PREFIX) \
		fdir=$(SNPS_FDIR)/host_trajectories
