plot_bin_trj:
	$(_R) R/trj_plot_host_response.r plot.bin.patterns \
		ifn.order=$(TRJ_BIN_ORDER) \
		ifn.median=$(TRJ_PATTERN_MEDIAN) \
		ifn.top95=$(TRJ_PATTERN_TOP95) \
		ifn.top75=$(TRJ_PATTERN_TOP75) \
		ifn.bottom05=$(TRJ_PATTERN_BOTTOM05) \
		ifn.bottom25=$(TRJ_PATTERN_BOTTOM25) \
		ifn.detection=$(TRJ_CONTIG_NORM_DETECTION) \
		ifn.selected.bins=$(TRJ_SELECTED_BIN_TABLE) \
		select.bins=$(TRJ_SELECTED_BINS) \
		base.ids=$(TRJ_BASE_IDS) \
		disturb.ids=$(TRJ_MID_IDS) \
		lib.ids=$(TRJ_IDS) \
		sample.defs.ifn=$(TRJ_SAMPLE_DEFS) \
		annotate.libs=$(TRJ_ANNOTATE) \
		subject.id=$(SUBJECT_ID) \
		fdir=$(TRJ_FDIR)/host_response

# show contigs per bin
plot_bin_trj_contigs:
	$(_R) R/trj_plot_host_detailed.r plot.bin.details \
		ifn.order=$(TRJ_BIN_ORDER) \
		ifn.median=$(TRJ_CONTIG_NORM) \
		ifn.c2b=$(TRJ_CONTIG_BIN) \
		ifn.detection=$(TRJ_CONTIG_NORM_DETECTION) \
		ifn.sample.defs=$(TRJ_SAMPLE_DEFS) \
		base.ids=$(TRJ_BASE_IDS) \
		disturb.ids=$(TRJ_MID_IDS) \
		lib.ids=$(TRJ_IDS) \
		subject.id=$(SUBJECT_ID) \
		annotate.libs=$(TRJ_ANNOTATE) \
		fdir=$(TRJ_FDIR)/host_response_contigs

plot_trj_all: plot_bin_trj plot_bin_trj_contigs
