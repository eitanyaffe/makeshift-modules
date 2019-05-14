
HUMAN_SUFFIX='*clean*'
DECONSEQ_DONE=$(DECONSEQ_DIR)/.done
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
deconseq: $(DECONSEQ_DONE)
