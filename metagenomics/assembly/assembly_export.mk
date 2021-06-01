# export stats
assembly_export:
	mkdir -p $(ASSEMBLY_EXPORT_DIR)
	cp $(ASSEMBLY_STATS_TABLE) $(ASSEMBLY_EXPORT_DIR)/
