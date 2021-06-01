# export stats
map_export:
	mkdir -p $(MAP_EXPORT_DIR)
	cp $(MAP_STATS_BWA) \
		$(MAP_STATS_FILTER) \
		$(MAP_STATS_PAIRED) \
		$(MAP_EXPORT_DIR)/
