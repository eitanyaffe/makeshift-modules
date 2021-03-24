# read count summary
STATS_DONE?=$(STATS_DIR)/.done
$(STATS_DONE):
	$(call _start,$(STATS_DIR))
	$(_R) $(_md)/R/stats.r merge.stats \
		ldir=$(LIBS_STAT_DIR_IN) \
		ids=$(LIB_IDS) \
		ofn.count=$(STATS_COUNTS) \
		ofn.yield=$(STATS_YIELD)
	$(_end_touch)
lib_stats: $(STATS_DONE)

plot_stats:
	$(_R) $(_md)/R/qc_plots.r plot.stats \
		ldir=$(LIBS_DIR) \
		fdir=$(LIB_STATS_FDIR) \
		ids=$(LIB_STATS_IDS) \
		titles=$(LIB_STATS_LABELS)
