BWA_MAIN_DONE?=$(MAP_CHUNK_DIR)/.done_map
$(BWA_MAIN_DONE):
	$(call _start,$(MAP_CHUNK_DIR))
	$(BWA_BIN) mem \
		-t $(MAP_BWA_THREADS) \
		$(MAP_INDEX_PREFIX) \
		$(MAP_CHUNK_INPUT_R1) > \
		$(MAP_CHUNK_SAM_R1)
	$(BWA_BIN) mem \
		-t $(MAP_BWA_THREADS) \
		$(MAP_INDEX_PREFIX) \
		$(MAP_CHUNK_INPUT_R2) > \
		$(MAP_CHUNK_SAM_R2)
	$(_end_touch)
map_main: $(BWA_MAIN_DONE)

BAM_SORT_DONE?=$(MAP_CHUNK_DIR)/.done_sort
$(BAM_SORT_DONE): $(BWA_MAIN_DONE)
	$(_start)
	$(SAMTOOLS_BIN) sort -@$(MAP_SAMTOOLS_SORT_THREADS) -o $(MAP_CHUNK_BAM_R1) $(MAP_CHUNK_SAM_R1)
	$(SAMTOOLS_BIN) sort -@$(MAP_SAMTOOLS_SORT_THREADS) -o $(MAP_CHUNK_BAM_R2) $(MAP_CHUNK_SAM_R2)
	$(_end_touch)
map_sort: $(BAM_SORT_DONE)

SAM_PARSE_DONE?=$(MAP_CHUNK_DIR)/.done_parse
$(SAM_PARSE_DONE): $(BAM_SORT_DONE)
	$(_start)
	perl $(_md)/pl/parse_bwa_sam.pl \
		$(MAP_CHUNK_SAM_R1) \
		$(MAP_CHUNK_PARSE_R1) \
		$(MAP_STATS_R1)
	perl $(_md)/pl/parse_bwa_sam.pl \
		$(MAP_CHUNK_SAM_R2) \
		$(MAP_CHUNK_PARSE_R2) \
		$(MAP_STATS_R2)
	$(_end_touch)
map_parse: $(SAM_PARSE_DONE)

MAP_VERIFY_DONE?=$(MAP_CHUNK_DIR)/.done_verify
$(MAP_VERIFY_DONE): $(SAM_PARSE_DONE)
	$(_start)
	perl $(_md)/pl/verify_parse.pl \
		$(MAP_CHUNK_PARSE_R1) \
		$(MAP_CONTIG_FILE)
	perl $(_md)/pl/verify_parse.pl \
		$(MAP_CHUNK_PARSE_R2) \
		$(MAP_CONTIG_FILE)
	$(_end_touch)
map_verify: $(MAP_VERIFY_DONE)

MAP_FILTER_DONE?=$(MAP_CHUNK_DIR)/.done_filter
$(MAP_FILTER_DONE): $(MAP_VERIFY_DONE)
	$(_start)
	perl $(_md)/pl/filter_map.pl \
		$(MAP_CHUNK_PARSE_R1) \
		$(MAP_MIN_QUALITY_SCORE) \
		$(MAP_MIN_LENGTH) \
		$(MAP_MIN_EDIT_DISTANCE) \
		$(MAP_FILTERED_R1) \
		$(MAP_FILTERED_STATS_R1)
	perl $(_md)/pl/filter_map.pl \
		$(MAP_CHUNK_PARSE_R2) \
		$(MAP_MIN_QUALITY_SCORE) \
		$(MAP_MIN_LENGTH) \
		$(MAP_MIN_EDIT_DISTANCE) \
		$(MAP_FILTERED_R2) \
		$(MAP_FILTERED_STATS_R2)
	$(_end_touch)
map_filter: $(MAP_FILTER_DONE)

MAP_PAIR_DONE?=$(MAP_CHUNK_DIR)/.done_pair
$(MAP_PAIR_DONE): $(MAP_FILTER_DONE)
	$(_start)
	perl $(_md)/pl/pair_reads.pl \
		$(MAP_FILTERED_R1) \
		$(MAP_FILTERED_R2) \
		$(MAP_PAIRED_CHUNK) \
		$(MAP_PAIRED_STATS)
	$(_end_touch)
map_pair: $(MAP_PAIR_DONE)

map_chunk: $(MAP_PAIR_DONE)

####################################################################################
# all chunks
####################################################################################

S_MAP_CHUNKS_DONE?=$(MAP_INFO_DIR)/.done_chunks
$(S_MAP_CHUNKS_DONE):
	$(_start)
	$(MAKE) m=par par_tasks_table \
		PAR_MODULE=map \
		PAR_NAME=map_chunk \
		PAR_TARGET=map_chunk \
		PAR_MACHINE=$(MAP_CHUNK_MACHINE_TYPE) \
		PAR_DISK_TYPE=pd-ssd \
		PAR_DISK_GB=32 \
		PAR_WORK_DIR=$(MAP_INFO_DIR) \
		PAR_TASK_ODIR_VAR=MAP_CHUNK_DIR \
		PAR_TASK_ITEM_VAR=MAP_CHUNK_ID \
		PAR_TASK_ITEM_TABLE=$(MAP_CHUNK_TABLE) \
		PAR_TASK_ITEM_FIELD=chunk \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
map_chunks: $(S_MAP_CHUNKS_DONE)
