INDEX_PREFIX?=$(INDEX_DIR)/idx
INDEX_DONE?=$(INDEX_DIR)/.done
$(INDEX_DONE):
	$(call _assert,MAP_SEQ_FILE)
	$(call _start,$(INDEX_DIR))
	$(BWA_BIN) index \
		-p $(INDEX_PREFIX) \
		$(MAP_SEQ_FILE)
	$(_end_touch)
map_index: $(INDEX_DONE)

MAP_DONE?=$(MAP_DIR)/.done_map_bwa
$(MAP_DONE): $(INDEX_DONE) $(SPLIT_DONE)
	$(call _start,$(MAPPED_DIR))
	$(if $(or $(_dry),$(wildcard $(SPLIT_DIR)/*)),,$(error no files found in $(SPLIT_DIR)))
	$(foreach IFN, $(wildcard $(SPLIT_DIR)/*$(MAP_INPUT_SUFFIX)), $(BWA_BIN) mem \
		-t $(MAP_BWA_THREADS) \
		$(INDEX_PREFIX) \
		$(IFN) > \
		$(MAPPED_DIR)/$(notdir $(IFN)); $(ASSERT); )
	$(_end_touch)
map_bwa: $(MAP_DONE)

MAP_BAM_DONE?=$(MAP_DIR)/.done_bam
$(MAP_BAM_DONE): $(MAP_DONE)
	$(call _start,$(MAP_BAM_DIR))
	$(foreach IFN, $(wildcard $(MAPPED_DIR)/*$(MAP_INPUT_SUFFIX)), \
		$(SAMTOOLS_BIN) sort -@$(MAP_SAMTOOLS_THREADS) -o $(MAP_BAM_DIR)/$(notdir $(IFN)) $(IFN); $(ASSERT); )
	$(_end_touch)
map_bam_single: $(MAP_BAM_DONE)

MAP_BAM_MERGE_DONE?=$(MAP_DIR)/.done_bam_merge
$(MAP_BAM_MERGE_DONE): $(MAP_BAM_DONE)
	$(call _start,$(MAP_LIB_DIR))
	samtools merge -@$(MAP_SAMTOOLS_THREADS) -f $(MAP_BAM_FILE) $(wildcard $(MAP_BAM_DIR)/*$(MAP_INPUT_SUFFIX))
	$(_end_touch)
map_bam: $(MAP_BAM_MERGE_DONE)

PARSE_QSUB_DIR?=$(MAP_TMPDIR)/map_parse

# parse the bwa/sam output
PARSE_SCRIPT?=$(_md)/pl/parse_bwa_sam.pl
PARSE_DONE?=$(MAP_DIR)/.done_parse
$(PARSE_DONE): $(MAP_DONE)
	$(call _start,$(PARSE_DIR))
	mkdir -p $(PARSE_STAT_DIR)
	$(call _time,$(PARSE_DIR)) \
		$(_R) $(_md)/R/distrib_parse_bwa.r distrib.parse.bwa \
		script=$(PARSE_SCRIPT) \
		idir=$(MAPPED_DIR) \
		odir=$(PARSE_DIR) \
		sdir=$(PARSE_STAT_DIR) \
		sfile=$(PARSE_STAT_FILE) \
		qsub.dir=$(PARSE_QSUB_DIR) \
		batch.max.jobs=$(NUM_MAP_JOBS) \
		total.max.jobs.fn=$(MAX_JOBS_FN) \
		dtype=$(DTYPE) \
		jobname=mparse
	$(_end_touch)
map_parse: $(PARSE_DONE)

# verify parse using ref genome
SHOULD_VERIFY?=F
VERIFY_SCRIPT?=$(_md)/pl/verify_parse.pl
VERIFY_PARSE_DONE?=$(MAP_DIR)/.done_verify
$(VERIFY_PARSE_DONE): $(PARSE_DONE)
	$(_start)
ifeq ($(SHOULD_VERIFY),T)
	$(call _time,$(PARSE_DIR),verify) \
		$(_R) $(_md)/R/distrib_parse_bwa.r distrib.verify.parse \
		script=$(VERIFY_SCRIPT) \
		ref=$(FULL_CONTIG_FILE) \
		idir=$(PARSE_DIR) \
		qsub.dir=$(PARSE_QSUB_DIR) \
		batch.max.jobs=$(NUM_MAP_JOBS) \
		total.max.jobs.fn=$(MAX_JOBS_FN) \
		dtype=$(DTYPE) \
		jobname=mverify
endif
	$(_end_touch)
map_verify: $(VERIFY_PARSE_DONE)

