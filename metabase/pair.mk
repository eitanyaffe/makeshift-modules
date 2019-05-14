
PAIR_DONE=$(FINAL_LIB_DIR)/.done
$(PAIR_DONE): $(DECONSEQ_DONE)
	$(_start)
	$(_R) $(_md)/R/distrib_pair_fastq.r distrib.pair.fastq \
		pair.script=$(_md)/pl/pair_fastq.pl \
		idir=$(DECONSEQ_DIR) \
		wdir=$(_md) \
		pattern=$(DECONSEQ_PATTERN) \
		odir.pairs=$(PAIRED_BOTH_DIR) \
		odir.R1=$(PAIRED_R1_DIR) \
		odir.R2=$(PAIRED_R2_DIR) \
		qsub.dir=$(PAIRED_QSUB_DIR) \
		batch.max.jobs=$(PAIRED_MAX_JOBS) \
		total.max.jobs.fn=$(MAX_JOBS_FN) \
		dtype=$(DTYPE) \
		jobname=pair
	$(_end_touch)
pairs: $(PAIR_DONE)

PAIR_SINGLE_DONE=$(FINAL_LIB_DIR)/.done_single
$(PAIR_SINGLE_DONE): $(PAIR_DONE)
	$(_start)
	$(_R) $(_md)/R/unite_split_files.r unite.split.files \
		idir=$(PAIRED_BOTH_DIR) \
		pattern=$(DECONSEQ_PATTERN) \
		ofn1=$(PAIRED_R1) \
		ofn2=$(PAIRED_R2)
	$(_end_touch)
lib_final: $(PAIR_SINGLE_DONE)

$(PP_COUNT_DECONSEQ): $(PAIR_DONE)
	$(_start)
	$(_md)/pl/count_fastq.pl $(PAIRED_BOTH_DIR) '*' '*.fq' no_human $@
	$(_end)
pair_stats: $(PP_COUNT_DECONSEQ)
