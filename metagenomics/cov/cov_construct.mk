cov_lib_map:
	@$(MAKE) m=map map_basic map_clean \
		MAP_ROOT=$(COV_MAP_ROOT) \
		MAP_SEQ_FILE=$(COV_INPUT_CONTIG_FASTA)

COV_LIB_CONSTRUCT_DONE?=$(COV_LIB_DIR)/.done_construct
$(COV_LIB_CONSTRUCT_DONE):
	$(call _start,$(COV_LIB_DIR))
	$(COV_BIN) construct \
		-idir $(COV_PARSE_DIR) \
		-contig_table $(COV_INPUT_CONTIG_TABLE) \
		-discard_clipped $(COV_DISCARD_CLIPPED) \
		-min_score $(COV_MIN_SCORE) \
		-min_length $(COV_MIN_MATCH_LENGTH) \
		-max_edit $(COV_MAX_EDIT_DISTANCE) \
		-ofn $(COV_DS)
	$(_end_touch)
cov_lib_construct: $(COV_LIB_CONSTRUCT_DONE)

cov_lib: cov_lib_map cov_lib_construct

COV_LIBS_DONE?=$(COV_DIR)/.done_cov_libs
$(COV_LIBS_DONE):
	$(_start)
	$(_Rcall) $(CURDIR) $(_md)/R/cov_libs.r make.libs \
		ids=$(COV_IDS) \
		module=$(m) \
		target=cov_lib \
		is.dry=$(DRY)
	$(_end_touch)
cov_libs: $(COV_LIBS_DONE)

COV_TABLE_DONE?=$(COV_DIR)/.done_table
$(COV_TABLE_DONE): $(COV_LIBS_DONE)
	$(call _start,$(COV_DIR))
	$(_Rcall) $(CURDIR) $(_md)/R/cov_table.r make.cov.table \
		base.dir=$(COV_DIR) \
		ids=$(COV_IDS) \
		ofn=$(COV_LIB_TABLE)
	$(_end_touch)
cov_table: $(COV_TABLE_DONE)
