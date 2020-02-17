CLEAN_DONE?=$(LIB_DIR)/.done_clean_libs
$(CLEAN_DONE):
	$(_start)
	rm -rf \
		$(DUP_DIR) \
		$(TRIMMOMATIC_OUTDIR) \
		$(LIB_SPLIT_DIR) \
		$(DECONSEQ_DIR) \
		$(DECONSEQ_QSUB_DIR) \
		$(PAIRED_BOTH_DIR) \
		$(PAIRED_R1_DIR) \
		$(PAIRED_R2_DIR)
	$(_end_touch)
libs_clobber: $(CLEAN_DONE)
