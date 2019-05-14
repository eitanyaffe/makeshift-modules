# element scatter pre/post over hosts
# select persistent/replaced hosts and elements
cr_plot_host_compare:
	$(_R) R/plot_matrix_compare.r plot.matrix.compare.anchor.details \
		ifn.anchors=$(CR_ANCHORS_SELECTED) \
		ifn.sets=$(CR_SETS) \
		ifn.set.stats=$(CR_SET_DIST) \
		min.element.genes=10 \
		max.element.sd=0.1 \
		ifn.map=$(CR_MAP_COMPARE) \
		min.contacts=$(CR_NETWORK_MIN_CONTACTS) \
		legend1=$(CR_LEGEND1) \
		legend2=$(CR_LEGEND2) \
		fdir=$(CR_FDIR)/map_compare/$(CR_HIC_COMPARE_LABEL)/anchor_details
