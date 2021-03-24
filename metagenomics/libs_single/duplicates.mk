DUP_DONE=$(LIB_DIR)/.done_dups
$(DUP_DONE):
	$(call _start,$(DUP_DIR))
	perl $(_md)/pl/remove_duplicate_wrapper_single.pl \
		$(REMOVE_DUP_BIN) \
		$(INPUT_FILE_SUFFIX) \
		$(DUP_R) \
		$(LIB_COMPLEXITY_TABLE) \
		$(LIB_SUMMARY_TABLE) \
		$(DUP_INPUT_DIR)
	$(_end_touch)
dups_basic: $(DUP_DONE)

$(PP_COUNT_DUPS): $(DUP_DONE)
	$(_start)
	$(_md)/pl/count_fastq_fn_single.pl $(DUP_R) duplicate $@
	$(_end)
dups: $(PP_COUNT_DUPS)

$(eval $(call bin_rule2,remove_duplicates,$(_md)/cpp/remove_duplicates.cpp))
REMOVE_DUP_BIN?=$(_md)/bin.$(_binary_suffix)/remove_duplicates_single
libs_init: $(REMOVE_DUP_BIN)
