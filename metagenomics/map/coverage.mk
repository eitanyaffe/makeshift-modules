# note we don't need map pairs here
COVERAGE_DONE?=$(MAP_DIR)/.done_map_coverage
$(COVERAGE_DONE): $(FILTER_DONE)
	$(_start)
	$(call _time,$(MAP_DIR),coverage) \
		$(_md)/pl/coverage_summary.pl \
		$(CONTIG_TABLE) \
		$(CONTIG_FIELD) \
		$(FILTER_DIR) \
		$(MAP_BINSIZE) \
		$(COVERAGE_TABLE)
	$(_end_touch)
coverage: $(COVERAGE_DONE)
