
$(PP_COUNT_INPUT):
	$(call _start,$(LIB_DIR))
ifeq ($(LIB_INPUT_STYLE),files)
	$(_md)/pl/count_fastq_fn_single.pl $(TRIMMOMATIC_IN_R) input $@
else
	$(_md)/pl/count_fastq_dirs_single.pl '*' '*.$(INPUT_FILE_SUFFIX)' input $@ $(TRIMMOMATIC_IN_DIRS)
endif
	$(_end)
input_stats: $(PP_COUNT_INPUT)

TRIMMOMATIC_DONE?=$(LIB_DIR)/.done_trimmomatic
$(TRIMMOMATIC_DONE): $(PP_COUNT_INPUT)
	$(call _start,$(TRIMMOMATIC_OUTDIR))
ifeq ($(LIB_INPUT_STYLE),files)
		java -jar $(TRIMMOMATIC_JAR) $(TRIMMOMATIC_MODE) \
		-threads $(TRIMMOMATIC_THREADS) \
		$(TRIMMOMATIC_IN_R) \
		$(TRIMMOMATIC_R) \
		$(TRIMMOMATIC_PARAMS)
else
	perl $(_md)/pl/trimmomatic_dirs_single.pl \
		$(TRIMMOMATIC_JAR) \
		$(TRIMMOMATIC_MODE) \
		$(TRIMMOMATIC_THREADS) \
		"$(TRIMMOMATIC_PARAMS)" \
		$(INPUT_FILE_SUFFIX) \
		$(TRIMMOMATIC_OUTDIR) \
		$(TRIMMOMATIC_IN_DIRS)
endif
	$(_end_touch)
trimmomatic_base: $(TRIMMOMATIC_DONE)

$(PP_COUNT_TRIMMOMATIC): $(TRIMMOMATIC_DONE)
	$(_start)
	perl $(_md)/pl/count_fastq_single.pl $(TRIMMOMATIC_OUTDIR) '*' '*.fastq' no_adapters $@
	$(_end)

trimmomatic: $(PP_COUNT_TRIMMOMATIC)

