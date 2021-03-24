nlv_plot_combo:
	$(_R) R/nlv_plot_bins.r plot.combo \
		ifn.libs=$(NLV_SET_DEFS) \
		ifn.bins=$(NLV_INPUT_BIN_TABLE) \
		ifn.sets=$(NLV_BIN_SET_SUMMARY) \
		ifn.set.pairs=$(NLV_BIN_SET_PAIR_SUMMARY) \
		ifn.dist.mat=$(NLV_DISTANCE_MATRIX) \
		ifn.count.mat=$(NLV_TRJ_MAT_COUNT_BINS) \
		ifn.total.mat=$(NLV_TRJ_MAT_TOTAL_BINS) \
		fdir=$(NLV_FDIR)/bins_combo

nlv_plot_mat:
	$(_R) R/nlv_plot_bins.r plot.mat \
		ifn.libs=$(NLV_SET_DEFS) \
		ifn.bins=$(NLV_INPUT_BIN_TABLE) \
		ifn.count.mat=$(NLV_TRJ_MAT_COUNT_BINS) \
		ifn.total.mat=$(NLV_TRJ_MAT_TOTAL_BINS) \
		fdir=$(NLV_FDIR)/bins_mat

nlv_plot_freq_div:
	$(_R) R/nlv_plot_freq.r plot.freq \
		ifn.libs=$(NLV_SET_DEFS) \
		ifn.bins=$(NLV_INPUT_BIN_TABLE) \
		ifn.sites=$(NLV_FREQ_DIVERGE_INPUT) \
		ifn.sets=$(NLV_BIN_SET_SUMMARY) \
		ifn.count.mat=$(NLV_TRJ_MAT_COUNT_BINS) \
		ifn.total.mat=$(NLV_TRJ_MAT_TOTAL_BINS) \
		fdir=$(NLV_FDIR)/bins_freq_diverge

nlv_plot_freq_seg:
	$(_R) R/nlv_plot_freq.r plot.freq \
		ifn.libs=$(NLV_SET_DEFS) \
		ifn.bins=$(NLV_INPUT_BIN_TABLE) \
		ifn.sites=$(NLV_FREQ_SEGREGATE_INPUT) \
		ifn.sets=$(NLV_BIN_SET_SUMMARY) \
		ifn.count.mat=$(NLV_TRJ_MAT_COUNT_BINS) \
		ifn.total.mat=$(NLV_TRJ_MAT_TOTAL_BINS) \
		fdir=$(NLV_FDIR)/bins_freq_seg

nlv_plot_strains:
	$(_R) R/nlv_plot_strains.r plot.strains \
		ifn.libs=$(NLV_SET_DEFS) \
		ifn.bin.coverage=$(NLV_BIN_SET_SUMMARY) \
		ifn.bins=$(STRAIN_BIN_TABLE) \
		ifn.strains.template=$(STRAIN_RESULT_TABLE) \
		ifn.taxa=$(SET_TAXA_REPS) \
		ifn.bin.order=$(TRJ_BIN_ORDER) \
		bin.template=$(STRAIN_BIN) \
		type=$(NLV_LIB_INPUT_TYPE) \
		maxSNPs=$(STRAIN_BIN_MAX_SNPS) \
		maxN=$(STRAIN_FINDER_N_MAX) \
		fdir=$(NLV_FDIR)/strains_N$(STRAIN_FINDER_N_MAX)_$(STRAIN_CRITERIA)

nlv_plot_strain_tnse:
	$(_R) $(_md)/R/nlv_plot_tsne.r plot.strain.tsne \
		ifn.sites=$(NLV_TSNE_SITES) \
		ifn.bins=$(NLV_TSNE_BINS) \
		bin.template=$(STRAIN_BIN) \
		ifn.class.template=$(STRAIN_RESULT_CLASS) \
		fdir=$(NLV_FDIR)/strain_tsne

nlv_plot: nlv_plot_combo
