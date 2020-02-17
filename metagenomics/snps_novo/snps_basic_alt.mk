# unified snps tables with all libs
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

SNPS_CLASSIFY_POS_DONE?=$(SNPS_DIR)/.done_classify_pos
$(SNPS_CLASSIFY_POS_DONE): $(SNPS_UNIFIED_DONE)
	$(call _start,$(SNPS_DIR))
	perl $(_md)/pl/snp_classify_pos.pl \
		$(SNPS_UNIFIED_PREFIX) \
		$(_SNPS_MIN_TOTAL_COUNT) \
		$(_SNPS_FIX_THRESHOLD) \
		$(_SNPS_POLY_THRESHOLD) \
		$(_SNPS_CLASSIFIED_TABLE)
#	$(_end_touch)
snps_class_pos: $(SNPS_CLASSIFY_POS_DONE)
