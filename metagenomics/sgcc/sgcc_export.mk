# export stats
sgcc_export:
	mkdir -p $(SGCC_EXPORT_DIR)
	cp $(SGCC_COMPARE_TABLE) $(SGCC_EXPORT_DIR)/kmer.mat
