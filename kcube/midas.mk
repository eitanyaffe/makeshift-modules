MIDAS_INIT_DONE=$(MIDAS_REF_DIR)/.done_init
$(MIDAS_INIT_DONE):
	$(call _start,$(MIDAS_REF_DIR))
	$(_R) $(_md)/R/midas.r get.refs \
		idir=$(MIDAS_PANGENOME_INPUT_DIR) \
		odir=$(MIDAS_REF_DIR)
	$(_end_touch)
midas_refs: $(MIDAS_INIT_DONE)
