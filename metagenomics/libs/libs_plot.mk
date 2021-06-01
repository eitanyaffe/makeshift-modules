plot_stats:
	$(_R) $(_md)/R/plot_stats.r plot.stats \
		ifn.reads.count=$(STATS_READS_COUNTS) \
		ifn.reads.yield=$(STATS_READS_YIELD) \
		ifn.bps.count=$(STATS_BPS_COUNTS) \
		ifn.bps.yield=$(STATS_BPS_YIELD) \
		fdir=$(LIBS_FDIR)/all_libs

plot_stats_selected:
	$(_R) $(_md)/R/plot_stats.r plot.stats.selected \
		ifn.selected=$(LIBS_SELECT_TABLE) \
		ifn.reads.count=$(STATS_READS_COUNTS) \
		ifn.reads.yield=$(STATS_READS_YIELD) \
		ifn.bps.count=$(STATS_BPS_COUNTS) \
		ifn.bps.yield=$(STATS_BPS_YIELD) \
		fdir=$(LIBS_FDIR)/selected_libs
