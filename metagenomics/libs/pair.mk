PAIR_DONE?=$(PAIRED_DIR)/.done
$(PAIR_DONE):
	$(call _start,$(PAIRED_DIR))
	$(call _time,$(PAIRED_DIR),pair) perl $(_md)/pl/pair_fastq.pl \
		$(PAIRED_IN_R1) \
		$(PAIRED_IN_R2) \
		$(PAIRED_R1) \
		$(PAIRED_R2) \
		$(NON_PAIRED_R1) \
		$(NON_PAIRED_R2)
	$(_end_touch)
pair: $(PAIR_DONE)
