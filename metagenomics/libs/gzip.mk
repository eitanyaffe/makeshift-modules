LIB_INPUT_DONE?=$(LIB_INPUT_DIR)/.done_gunzip
$(LIB_INPUT_DONE):
	$(call _start,$(LIB_INPUT_DIR))
	$(foreach X,$(LIB_INPUT_R1_GZ),\
		cp $X $(LIB_INPUT_DIR)/R1.fastq.gz && \
		pigz -c -d -p $(PIGZ_THREADS) $(LIB_INPUT_DIR)/R1.fastq.gz \
			>> $(LIB_INPUT_DIR)/merged_R1.fastq && rm $(LIB_INPUT_DIR)/R1.fastq.gz; $(ASSERT); )
	$(foreach X,$(LIB_INPUT_R2_GZ),\
		cp $X $(LIB_INPUT_DIR)/R2.fastq.gz && \
		pigz -c -d -p $(PIGZ_THREADS) $(LIB_INPUT_DIR)/R2.fastq.gz \
			>> $(LIB_INPUT_DIR)/merged_R2.fastq && rm $(LIB_INPUT_DIR)/R2.fastq.gz; $(ASSERT); )
	perl $(_md)/pl/subsample_pair.pl \
		$(LIBS_FASTQ_READ_COUNT) \
		$(LIBS_SUBSAMPLE_SEED) \
		 $(LIB_INPUT_DIR)/merged_R1.fastq \
		 $(LIB_INPUT_DIR)/merged_R2.fastq \
		$(LIBS_INPUT_R1) \
		$(LIBS_INPUT_R2) \
		$(LIBS_SUBSAMPLE_STATS)
	rm $(LIB_INPUT_DIR)/merged_R1.fastq $(LIB_INPUT_DIR)/merged_R2.fastq
	$(_end_touch)
lib_extract_base: $(LIB_INPUT_DONE)

$(COUNT_INPUT): $(LIB_INPUT_DONE)
	$(_start)
	perl $(_md)/pl/count_fastq_fn.pl $(LIBS_INPUT_R1) $(LIBS_INPUT_R2) input $@
	$(_end)
lib_extract: $(COUNT_INPUT)

COMPRESS_DONE?=$(LIB_OUT_DIR)/.done_gzip
$(COMPRESS_DONE):
	$(call _start,$(LIB_OUT_DIR))
	$(call _time,$(LIB_OUT_DIR),gzip_R1) pigz -p $(PIGZ_THREADS) -c $(MERGED_R1) > $(FINAL_R1)
	$(call _time,$(LIB_OUT_DIR),gzip_R2) pigz -p $(PIGZ_THREADS) -c $(MERGED_R2) > $(FINAL_R2)
	$(_end_touch)
lib_compress: $(COMPRESS_DONE)
