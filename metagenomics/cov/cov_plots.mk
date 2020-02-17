cov_plot_contig:
	$(_R) R/cov_plot_contig.r plot.contig \
		prefix=$(COV_CONTIG_PREFIX) \
		contig=$(COV_CONTIG) \
		fdir=$(COV_FDIR)/$(COV_WEIGHT_STYLE)/contig/$(COV_CONTIG_LABEL)

cov_plot_summary:
	$(_R) R/cov_plot_summary.r plot.summary \
		ifn.contigs=$(COV_CONTIG_TABLE) \
		ifn.segments=$(COV_SEGMENT_TABLE) \
		fdir=$(COV_FDIR)/$(COV_WEIGHT_STYLE)/summary

cov_plot: cov_plot_contig
