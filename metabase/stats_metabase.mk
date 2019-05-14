# read count summary
STATS_DONE?=$(STATS_DIR)/.done
$(STATS_DONE):
	$(call _start,$(STATS_DIR))
	$(_R) $(_md)/R/stats.r merge.stats \
		ldir=$(METABASE_OUTPUT_DIR)/libs \
		ids=$(LIB_IDS) \
		ofn.count=$(STATS_COUNTS) \
		ofn.yield=$(STATS_YIELD)
	$(_end_touch)
stats: $(STATS_DONE)

plot_stats:
	$(_R) $(_md)/R/qc_plots.r plot.stats \
		ldir=$(METABASE_OUTPUT_DIR)/libs \
		fdir=$(METABASE_FDIR)/lib_stats \
		ids=$(LIB_IDS) \
		titles=$(LIB_LABELS) \
		cols="$(LIB_COLORS)"
