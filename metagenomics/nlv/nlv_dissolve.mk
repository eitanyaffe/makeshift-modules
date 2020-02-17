NLV_DISSOLVE_TABLE_DONE?=$(NLV_DISSOLVE_DIR)/.done_table
$(NLV_DISSOLVE_TABLE_DONE):
	$(call _start,$(NLV_DISSOLVE_DIR))
	$(_Rcall) $(CURDIR) $(_md)/R/nlv_sets.r make.set.table \
		ifn=$(NLV_SET_DEFS) \
		base.dir=$(NLV_SET_BASEDIR) \
		ofn=$(NLV_DISSOLVE_INPUT_TABLE)
	$(_end_touch)
nlv_dissolve_table: $(NLV_DISSOLVE_TABLE_DONE)

NLV_DISSOLVE_DUMP_DONE?=$(NLV_DISSOLVE_DIR)/.done_dump
$(NLV_DISSOLVE_DUMP_DONE): $(NLV_DISSOLVE_TABLE_DONE)
	$(_start)
	$(NLV_BIN) dissolve \
		-ifn $(NLV_DISSOLVE_INPUT_TABLE) \
		-contig $(NLV_DISSOLVE_CONTIG) \
		-outlier_fraction $(NLV_DISSOLVE_OUTLIER_FRACTION) \
		-p_value $(NLV_DISSOLVE_PVALUE) \
		-ofn $(NLV_DISSOLVE_CONTIG_DUMP)
	$(_end_touch)
nlv_dissolve_dump: $(NLV_DISSOLVE_DUMP_DONE)
