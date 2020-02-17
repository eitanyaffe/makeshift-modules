nlv_plot_mat:
	$(_R) R/nlv_plot_bins.r plot.bin.mat \
		ifn.libs=$(NLV_SET_DEFS) \
		ifn.bins=$(NLV_INPUT_BIN_TABLE) \
		ifn.sets=$(NLV_BIN_SET_SUMMARY) \
		ifn.set.pairs=$(NLV_BIN_SET_PAIR_SUMMARY) \
		ifn.count.mat=$(NLV_TRJ_DIVERGE_MAT_COUNT) \
		ifn.total.mat=$(NLV_TRJ_DIVERGE_MAT_TOTAL) \
		fdir=$(NLV_FDIR)/bins_mat

nlv_plot_freq:
	$(_R) R/nlv_plot_freq.r plot.freq \
		ifn.libs=$(NLV_SET_DEFS) \
		ifn.bins=$(NLV_INPUT_BIN_TABLE) \
		ifn.sets=$(NLV_BIN_SET_SUMMARY) \
		ifn.count.mat=$(NLV_TRJ_DIVERGE_MAT_COUNT) \
		ifn.total.mat=$(NLV_TRJ_DIVERGE_MAT_TOTAL) \
		fdir=$(NLV_FDIR)/bins_freq

nlv_plot: nlv_plot_mat nlv_plot_freq
