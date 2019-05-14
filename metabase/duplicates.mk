DUP_DONE=$(DUP_DIR)/.done_input
$(DUP_DONE):
	$(call _start,$(DUP_DIR))
ifeq ($(LIB_INPUT_STYLE),files)
	$(REMOVE_DUP_BIN) \
		-ifn1 $(LIB_INPUT_R1) \
		-ifn2 $(LIB_INPUT_R2) \
		-ofn1 $(DUP_R1) \
		-ofn2 $(DUP_R2) \
		-mfn $(LIB_COMPLEXITY_TABLE) \
		-sfn $(PP_COUNT_INPUT)
else
	perl $(_md)/pl/remove_duplicate_wrapper.pl \
		$(REMOVE_DUP_BIN) \
		$(INPUT_FILE_SUFFIX) \
		$(DUP_DIR)/R1.fastq \
		$(DUP_DIR)/R2.fastq \
		$(LIB_COMPLEXITY_TABLE) \
		$(PP_COUNT_INPUT) \
		$(LIB_INPUT_DIRS)
endif
	$(_end_touch)

$(PP_COUNT_DUPS): $(DUP_DONE)
	$(_start)
	$(_md)/pl/count_fastq_fn.pl $(DUP_R1) $(DUP_R2) duplicate $@
	$(_end)
dups: $(PP_COUNT_DUPS)

$(eval $(call bin_rule2,remove_duplicates,$(_md)/cpp/remove_duplicates.cpp))
REMOVE_DUP_BIN?=$(_md)/bin.$(_binary_suffix)/remove_duplicates
metabase_init: $(REMOVE_DUP_BIN)
