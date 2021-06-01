
REMOVE_DUP_BIN_LOCAL?=/tmp/remove_duplicates

$(eval $(call bin_rule3,remove_duplicates,$(_md)/cpp/remove_duplicates.cpp))
REMOVE_DUP_BIN?=$(BIN_DIR)/libs/remove_duplicates
libs_init: $(REMOVE_DUP_BIN)

DUP_DONE=$(DUP_DIR)/.done_dups
$(DUP_DONE):
	$(call _start,$(DUP_DIR))
	cp $(REMOVE_DUP_BIN) $(REMOVE_DUP_BIN_LOCAL) && chmod +x $(REMOVE_DUP_BIN_LOCAL)
	$(call _time,$(DUP_DIR),dup) \
	$(REMOVE_DUP_BIN_LOCAL) \
		 -ifn1 $(TRIMMOMATIC_PAIRED_R1) \
		 -ifn2 $(TRIMMOMATIC_PAIRED_R2) \
		 -ofn1 $(DUP_R1) \
		 -ofn2 $(DUP_R2) \
		 -mfn $(COMPLEXITY_TABLE) \
		 -sfn $(SUMMARY_TABLE)
remove_dups_base: $(DUP_DONE)

$(COUNT_DUPS): $(DUP_DONE)
	$(_start)
	perl $(_md)/pl/count_fastq_fn.pl $(DUP_R1) $(DUP_R2) duplicate $@
	$(_end)
remove_dups: $(COUNT_DUPS)
