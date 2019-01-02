contig_midas_plot:
	$(_R) R/midas_plot.r midas.plot \
		ifn.matrix=$(CONTIG_MATRIX_FILTERED) \
		ifn.midas=XXX
