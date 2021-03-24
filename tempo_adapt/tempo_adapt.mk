MOCK_ANCHOR_TABLE_DONE?=$(SUBJECT_DIR)/.done_mock_anchor_table_v1
$(MOCK_ANCHOR_TABLE_DONE):
	$(_start)
	$(_R) R/mock_anchor_table.r anchor.table \
		ifn=$(BINS_TABLE) \
		ofn=$(MOCK_ANCHOR_TABLE)
	$(_end_touch)
make_mock_anchor_table: $(MOCK_ANCHOR_TABLE_DONE)
