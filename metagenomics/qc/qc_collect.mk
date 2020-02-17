
QC_COLLECT_COUNTS_DONE=$(QC_SUMMARY_DIR)/.done_collect
$(QC_COLLECT_COUNTS_DONE):
	$(call _start,$(QC_SUMMARY_DIR))
	$(_Rcall) $(CURDIR) $(_md)/R/qc_libs.r collect.counts \
		ifn=$(QC_IN_SAMPLE_TABLE) \
		idir=$(BASE_OUTPUT_DIR) \
		fields=$(QC_COUNT_FIELDS) \
		ofn=$(QC_COUNT_SUMMARY)
	$(_end_touch)
qc_collect_counts: $(QC_COLLECT_COUNTS_DONE)

QC_YIELDS_DONE=$(QC_SUMMARY_DIR)/.done_yields
$(QC_YIELDS_DONE): $(QC_COLLECT_COUNTS_DONE)
	$(_start)
	$(_Rcall) $(CURDIR) $(_md)/R/qc_libs.r yields \
		ifn=$(QC_COUNT_SUMMARY) \
		fields=$(QC_COUNT_FIELDS) \
		ofn=$(QC_YIELD_SUMMARY)
	$(_end_touch)
qc_yields: $(QC_YIELDS_DONE)

