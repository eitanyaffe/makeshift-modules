METABAT_TNSE_DONE?=$(METABAT_TSNE_DIR)/.done_tnse
$(METABAT_TNSE_DONE): $(METABAT_DONE)
	$(call _start,$(METABAT_TSNE_DIR))
	$(_R) $(_md)/R/metaBAT_tsne.r compute.tsne \
		ifn=$(METABAT_DEPTH_TABLE) \
		perplexity=$(METABAT_TSNE_PERLEXITY) \
		nthreads=$(METABAT_TSNE_NTHREADS) \
		norm=$(METABAT_TSNE_NORM) \
		min.length=$(METABAT_TSNE_MIN_CONTIG_LENGTH) \
		max.iter=$(METABAT_TSNE_ITERATIONS) \
		ofn=$(METABAT_TSNE)
	$(_end_touch)
metabat_tsne: $(METABAT_TNSE_DONE)

plot_tsne:
	$(_R) R/metabat_plot_tsne.r plot.tsne \
		ifn=$(METABAT_TSNE) \
		ifn.cb=$(METABAT_TABLE) \
		ifn.bins=$(METABAT_BIN_CLASS) \
		percent=$(METABAT_TSNE_PLOT_TRANSPARENT_PERCENT) \
		fdir=$(METABAT_FDIR)/tsne/$(METABAT_TSNE_TAG)/base

plot_tsne_density:
	$(_R) R/metabat_plot_tsne.r plot.tsne.density \
		ifn=$(METABAT_TSNE) \
		nbins=$(METABAT_TSNE_PLOT_NBINS) \
		fdir=$(METABAT_FDIR)/tsne/$(METABAT_TSNE_TAG)/density
