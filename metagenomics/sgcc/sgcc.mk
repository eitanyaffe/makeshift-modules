#####################################################################################################
# generate lib table
#####################################################################################################

SGCC_TABLE_DONE?=$(SGCC_TABLE_DIR)/.done_table
$(SGCC_TABLE_DONE):
	$(call _start,$(SGCC_TABLE_DIR))
	$(_R) $(SGCC_TABLE_SCRIPT) generate.sgcc.table \
		ifn=$(SGCC_INPUT_TABLE) \
		idir=$(SGCC_INPUT_DIR) \
		ofn=$(SGCC_TABLE) \
		ofn.extra=$(SGCC_TABLE_EXTRA)
	$(_end_touch)
sgcc_table: $(SGCC_TABLE_DONE)

#####################################################################################################
# signatures
#####################################################################################################

SGCC_INPUT_DONE?=$(SGCC_LIB_WORK_DIR)/.done_input
$(SGCC_INPUT_DONE):
	$(call _start,$(SGCC_LIB_WORK_DIR))
	cp $(SGCC_INPUT_R1_GZ) $(SGCC_SEQ_R1_GZ)
	cp $(SGCC_INPUT_R2_GZ) $(SGCC_SEQ_R2_GZ)
	pigz -d -p $(SGCC_PIGZ_THREADS) $(SGCC_SEQ_R1_GZ)
	pigz -d -p $(SGCC_PIGZ_THREADS) $(SGCC_SEQ_R2_GZ)
	perl $(_md)/pl/count_fastq_fn.pl $(SGCC_SEQ_R1) $(SGCC_SEQ_R2) $(SGCC_LIB_ID) $(SGCC_READ_COUNT_FILE)
	perl $(_md)/pl/subsample.pl $(SGCC_SEQ_R1) $(SGCC_FASTQ_COUNT) $(SGCC_SUBSAMPLE_SEED) > $(SGCC_FASTQ)
	perl $(_md)/pl/subsample.pl $(SGCC_SEQ_R2) $(SGCC_FASTQ_COUNT) $(SGCC_SUBSAMPLE_SEED) >> $(SGCC_FASTQ)
	rm $(SGCC_SEQ_R1) $(SGCC_SEQ_R2)
	$(_end_touch)
sgcc_input: $(SGCC_INPUT_DONE)

SGCC_SIG_DONE?=$(SGCC_LIB_WORK_DIR)/.done_compute
$(SGCC_SIG_DONE): $(SGCC_INPUT_DONE)
	$(_start)
	$(SOURMASH) compute \
		-k $(SGCC_KMER_SIG) \
		-o $(SGCC_SIG) \
		$(SGCC_FASTQ)
	$(_end_touch)
sgcc_sig: $(SGCC_SIG_DONE)

S_SGCC_SIG_DONE?=$(SGCC_LIB_INFO_DIR)/.done_sig
$(S_SGCC_SIG_DONE):
	$(_start)
	$(MAKE) m=par par \
		PAR_MODULE=sgcc \
		PAR_WORK_DIR=$(SGCC_LIB_INFO_DIR) \
		PAR_NAME=sgcc_sig \
		PAR_TARGET=sgcc_sig \
		PAR_ODIR_VAR=SGCC_LIB_WORK_DIR \
		PAR_DISK_GB=$(SGCC_DISK_GB) \
		PAR_DISK_TYPE=pd-ssd \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_sig: $(S_SGCC_SIG_DONE)

#####################################################################################################
# compare
#####################################################################################################

SGCC_COMPARE_DONE?=$(SGCC_COMPARE_DIR)/.done_compare
$(SGCC_COMPARE_DONE):
	$(call _start,$(SGCC_COMPARE_DIR))
	$(_R) R/sgcc.r compare \
		binary=$(SOURMASH) \
		ifn=$(SGCC_TABLE) \
		idir=$(SGCC_BASE_DIR) \
		wdir=$(SGCC_COMPARE_DIR)/wdir \
		kmer=$(SGCC_KMER_SIG) \
		ofn=$(SGCC_COMPARE_TABLE) \
		ofn.stats=$(SGCC_STATS_TABLE)
	$(MAKE) m=par par_delete_find \
		PAR_REMOVE_DIR=$(SGCC_LIBS_DIR) \
		PAR_REMOVE_NAME_PATTERN="reads.fq"
	$(_end_touch)
sgcc_compare: $(SGCC_COMPARE_DONE)
