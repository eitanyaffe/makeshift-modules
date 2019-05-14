PRODIGAL_DONE?=$(PRODIGAL_DIR)/.done
$(PRODIGAL_DONE):
	$(call _start,$(PRODIGAL_DIR))
	$(PRODIGAL_BIN) -q -f gff \
		-p $(PRODIGAL_SELECT_PROCEDURE) \
		-i $(PRODIGAL_INPUT) \
		-a $(PRODIGAL_AA) \
		-d $(PRODIGAL_NT) \
		-o $(PRODIGAL_OUTPUT_RAW)
	$(_end_touch)
prodigal: $(PRODIGAL_DONE)
