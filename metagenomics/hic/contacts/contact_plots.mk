cnt_plot_host_compare:
	$(_R) R/cnt_plot_host_matrix.r plot.matrix.compare \
		ifn.bins=$(CNT_BINS_IN) \
		ifn.bins.sites=$(CNT_BINS_SITES_IN) \
		ifn.map=$(CNT_MAP_COMPARE) \
		min.contacts=$(CNT_MIN_CONTACTS) \
		legend1=$(CNT_LEGEND1) \
		legend2=$(CNT_LEGEND2) \
		fdir=$(CNT_FDIR)/map_compare/$(CNT_HIC_COMPARE_LABEL)

make_contact_plots: cnt_plot_host_compare
