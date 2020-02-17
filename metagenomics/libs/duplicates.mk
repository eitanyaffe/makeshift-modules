DUP_DONE=$(LIB_DIR)/.done_dups
$(DUP_DONE):
	$(call _start,$(DUP_DIR))
	perl $(_md)/pl/remove_duplicate_wrapper.pl \
		$(REMOVE_DUP_BIN) \
		$(INPUT_FILE_SUFFIX) \
		$(DUP_DIR)/R1.fastq \
		$(DUP_DIR)/R2.fastq \
		$(LIB_COMPLEXITY_TABLE) \
		$(LIB_SUMMARY_TABLE) \
		$(DUP_INPUT_DIR)
	$(_end_touch)
dups_basic: $(DUP_DONE)

$(PP_COUNT_DUPS): $(DUP_DONE)
	$(_start)
	$(_md)/pl/count_fastq_fn.pl $(DUP_R1) $(DUP_R2) duplicate $@
	$(_end)
dups: $(PP_COUNT_DUPS)

$(eval $(call bin_rule2,remove_duplicates,$(_md)/cpp/remove_duplicates.cpp))
REMOVE_DUP_BIN?=$(_md)/bin.$(_binary_suffix)/remove_duplicates
libs_init: $(REMOVE_DUP_BIN)
