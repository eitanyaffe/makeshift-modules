# merge into a single pair R1/R2
MERGE_DONE?=$(LIB_MERGE_DIR)/.done_merge
$(MERGE_DONE):
	$(call _start,$(LIB_MERGE_DIR))
	$(call _time,$(LIB_MERGE_DIR),merge_fastq) $(_R) R/merge.r merge.fastq \
		ifn=$(CHUNK_TABLE) \
		idir=$(CHUNKS_DIR) \
		ofn1=$(MERGED_R1) \
		ofn2=$(MERGED_R2)
	$(_end_touch)
lib_merge_base: $(MERGE_DONE)

$(COUNT_MERGE): $(MERGE_DONE)
	$(_start)
	perl $(_md)/pl/count_fastq_fn.pl $(MERGED_R1) $(MERGED_R2) final $@
	$(_end)
lib_merge: $(COUNT_MERGE)
