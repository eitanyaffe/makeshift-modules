SPLIT_DONE?=$(SPLIT_DIR)/.done
$(SPLIT_DONE):
	$(call _start,$(SPLIT_DIR))
	$(call _time,$(SPLIT_DIR),split) \
	perl $(_md)/pl/split_fastq_pair.pl \
		$(CHUNK_TABLE) \
		$(SPLIT_DIR) \
		$(SPLIT_SIZE) \
		F 0 0 \
		$(SPLIT_INPUT_R1) \
		$(SPLIT_INPUT_R2)
	$(_end_touch)
libs_split: $(SPLIT_DONE)
