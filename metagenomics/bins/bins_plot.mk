plot_bins_checkm:
	$(_R) R/bins_checkm_plot.r plot.basic \
		ifn=$(BINS_CHECKM_RESULT) \
		min.complete=$(BINS_MIN_GENOME_COMPLETE) \
		max.contam=$(BINS_MAX_GENOME_CONTAM) \
		subject.id=$(SUBJECT_ID) \
		fdir=$(BINS_FDIR)/checkm

plot_bins_fragments:
	$(_R) R/bins_fragment_plot.r plot.fragments \
		ifn=$(BINS_SEGMENT_TABLE) \
		fdir=$(BINS_FDIR)/fragments

plot_bins: plot_bins_checkm plot_bins_fragments
	@$(MAKE) m=metaBAT plot_metabat
