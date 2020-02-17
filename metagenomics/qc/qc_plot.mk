plot_qc_yields:
	$(_R) R/plot_qc.r plot.qc.yields \
		ifn=$(QC_COUNT_SUMMARY) \
		fields=$(QC_COUNT_FIELDS) \
		fdir=$(QC_SUMMARY_FDIR)/yields
