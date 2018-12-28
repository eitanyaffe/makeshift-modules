ifeq ($(MAP_IS_PAIRED),T)
SPLIT_SCRIPT?=$(_md)/pl/split_fastq.pl
else
SPLIT_SCRIPT?=$(_md)/pl/split_fastq_single.pl
endif

# split input fastq files
ifeq ($(MAP_PURGE_SPLIT),T)
SPLIT_DONE=$(MAP_DIR)/.done_split
else
SPLIT_DONE=$(SPLIT_DIR)/.done_split
endif
$(SPLIT_DONE):
	@rm -rf $(SPLIT_DIR)
	$(call _start,$(SPLIT_DIR) $(MAP_DIR))
	@echo '##' Catalog: $(CATALOG_ID)
	@echo '##' Mapping library: $(LIB_ID)
	$(call _assert,LIB_ID MAP_INPUT)
	$(call _time,$(MAP_DIR),split) \
		$(SPLIT_SCRIPT) \
			$(SPLIT_DIR) \
			$(MAP_SPLIT_READS_PER_FILE) \
			$(MAP_SPLIT_TRIM) \
			$(MAP_SPLIT_READ_OFFSET1) \
			$(MAP_READ_LENGTH1) \
			$(MAP_SPLIT_READ_OFFSET2) \
			$(MAP_READ_LENGTH2) \
			$(MAP_MAX_READS) \
			$(MAP_INPUT_STAT) \
			$(MAP_INPUT)
	$(_end_touch)
split: $(SPLIT_DONE)

# filter reads
FILTER_QSUB_DIR?=$(QSUB_LIB_DIR)/map_filter
FILTER_DONE?=$(MAP_DIR)/.done_filter_$(FILTER_ID)
FILTER_SCRIPT?=$(_md)/pl/filter_map.pl
$(FILTER_DONE): $(VERIFY_PARSE_DONE)
	$(call _start,$(FILTER_DIR))
	mkdir -p $(FILTER_STAT_DIR)
	$(call _time,$(MAP_DIR),filter) $(_R) $(_md)/R/distrib_map.r distrib.filter \
		script=$(FILTER_SCRIPT) \
		idir=$(PARSE_DIR) \
		odir=$(FILTER_DIR) \
		sdir=$(FILTER_STAT_DIR) \
		sfile=$(FILTER_STAT_FILE) \
		min.score=$(MAP_MIN_QUALITY_SCORE) \
		min.length=$(MAP_MIN_LENGTH) \
		min.distance=$(MAP_MIN_EDIT_DISTANCE) \
		qsub.dir=$(FILTER_QSUB_DIR) \
		batch.max.jobs=$(NUM_MAP_JOBS) \
		total.max.jobs.fn=$(MAX_JOBS_FN) \
		dtype=$(DTYPE) \
		jobname=mfilter
	$(_end_touch)
filter: $(FILTER_DONE)

map: $(FILTER_DONE)

# remove split/mapped/parsed directories yet keep .done files
CLEAN_DONE?=$(MAP_DIR)/.done_clean
$(CLEAN_DONE):
	$(_start)
ifeq ($(MAP_PURGE_SPLIT),T)
	rm -rf $(SPLIT_DIR)
endif
	rm -rf $(MAPPED_DIR) $(PARSE_DIR)
	$(_end_touch)
map_clean: $(CLEAN_DONE)

