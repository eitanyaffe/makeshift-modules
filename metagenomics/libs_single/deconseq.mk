
HUMAN_SUFFIX='*clean*'
DECONSEQ_DONE=$(LIB_DIR)/.done_deconseq
$(DECONSEQ_DONE): $(SPLIT_DONE)
	$(call _start,$(DECONSEQ_DIR))
	@echo "================================================================================"
	@echo "Removing human sequences (DeconSeq)"
	@echo "================================================================================"
	$(call _time,$(DECONSEQ_DIR),no_human) \
		$(_R) $(_md)/R/distrib_remove_human.r distrib.remove.human \
		deconseq=$(DECONSEQ_SCRIPT) \
		dbs=$(DECONSEQ_DBS) \
		wdir=$(DECONSEQ_BIN_DIR) \
		identity=$(DECONSEQ_IDENTITY) \
		coverage=$(DECONSEQ_COVERAGE) \
		idir=$(DECONSEQ_IDIR) \
		odir=$(DECONSEQ_DIR) \
		qsub.dir=$(DECONSEQ_QSUB_DIR) \
		threads=$(DECONSEQ_THREADS) \
		batch.max.jobs=$(DECONSEQ_MAX_JOBS) \
		total.max.jobs.fn=$(MAX_JOBS_FN) \
		dtype=$(DTYPE) \
		jobname=deconseq
	$(_end_touch)
deconseq_base: $(DECONSEQ_DONE)

$(PP_COUNT_DECONSEQ): $(DECONSEQ_DONE)
	$(_start)
	perl $(_md)/pl/count_fastq_single.pl $(DECONSEQ_DIR) '*' '*clean.fq' deconseq $@
	$(_end)
deconseq: $(PP_COUNT_DECONSEQ)

FINAL_DONE=$(LIB_DIR)/.done_final
$(FINAL_DONE): $(PP_COUNT_DECONSEQ)
	$(call _start,$(FINAL_LIB_DIR))
	cat $(DECONSEQ_DIR)/$(DECONSEQ_PATTERN) > $(PAIRED_R1)
	touch $(PAIRED_R2)
	$(_end_touch)
final: $(FINAL_DONE)

libs_single: trimmomatic dups split deconseq final
