MAP_INPUT_DONE?=$(MAP_INPUT_DIR)/.done_gunzip
$(MAP_INPUT_DONE):
	$(call _start,$(MAP_INPUT_DIR))
	$(call _time,$(MAP_INPUT_DIR),in_R1) \
		cp $(MAP_INPUT_R1_GZ) $(MAP_INPUT_R1).gz
	$(call _time,$(MAP_INPUT_DIR),unzip_R1) \
		pigz -d -p $(MAP_PIGZ_THREADS) $(MAP_INPUT_R1).gz
	$(call _time,$(MAP_INPUT_DIR),in_R2) \
		cp $(MAP_INPUT_R2_GZ) $(MAP_INPUT_R2).gz
	$(call _time,$(MAP_INPUT_DIR),unzip_R2) \
		pigz -d -p $(MAP_PIGZ_THREADS) $(MAP_INPUT_R2).gz
	$(_end_touch)
map_input: $(MAP_INPUT_DONE)

MAP_SPLIT_DONE?=$(MAP_SPLIT_DIR)/.done
$(MAP_SPLIT_DONE): $(MAP_INPUT_DONE)
	$(call _start,$(MAP_SPLIT_DIR))
	$(call _time,$(MAP_SPLIT_DIR),split) \
	perl $(_md)/pl/split_fastq_pair.pl \
		$(MAP_CHUNK_TABLE) \
		$(MAP_SPLIT_DIR) \
		$(MAP_SPLIT_READS_PER_FILE) \
		$(MAP_SPLIT_TRIM) \
		$(MAP_SPLIT_READ_OFFSET) \
		$(MAP_SPLIT_READ_LENGTH) \
		$(MAP_INPUT_R1) \
		$(MAP_INPUT_R2)
	wc -l $(MAP_CHUNK_TABLE)
	$(_end_touch)
map_split: $(MAP_SPLIT_DONE)
