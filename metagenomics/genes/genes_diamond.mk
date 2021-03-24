DIAMOND_INDEX?=$(BLAST_TARGET_FASTA).diamond_index
BLAST_RESULT_RAW?=$(BLAST_DIR)/blast.result.raw
BLAST_RESULT_SAM?=$(BLAST_DIR)/blast.result.sam

BLAST_INDEX_DONE?=$(DIAMOND_INDEX).done
$(BLAST_INDEX_DONE):
	$(_start)
	$(DIAMOND_BIN) makedb \
		-c $(DIAMOND_INDEX_CHUNKS) \
		--in $(BLAST_TARGET_FASTA) \
		-p $(DIAMOND_THREADS) \
		-d $(DIAMOND_INDEX)
	$(_end_touch)
genes_diamond_index: $(BLAST_INDEX_DONE)

BLAST_DONE?=$(BLAST_DIR)/.done_raw
$(BLAST_DONE): $(BLAST_INDEX_DONE)
	$(call _start,$(BLAST_DIR))
	$(call _time,$(BLAST_DIR),blast) $(DIAMOND_BIN) $(DIAMOND_COMMAND) \
		-b $(DIAMOND_BLOCK_SIZE) \
		-c $(DIAMOND_INDEX_CHUNKS) \
		-d $(DIAMOND_INDEX) \
		-p $(DIAMOND_THREADS) \
		-q $(BLAST_QUERY) \
		-e $(DIAMOND_EVALUE) \
		$(DIAMOND_BLAST_PARAMS) \
		-a $(BLAST_RESULT_RAW)
	$(_end_touch)

BLAST_SAM_DONE?=$(BLAST_DIR)/.done_sam
$(BLAST_SAM_DONE): $(BLAST_DONE)
	$(_start)
	$(call _time,$(BLAST_DIR),view) $(DIAMOND_BIN) view \
		-a $(BLAST_RESULT_RAW) \
		-o $(BLAST_RESULT_SAM)
	$(_end_touch)

BLAST_PARSE_DONE?=$(BLAST_DIR)/.done_parse
$(BLAST_PARSE_DONE): $(BLAST_SAM_DONE)
	$(_start)
	$(call _time,$(BLAST_DIR),parse_sam) perl $(_md)/pl/sam_parse.pl \
		$(BLAST_RESULT_SAM) \
		$(BLAST_QUERY_TABLE) \
		$(BLAST_TARGET_TABLE) \
		aa \
		$(BLAST_RESULT)
	$(_end_touch)
genes_diamond_blast: $(BLAST_PARSE_DONE)

# clean raw diamond result
BLAST_CLEAN_RAW_DONE?=$(BLAST_DIR)/.done_clean_diamond_raw
$(BLAST_CLEAN_RAW_DONE): $(BLAST_SAM_DONE)
	$(_start)
	rm -rf $(BLAST_RESULT_RAW).daa
	$(_end_touch)
genes_diamond_clean: $(BLAST_CLEAN_RAW_DONE)

# no query table for reads: generate sam and remove diamond raw file 
reads_diamond_blast: $(BLAST_CLEAN_RAW_DONE)
