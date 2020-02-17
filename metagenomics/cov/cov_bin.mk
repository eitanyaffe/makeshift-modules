COV_CLUSTER_DONE?=$(COV_DIR)/.done_table
$(COV_TABLE_DONE): $(COV_LIBS_DONE)
	$(call _start,$(COV_DIR))
	$(_Rcall) $(CURDIR) $(_md)/R/cov_table.r make.cov.table \
		base.dir=$(COV_DIR) \
		ids=$(COV_IDS) \
		ofn=$(COV_LIB_TABLE)
	$(_end_touch)
cov_table: $(COV_TABLE_DONE)
