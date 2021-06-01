STATS_DONE?=$(MAP_MULTI_STATS_DIR)/.done
$(STATS_DONE):
	$(call _start,$(MAP_MULTI_STATS_DIR))
	$(_R) $(_md)/R/map_stats.r collect.stats \
		ifn=$(MAP_ASSEMBLY_TABLE) \
		idir=$(MAP_ROOT_DIR) \
		ofn.bwa=$(MAP_STATS_BWA) \
		ofn.filter=$(MAP_STATS_FILTER) \
		ofn.paired=$(MAP_STATS_PAIRED)
	$(_end_touch)
map_stats: $(STATS_DONE)

plot_stats:
	$(_R) $(_md)/R/map_stats.r plot.stats \
		ifn.bwa=$(MAP_STATS_BWA) \
		ifn.filter=$(MAP_STATS_FILTER) \
		ifn.paired=$(MAP_STATS_PAIRED) \
		fdir=$(MAP_FDIR)
