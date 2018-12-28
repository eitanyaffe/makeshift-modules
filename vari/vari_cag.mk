
# add cag id to profiles
VAR_CAG_DONE?=$(MAP_DIR)/.done_cag_var
$(VAR_CAG_DONE): $(VAR_DONE)
	$(_start)
	perl $(_md)/pl/append_group_file.pl \
		$(VAR_INPUT_CONTIG_TABLE) \
		$(VAR_INPUT_ITEM_FIELD) \
		$(VAR_INPUT_GROUP_FIELD) \
		$(VAR_TABLE_NT) \
		$(CAG_NT) \
		$(CAG_EXPLODE_DIR) \
		nt
	perl $(_md)/pl/append_group_file.pl \
		$(VAR_INPUT_CONTIG_TABLE) \
		$(VAR_INPUT_ITEM_FIELD) \
		$(VAR_INPUT_GROUP_FIELD) \
		$(VAR_TABLE_NT_COV) \
		$(CAG_NT_COV) \
		$(CAG_EXPLODE_DIR) \
		nt_cov
	perl $(_md)/pl/append_group_file.pl \
		$(VAR_INPUT_CONTIG_TABLE) \
		$(VAR_INPUT_ITEM_FIELD) \
		$(VAR_INPUT_GROUP_FIELD) \
		$(VAR_TABLE_LINK) \
		$(CAG_LINK) \
		$(CAG_EXPLODE_DIR) \
		link
	perl $(_md)/pl/append_group_file.pl \
		$(VAR_INPUT_CONTIG_TABLE) \
		$(VAR_INPUT_ITEM_FIELD) \
		$(VAR_INPUT_GROUP_FIELD) \
		$(VAR_TABLE_LINK_COV) \
		$(CAG_LINK_COV) \
		$(CAG_EXPLODE_DIR) \
		link_cov
	$(_end_touch)
vari_cag: $(VAR_CAG_DONE)
