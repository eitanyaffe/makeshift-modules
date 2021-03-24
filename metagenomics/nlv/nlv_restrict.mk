NLV_RESTRICT_CONTIGS_DONE?=$(NLV_DIR)/.done_restrict_contigs
$(NLV_RESTRICT_CONTIGS_DONE):
	$(_start)
	$(_R) R/nlv_bins.r restrict.contigs \
		ifn.bins=$(NLV_INPUT_BIN_TABLE) \
		ifn.c2b=$(NLV_INPUT_CONTIG2BIN) \
		bin.field=$(NLV_BIN_FIELD) \
		bin.value=$(NLV_BIN_VALUE) \
		ofn=$(NLV_RESTRICT_C2B)
	$(_end_touch)
nlv_restrict_contigs: $(NLV_RESTRICT_CONTIGS_DONE)

NLV_RESTRICT_DONE?=$(NLV_SET_DIR)/.done_restrict
$(NLV_RESTRICT_DONE): $(NLV_MERGE_DONE) $(NLV_RESTRICT_CONTIGS_DONE)
	$(_start)
	$(NLV_BIN) restrict \
		-ifn_nlv $(NLV_SET_DS) \
		-ifn_contigs $(NLV_RESTRICT_C2B) \
		-ofn $(NLV_RESTRICT_DS)
	$(_end_touch)
nlv_restrict_set: $(NLV_RESTRICT_DONE)

NLV_RESTRICT_SETS_DONE?=$(NLV_SET_BASEDIR)/.done_restrict_sets
$(NLV_RESTRICT_SETS_DONE): $(NLV_SETS_DONE)
	$(call _start,$(NLV_SET_BASEDIR))
	$(_Rcall) $(CURDIR) $(_md)/R/nlv_sets.r make.sets \
		ifn=$(NLV_SET_DEFS) \
		module=$(m) \
		target=nlv_restrict_set \
		is.dry=$(DRY)
	$(_end_touch)
nlv_restrict: $(NLV_RESTRICT_SETS_DONE)
