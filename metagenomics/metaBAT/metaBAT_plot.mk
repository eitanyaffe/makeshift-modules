mb_plot_scores:
	$(_R) $(_md)/R/mb_plot.r plot.scores \
		ifn.bins=$(METABAT_BIN_TABLE) \
		ifn.score=$(METABAT_CONTIG_SCORE) \
		min.score=$(METABAT_MIN_SCORE) \
		min.zscore=$(METABAT_MIN_ZSCORE) \
		fdir=$(METABAT_FDIR)/post_metabat_contig_scores

mb_plot_checkm:
	$(_R) R/bins_checkm_plot.r plot.basic \
		ifn=$(METABAT_CHECKM_RESULT) \
		min.complete=$(METABAT_MIN_GENOME_COMPLETE) \
		max.contam=$(METABAT_MAX_GENOME_CONTAM) \
		subject.id=$(SUBJECT_ID) \
		fdir=$(METABAT_FDIR)/checkm

plot_metabat: mb_plot_checkm mb_plot_scores
