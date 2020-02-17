###############################################################################################
# create bam using bwa/samtools
###############################################################################################

MB_INDEX_DONE?=$(METABAT_INDEX_DIR)/.done
$(MB_INDEX_DONE):
	$(call _start,$(METABAT_INDEX_DIR))
	$(METABAT_BWA) index \
		-p $(METABAT_INDEX_PREFIX) \
		$(METABAT_IN_CONTIGS)
	$(_end_touch)
mb_index: $(MB_INDEX_DONE)

# trim and unite paired reads to single file
METABAT_INPUT_LIB_DONE?=$(METABAT_LIB_DIR)/.done_input
$(METABAT_INPUT_LIB_DONE):
	$(call _start,$(METABAT_LIB_DIR))
	rm -rf $(METABAT_FASTQ)
	perl $(_md)/pl/trim_fastq.pl $(METABAT_IN_R1) $(METABAT_OFFSET) $(METABAT_LENGTH) $(METABAT_FASTQ)
	perl $(_md)/pl/trim_fastq.pl $(METABAT_IN_R2) $(METABAT_OFFSET) $(METABAT_LENGTH) $(METABAT_FASTQ)
	$(_end_touch)
mb_input_lib: $(METABAT_INPUT_LIB_DONE)

METABAT_BAM_DONE?=$(METABAT_LIB_DIR)/.done
$(METABAT_BAM_DONE): $(METABAT_INPUT_LIB_DONE) $(MB_INDEX_DONE)
	$(_start)
	$(METABAT_BWA) mem \
		-t $(METABAT_IO_THREADS) \
		$(METABAT_INDEX_PREFIX) \
		$(METABAT_FASTQ) \
	| $(METABAT_SAMTOOLS) sort -@$(METABAT_IO_THREADS) -o $(METABAT_LIB_BAM) -
	$(_end_touch)
mb_bam: $(METABAT_BAM_DONE)
