# create single index file
INDEX_DONE?=$(MAP_INDEX_DIR)/.done
$(INDEX_DONE):
	$(call _start,$(MAP_INDEX_DIR))
	$(BWA_BIN) index \
		-p $(MAP_INDEX_PREFIX) \
		$(MAP_CONTIG_FILE)
	$(_end_touch)
map_index: $(INDEX_DONE)
