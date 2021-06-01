# create single index file
MERGE_BAM_DONE?=$(MAP_OUT_DIR)/.done_merge_bams
$(MERGE_BAM_DONE):
	$(call _start,$(MAP_OUT_DIR))
	$(_R) R/map_merge.r merge.bam \
		ifn=$(MAP_CHUNK_TABLE) \
		threads=$(MAP_SAMTOOLS_MERGE_THREADS) \
		idir=$(MAP_CHUNKS_DIR) \
		ofn=$(MAP_BAM_FILE)
	$(_end_touch)
map_bam_merge: $(MERGE_BAM_DONE)

MERGE_CHUNKS_DONE?=$(MAP_OUT_DIR)/.done_merge_chunks
$(MERGE_CHUNKS_DONE):
	$(call _start,$(MAP_OUT_DIR))
	$(_R) R/map_merge.r merge.pairs \
		ifn=$(MAP_CHUNK_TABLE) \
		idir=$(MAP_CHUNKS_DIR) \
		ofn=$(MAP_PAIRED)
	$(_R) R/map_merge.r merge.sides \
		ifn=$(MAP_CHUNK_TABLE) \
		idir=$(MAP_CHUNKS_DIR) \
		ofn1=$(MAP_R1) \
		ofn2=$(MAP_R2)
	$(_end_touch)
map_pair_merge: $(MERGE_CHUNKS_DONE)

map_merge: $(MERGE_BAM_DONE) $(MERGE_CHUNKS_DONE)
