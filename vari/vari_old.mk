
SFILES=$(addprefix $(_md)/cpp/,varisum.cpp Params.cpp Params.h util.cpp util.h)
$(eval $(call bin_rule2,varisum,$(SFILES)))
VARISUM_BIN=$(_md)/bin.$(shell hostname)/varisum

init_vari: $(VARISUM_BIN)

# compute variance over selected catalog genes
VAR_DONE?=$(MAP_DIR)/.done_var
$(VAR_DONE): $(PARSE_DONE)
	$(_start)
	@mkdir -p $(VAR_TABLE_NT_COV_DIR) $(VAR_TABLE_LINK_COV_DIR)
	$(VARISUM_BIN) \
		-idir $(PARSE_DIR) \
		-contigs $(VAR_INPUT_CONTIG_TABLE) \
		-contig_field $(VAR_INPUT_ITEM_FIELD) \
		-margin $(VAR_MARGIN) \
		-ofn_nt $(VAR_TABLE_NT) \
		-ofn_link $(VAR_TABLE_LINK) \
		-ofn_nt_cov $(VAR_TABLE_NT_COV) \
		-ofn_link_cov $(VAR_TABLE_LINK_COV) \
		-odir_nt_cov $(VAR_TABLE_NT_COV_DIR) \
		-odir_link_cov $(VAR_TABLE_LINK_COV_DIR)
	$(_end_touch)
vari: $(VAR_DONE)
