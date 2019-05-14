# not used
plot_poly:
	$(_R) R/plot_poly.r plot.poly \
		ifn.elements=$(EVO_ELEMENT_TABLE) \
		ifn.cores=$(EVO_CORE_TABLE) \
		ifn.taxa=$(SET_TAX_LEGEND) \
		ifn.anchors=$(ANCHOR_CLUSTER_TABLE) \
		min.cov=$(EVO_MIN_COV) \
		min.length=$(EVO_MIN_LENGTH) \
		min.detect=$(EVO_DETECT_FRACTION) \
		fdir=$(EVO_FDIR)/snp_poly

################################################################

plot_snps:
	$(_R) R/evolve_plot.r plot.snp.density \
		ifn.elements=$(EVO_ELEMENT_TABLE) \
		ifn.cores=$(EVO_CORE_TABLE) \
		ifn.taxa=$(SET_TAX_LEGEND) \
		ifn.anchors=$(ANCHOR_CLUSTER_TABLE) \
		min.cov=$(EVO_MIN_COV) \
		min.length=$(EVO_MIN_LENGTH) \
		min.detect=$(EVO_DETECT_FRACTION) \
		fdir=$(EVO_FDIR)/snp_density

plot_ref_vs_10y:
	$(_R) R/plot_ref_vs_10y.r plot.ref.vs.10y \
		ifn.10y=$(EVO_CORE_FATE_CLASS_10Y) \
		ifn.ref=$(EVO_IN_SC_SUMMARY_UNIQUE) \
		fdir=$(EVO_FDIR)/ref_vs_10y_divergence

plot_host_scatters:
	$(_R) R/scatters.r plot.host.scatters \
		ifn=$(EVO_CORE_TABLE) \
		ifn.taxa=$(SET_TAX_LEGEND) \
		fdir=$(EVO_FDIR)/host_scatters

plot_classify_live:
	$(_R) R/classify.r plot.classify.live.breakdown \
		ifn.cores=$(EVO_CORE_LIVE_CLASS) \
		ifn.elements=$(EVO_ELEMENT_LIVE_CLASS) \
		fdir=$(EVO_FDIR)/classify_live

plot_host_fate_details:
	$(_R) R/plot_host_details.r plot.host.details \
		ifn.cores=$(EVO_CORE_FATE_CLASS) \
		ifn.elements=$(EVO_ELEMENT_FATE_CLASS) \
		ifn.ea=$(EVO_IN_SC_ELEMENT_ANCHOR) \
		fdir=$(EVO_FDIR)/host_details

plot_classify_fate:
	$(_R) R/classify.r plot.classify.fate.breakdown \
		ifn.cores=$(EVO_CORE_FATE_CLASS) \
		ifn.elements=$(EVO_ELEMENT_FATE_CLASS) \
		fdir=$(EVO_FDIR)/classify_fate

plot_element_scatters:
	$(_R) R/scatters.r plot.element.scatters \
		ifn=$(EVO_ELEMENT_LIVE_CLASS) \
		min.length=$(EVO_MIN_LENGTH) \
		fdir=$(EVO_FDIR)/element_scatters

plot_host_fate_summary:
	$(_R) R/fate_summary.r plot.host.fate.summary \
		ifn=$(EVO_CORE_FATE_SUMMARY) \
		ifn.taxa=$(SET_TAX_LEGEND) \
		mut.threshold=$(EVO_FIX_DENSITY_THRESHOLD) \
		fdir=$(EVO_FDIR)/host_fate_summary

plot_host_detect_summary:
	$(_R) R/fate_summary.r plot.host.detect.summary \
		ifn=$(EVO_CORE_DETECT_SUMMARY) \
		fdir=$(EVO_FDIR)/host_detect_summary

plot_element_fate:
	$(_R) R/plot_element_fate.r plot.element.fate \
		ifn.elements=$(EVO_ELEMENT_HOST_FATE) \
		fdir=$(EVO_FDIR)/element_summary

plot_host_complexity:
	$(_R) R/plot_host_complexity.r plot.host.complexity \
		ifn.elements=$(EVO_ELEMENT_LIVE_CLASS) \
		ifn.element2core=$(EVO_IN_SC_ELEMENT_ANCHOR) \
		fdir=$(EVO_FDIR)/host_complexity

plot_coverage:
	$(_R) R/plot_coverage.r plot.coverage \
		ifn.hosts.current=$(EVO_CORE_TABLE_CURRENT) \
		ifn.hosts.10y=$(EVO_CORE_TABLE_10Y) \
		ifn.elements.current=$(EVO_ELEMENT_TABLE_CURRENT) \
		ifn.elements.10y=$(EVO_ELEMENT_TABLE_10Y) \
		fdir=$(EVO_FDIR)/compare_coverage

# compare datasets
plot_halflife:
	$(_R) R/plot_turnover.r plot.halflife \
		ifn.aab=$(AAB_CORE_SUMMARY) \
		ifn.fp=$(FP_CORE_SUMMARY) \
		fdir=$(EVO_BASE_FDIR)/halflife
plot_rate:
	$(_R) R/plot_turnover.r plot.rate \
		ifn.aab=$(AAB_CORE_SUMMARY) \
		ifn.fp=$(FP_CORE_SUMMARY) \
		years=$(EVO_FATE_YEARS) \
		fdir=$(EVO_BASE_FDIR)/rate

###################################################################################################
# aliases
###################################################################################################

plot_evo_poly_basic: plot_host_fate_summary

plot_evo_poly: plot_snps plot_host_scatters plot_classify_live plot_element_scatters plot_classify_fate \
plot_host_fate_summary plot_host_detect_summary \
plot_element_fate plot_host_complexity plot_host_fate_details

plot_evolve:
	@$(MAKE) class_loop class=evo_poly t=plot_evo_poly

plot_evolve_cmp: plot_halflife plot_rate
