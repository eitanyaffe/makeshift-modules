
#####################################################################################################
# extract lib ids
#####################################################################################################

SGCC_IDS_DONE?=$(SGCC_DIR)/.done_ids
$(SGCC_IDS_DONE):
	$(call _start,$(SGCC_DIR))
	$(_R) R/sgcc.r extract.ids \
		ifn=$(SGCC_SAMPLE_TABLE_IN) \
		type=$(SGCC_SAMPLE_TYPE) \
		ofn=$(SGCC_LIB_IDS_FILE)
	$(_end_touch)
sgcc_ids: $(SGCC_IDS_DONE)

#####################################################################################################
# signatures
#####################################################################################################

SGCC_INPUT_DONE?=$(SGCC_INPUT_DIR)/.done_$(LIB_ID)
$(SGCC_INPUT_DONE):
	$(call _start,$(SGCC_INPUT_DIR))
	head -n $(SGCC_FASTQ_COUNT) $(SGCC_INPUT_FASTQ) > $(SGCC_FASTQ)
	$(_end_touch)
sgcc_input: $(SGCC_INPUT_DONE)

SGCC_SIG_DONE?=$(SGCC_SIG_DIR)/.done_$(LIB_ID)
$(SGCC_SIG_DONE): $(SGCC_INPUT_DONE)
	$(call _start,$(SGCC_SIG_DIR))
	$(SOURMASH) compute \
		-k $(SGCC_KMER_SIG) \
		-o $(SGCC_SIG) \
		$(SGCC_FASTQ)
	$(_end_touch)
sgcc_sig: $(SGCC_SIG_DONE)

sgcc_sigs:
	$(_Rcall) $(CURDIR) $(_md)/R/sgcc.r make \
		ifn=$(SGCC_SAMPLE_TABLE_IN) \
		type=$(SGCC_SAMPLE_TYPE) \
		target=sgcc_sig \
		is.dry=$(DRY)

#####################################################################################################
# compare
#####################################################################################################

# SGCC_COMPARE_DONE?=$(SGCC_DIR)/.done_compare
# $(SGCC_COMPARE_DONE):
# 	$(_start)
# 	$(_R) R/sgcc.r compare \
# 		ifn=$(SGCC_SAMPLE_TABLE_IN) \
# 		type=$(SGCC_SAMPLE_TYPE) \
# 		command.pre=$(SOURMASH) \
# 		ifn.template=$(SGCC_SIG) \
# 		id.template=$(LIB_ID) \
# 		kmer=$(SGCC_KMER_COMPARE) \
# 		ofn=$(SGCC_COMPARE_TABLE)
# 	$(_end_touch)
# sgcc_compare: $(SGCC_COMPARE_DONE)

SGCC_COMPARE_DONE?=$(SGCC_DIR)/.done_compare
$(SGCC_COMPARE_DONE):
	$(_start)
	$(_R) R/sgcc.r compare \
		command.pre='$(SOURMASH)' \
		idir=$(SGCC_SIG_DIR) \
		kmer=$(SGCC_KMER_COMPARE) \
		ofn=$(SGCC_COMPARE_TABLE)
#	$(_end_touch)
sgcc_compare: $(SGCC_COMPARE_DONE)
