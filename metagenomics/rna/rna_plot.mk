
# matrix
plot_rna_mat:
	$(_R) $(_md)/R/rna_plot.r plot.mat \
		ifn.bins=$(RNA_BINS_TABLE) \
		ifn.genes=$(RNA_BINNED_GENES) \
		ifn.libs=$(RNA_LIB_MAP_TABLE) \
		ifn.libdef=$(RNA_LIB_DEF_TABLE) \
		set1=$(RNA_SET1) \
		set2=$(RNA_SET2) \
		idir=$(RNA_BIN_DIR) \
		fdir=$(RNA_FDIR)/matrix_bins

# scatter
plot_rna_scatter:
	$(_R) $(_md)/R/plot_cmp.r plot.scatter \
		ifn.bins=$(RNA_BINS_TABLE) \
		ifn.cmp=$(RNA_COMPARE_TABLE) \
		set1=$(RNA_SET1) \
		set2=$(RNA_SET2) \
		fdir=$(RNA_FDIR)/compare/$(RNA_SET_LABEL)/scatter

plot_rna: plot_rna_mat plot_rna_scatter
