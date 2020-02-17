mb_plot_scores:
	$(_R) $(_md)/R/mb_plot.r plot.scores \
		ifn.bins=$(METABAT_BIN_TABLE) \
		ifn.score=$(METABAT_CONTIG_SCORE) \
		min.score=$(METABAT_MIN_SCORE) \
		min.zscore=$(METABAT_MIN_ZSCORE) \
		fdir=$(METABAT_FDIR)/contig_scores

plot_metabat: mb_plot_scores
