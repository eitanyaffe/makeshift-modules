SPLIT_DONE=$(LIB_SPLIT_DIR)/.done
$(SPLIT_DONE): $(PP_COUNT_TRIMMOMATIC)
	$(call _start,$(LIB_SPLIT_DIR))
	$(_md)/pl/split_fastq.pl \
		$(LIB_SPLIT_DIR) \
		$(SPLIT_SIZE) \
		F 0 0 \
		$(SPLIT_INPUT_R1) \
		$(SPLIT_INPUT_R2)
	$(_end_touch)
split: $(SPLIT_DONE)
