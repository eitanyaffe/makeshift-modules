# read count summary
plot_read_stats:
	$(_R) $(_md)/R/qc_plots.r plot.stats \
		ldir=$(METABASE_OUTPUT_DIR)/libs \
		fdir=$(METABASE_FDIR)/lib_stats \
		ids=$(LIB_IDS) \
		titles=$(LIB_LABELS) \
		cols="$(LIB_COLORS)"
