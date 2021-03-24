ASSEMBLY_WORK_DIR?=$(MEGAHIT_DIR)/work

MEGAHIT_DONE?=$(MEGAHIT_DIR)/.done_megahit
$(MEGAHIT_DONE):
	$(call _start,$(MEGAHIT_DIR))
	@rm -rf $(ASSEMBLY_WORK_DIR)
	$(MEGAHIT_BIN) $(MEGA_HIT_PARAMS) \
		-m $(MEGAHIT_MEMORY_CAP) \
		-o $(ASSEMBLY_WORK_DIR) \
		--min-contig-len $(MEGAHIT_MIN_CONTIG_LENGTH) \
		--k-min $(MEGAHIT_MIN_KMER) \
		--k-max $(MEGAHIT_MAX_KMER) \
		--k-step $(MEGAHIT_KMER_STEP) \
		$(MEGAHIT_MISC) \
		-t $(NTHREADS) \
		--input-cmd "$(ASSEMBLY_INPUT_CMD)"
	cp $(ASSEMBLY_WORK_DIR)/final.contigs.fa $(FULL_CONTIG_FILE)
	cat $(FULL_CONTIG_FILE) | $(_md)/pl/fasta_summary.pl > $(FULL_CONTIG_TABLE)
	$(_end_touch)
megahit_base: $(MEGAHIT_DONE)

MEGAHIT_SELECT_DONE?=$(MEGAHIT_DIR)/.done_megahit_select
$(MEGAHIT_SELECT_DONE): $(MEGAHIT_DONE)
	$(_start)
	$(_R) $(_md)/R/select_contigs.r top \
	        table=$(FULL_CONTIG_TABLE) \
		ofn=$(ASSEMBLY_CONTIG_TABLE) \
		min.length=$(ASSEMBLY_MIN_LEN)
	$(_md)/pl/select_contigs.pl \
		$(FULL_CONTIG_FILE) \
		$(ASSEMBLY_CONTIG_TABLE) \
		$(ASSEMBLY_CONTIG_FILE)
	$(_end_touch)
megahit: $(MEGAHIT_SELECT_DONE)

MEGAHIT_FASTG_DONE?=$(MEGAHIT_DIR)/.done_megahit_fastg
$(MEGAHIT_FASTG_DONE): $(MEGAHIT_DONE)
	$(_start)
	$(MEGAHIT_BIN)_toolkit contig2fastg \
		$(MEGAHIT_MAX_KMER) \
		$(ASSEMBLY_WORK_DIR)/intermediate_contigs/k$(MEGAHIT_MAX_KMER).contigs.fa \
		> $(MEGAHIT_FASTG)
	$(_end_touch)
megahit_fastg: $(MEGAHIT_FASTG_DONE)
