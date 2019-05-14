plot_timeline:
	$(_R) R/plot_timeline.r plot.timeline \
		ids=$(CR_DATASETS) \
		disturb.days=$(CR_DISTURB_DAYS) \
		labels=$(CR_LABELS) \
		days=$(CR_DAYS) \
		zoom.days=$(CR_ZOOM_DAYS) \
		fdir=$(CR_FDIR)/1_timeline

plot_sample_matrix:
	$(_R) R/sample_matrix_plot.r plot.sample.matrix \
		ifn.bins=$(CR_BINS) \
		ifn.order=$(ANCHOR_CLUSTER_TABLE) \
		ifn.response=$(CR_NORM) \
		ifn.median=$(CR_PATTERN_MEDIAN) \
		disturb.ids=$(CR_DISTURB_IDS) \
		labels=$(CR_LABELS) \
		fdir=$(CR_FDIR)/2_sample_matrix

plot_host_response:
	$(_R) R/plot_host_response.r plot.host.response \
		ifn.order=$(ANCHOR_CLUSTER_TABLE) \
		ifn.median=$(CR_PATTERN_MEDIAN) \
		ifn.top95=$(CR_PATTERN_TOP95) \
		ifn.top75=$(CR_PATTERN_TOP75) \
		ifn.bottom05=$(CR_PATTERN_BOTTOM05) \
		ifn.bottom25=$(CR_PATTERN_BOTTOM25) \
		ifn.taxa=$(SET_TAXA_REPS) \
		ifn.taxa.legend=$(SET_TAX_LEGEND) \
		ifn.detection=$(CR_NORM_DETECTION) \
		base.ids=$(CR_BASE_IDS) \
		disturb.ids=$(CR_DISTURB_IDS) \
		labels=$(CR_LABELS) \
		fdir=$(CR_FDIR)/3_host_response

plot_response_genus:
	$(_R) R/plot_genus_response.r plot.genus.response \
		ifn.rep=$(SET_TAXA_REPS) \
		ifn.median=$(CR_PATTERN_MEDIAN) \
		ifn.taxa.legend=$(SET_TAX_LEGEND) \
		ifn.detection=$(CR_NORM_DETECTION) \
		labels=$(CR_LABELS) \
		ifn.taxa=$(SET_TAXA_TABLE) \
		disturb.ids=$(CR_DISTURB_IDS) \
		fdir=$(CR_FDIR)/4_genus_response

plot_host_element_response:
	$(_R) R/plot_single_host.r plot.single.host.element.detailed \
		ifn.anchors=$(ANCHOR_CLUSTER_TABLE) \
		ifn.element2anchor=$(CR_IN_SC_ELEMENT_ANCHOR) \
		ifn.norm=$(CR_PATTERN_MEDIAN) \
		ifn.detection=$(CR_NORM_DETECTION) \
		base.min.correlation=$(CR_MIN_BASE_CORRELATION) \
		base.ids=$(CR_BASE_IDS) \
		disturb.ids=$(CR_DISTURB_IDS) \
		labels=$(CR_LABELS) \
		fdir=$(CR_FDIR)/5_single_host

plot_element_summary:
	$(_R) R/plot_element_summary.r plot.element.summary \
		ifn.reps=$(SET_TAXA_REPS) \
		ifn.anchors=$(ANCHOR_CLUSTER_TABLE) \
		ifn.element2anchor=$(CR_IN_SC_ELEMENT_ANCHOR) \
		ifn.obs=$(CR_PATTERN_OBS) \
		ifn.exp=$(CR_PATTERN_EXP) \
		ifn.detection=$(CR_NORM_DETECTION) \
		labels=$(CR_LABELS) \
		fdir=$(CR_FDIR)/6_element_summary

plot_shared_element_response:
	$(_R) R/cr_plot_element_response.r plot.shared.elements \
		ifn.sets=$(CR_SETS) \
		ifn.element2anchor=$(CR_IN_SC_ELEMENT_ANCHOR) \
		ifn.reps=$(SET_TAXA_REPS) \
		ifn.anchors=$(ANCHOR_CLUSTER_TABLE) \
		ifn.map=$(CR_ANCHOR_MATRIX) \
		ifn.bottom0=$(CR_PATTERN_BOTTOM0) \
		ifn.median=$(CR_PATTERN_MEDIAN) \
		ifn.top100=$(CR_PATTERN_TOP100) \
		ifn.detection=$(CR_NORM_DETECTION) \
		disturb.ids=$(CR_DISTURB_IDS) \
		labels=$(CR_LABELS) \
		fdir=$(CR_FDIR)/libs/$(CR_LIB_ID)/1_shared_element_response

cr_plots_basic: \
plot_timeline \
plot_sample_matrix \
plot_host_response plot_response_genus \
plot_host_element_response \
plot_element_summary

cr_plots: cr_plots_basic
