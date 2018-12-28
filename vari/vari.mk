
SFILES=$(addprefix $(_md)/cpp/,varisum.cpp Params.cpp Params.h util.cpp util.h)
$(eval $(call bin_rule2,varisum,$(SFILES)))
VARISUM_BIN=$(_md)/bin.$(shell hostname)/varisum

init_vari: $(VARISUM_BIN)

# compute variance over selected catalog genes
VAR_DONE?=$(MAP_DIR)/.done_poly
$(VAR_DONE):
	$(call _assert,VAR_INPUT_CONTIG_TABLE)
	$(_start)
	@mkdir -p $(VAR_OUTPUT_FULL_DIR) $(VAR_OUTPUT_CLIPPED_DIR)
	$(VARISUM_BIN) \
		-idir $(VAR_INPUT_PARSE_DIR) \
		-contigs $(VAR_INPUT_CONTIG_TABLE) \
		-contig_field $(VAR_INPUT_ITEM_FIELD) \
		-min_score $(VAR_MIN_SCORE) \
		-min_length $(VAR_MIN_MATCH_LENGTH) \
		-max_edit $(VAR_MAX_EDIT_DISTANCE) \
		-odir_full $(VAR_OUTPUT_FULL_DIR) \
		-odir_clipped $(VAR_OUTPUT_CLIPPED_DIR)
	$(_end_touch)
vari: $(VAR_DONE)

VAR_BIN_DONE?=$(MAP_DIR)/.done_polybin
$(VAR_BIN_DONE):
	$(_start)
	$(_R) $(_md)/R/vari_bin.r vari.bin \
		ifn.table=$(VAR_INPUT_CONTIG_TABLE) \
		field=$(VAR_INPUT_ITEM_FIELD) \
		dir.full=$(VAR_OUTPUT_FULL_DIR) \
		dir.clipped=$(VAR_OUTPUT_CLIPPED_DIR) \
		bin.sizes=$(VAR_BIN_SIZES) \
		snp.percent.threshold=$(VAR_POLY_PERCENT_THRESHOLD) \
		snp.count.threshold=$(VAR_POLY_COUNT_THRESHOLD) \
		snp.fixed.percent.threshold=$(VAR_POLY_FIXED_PERCENT_THRESHOLD)
	$(_end_touch)
vari_bin: $(VAR_BIN_DONE)

VAR_SUMMARY_DONE?=$(MAP_DIR)/.done_poly_summary
$(VAR_SUMMARY_DONE):
	$(_start)
	$(_R) $(_md)/R/vari_summary.r vari.summary \
		ifn.table=$(VAR_INPUT_CONTIG_TABLE) \
		field=$(VAR_INPUT_ITEM_FIELD) \
		dir.full=$(VAR_OUTPUT_FULL_DIR) \
		dir.clipped=$(VAR_OUTPUT_CLIPPED_DIR) \
		snp.percent.threshold=$(VAR_POLY_PERCENT_THRESHOLD) \
		snp.count.threshold=$(VAR_POLY_COUNT_THRESHOLD) \
		snp.fixed.percent.threshold=$(VAR_POLY_FIXED_PERCENT_THRESHOLD) \
		ofn=$(VAR_SUMMARY)
	$(_end_touch)
vari_summary: $(VAR_SUMMARY_DONE)

