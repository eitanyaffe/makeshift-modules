CLEAN_DONE?=$(LIB_DIR)/.done_clean_libs
$(CLEAN_DONE):
	$(_start)
	rm -rf \
		$(DUP_DIR) \
		$(TRIMMOMATIC_OUTDIR) \
		$(LIB_SPLIT_DIR) \
		$(DECONSEQ_DIR) \
		$(DECONSEQ_QSUB_DIR)
	$(_end_touch)
libs_clobber: $(CLEAN_DONE)
