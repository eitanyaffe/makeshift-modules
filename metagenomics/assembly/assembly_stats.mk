STATS_DONE?=$(ASSEMBLY_MULTI_STATS_DIR)/.done
$(STATS_DONE):
	$(call _start,$(ASSEMBLY_MULTI_STATS_DIR))
	$(_R) $(_md)/R/assembly_stats.r collect.stats \
		ifn=$(ASSEMBLY_TABLE) \
		idir=$(ASSEMBLY_BASE_DIR) \
		ofn=$(ASSEMBLY_STATS_TABLE)
	$(_end_touch)
assembly_stats: $(STATS_DONE)

plot_stats:
	$(_R) $(_md)/R/assembly_stats.r plot.stats \
		ifn=$(ASSEMBLY_STATS_TABLE) \
		fdir=$(ASSEMBLY_FDIR)
