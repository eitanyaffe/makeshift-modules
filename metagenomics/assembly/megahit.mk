##########################################################################################################
# run megahit
##########################################################################################################

MEGAHIT_WORK_DIR?=$(ASSEMBLY_WORK_DIR)/run

# keep megahit pid to pause it while rsyncing data
RSYNC_BG_PID_FN?=$(ASSEMBLY_WORK_DIR)/.rsync_bg_pid
MEGAHIT_PID_FN?=$(ASSEMBLY_WORK_DIR)/.megahit_pid


MEGAHIT_DONE?=$(ASSEMBLY_WORK_DIR)/.done_megahit
$(MEGAHIT_DONE):
	$(call _start,$(ASSEMBLY_WORK_DIR))
ifneq ($(GCP_RSYNC_SRC_VAR),not_defined)
	bash $(_md)/sh/submit_bg.sh $(RSYNC_BG_PID_FN) $(_md)/sh/rsync_loop.sh \
		$(GCP_RSYNC_SRC_VAR) \
		$(GCP_RSYNC_SRC) \
		$(GCP_RSYNC_TARGET_BUCKET) \
		$(MEGAHIT_RSYNC_WAIT_TIME) \
		$(MEGAHIT_PID_FN)
endif
	$(call _time,$(ASSEMBLY_WORK_DIR),,megahit) \
	bash $(_md)/sh/submit_megahit.sh $(MEGAHIT_PID_FN) \
	python3 $(MEGAHIT_BIN) $(MEGA_HIT_PARAMS) \
		-m $(MEGAHIT_MEMORY_CAP) \
		$(if $(wildcard $(MEGAHIT_WORK_DIR)),--continue )-o $(MEGAHIT_WORK_DIR) \
		--min-contig-len $(MEGAHIT_MIN_CONTIG_LENGTH) \
		--k-min $(MEGAHIT_MIN_KMER) \
		--k-max $(MEGAHIT_MAX_KMER) \
		--k-step $(MEGAHIT_KMER_STEP) \
		$(MEGAHIT_MISC) \
		-t $(ASSEMBLY_THREADS) \
		-r $(ASSEMBLY_INPUT_FASTQ)
ifneq ($(GCP_RSYNC_SRC_VAR),not_defined)
	@kill `cat $(RSYNC_BG_PID_FN)`
endif
	cp $(MEGAHIT_WORK_DIR)/final.contigs.fa $(FULL_CONTIG_FILE)
	cat $(FULL_CONTIG_FILE) | perl $(_md)/pl/fasta_summary.pl > $(FULL_CONTIG_TABLE)
	$(_end_touch)
megahit_base: $(MEGAHIT_DONE)

##########################################################################################################
# process results
##########################################################################################################

# select long contigs
MEGAHIT_SELECT_DONE?=$(ASSEMBLY_WORK_DIR)/.done_megahit_select
$(MEGAHIT_SELECT_DONE): $(MEGAHIT_DONE)
	$(_start)
	$(_R) $(_md)/R/select_contigs.r top \
	        table=$(FULL_CONTIG_TABLE) \
		ofn=$(ASSEMBLY_CONTIG_TABLE) \
		min.length=$(ASSEMBLY_MIN_LEN)
	perl $(_md)/pl/select_contigs.pl \
		$(FULL_CONTIG_FILE) \
		$(ASSEMBLY_CONTIG_TABLE) \
		$(ASSEMBLY_CONTIG_FILE)
	$(_end_touch)
megahit_main: $(MEGAHIT_SELECT_DONE)

# remove input files
MEGAHIT_CLEAN_DONE?=$(ASSEMBLY_WORK_DIR)/.done_clean
$(MEGAHIT_CLEAN_DONE): $(MEGAHIT_SELECT_DONE)
	$(_start)
	$(MAKE) m=par par_delete \
		PAR_REMOVE_PATHS=$(ASSEMBLY_INPUT_FASTQ)
	$(_end_touch)
megahit_clean: $(MEGAHIT_CLEAN_DONE)

# generate fastg
MEGAHIT_FASTG_DONE?=$(ASSEMBLY_WORK_DIR)/.done_megahit_fastg
$(MEGAHIT_FASTG_DONE): $(MEGAHIT_CLEAN_DONE)
	$(_start)
	$(MEGAHIT_BIN)_toolkit contig2fastg \
		$(MEGAHIT_MAX_KMER) \
		$(MEGAHIT_WORK_DIR)/intermediate_contigs/k$(MEGAHIT_MAX_KMER).contigs.fa \
		> $(MEGAHIT_FASTG)
	$(_end_touch)
megahit_fastg: $(MEGAHIT_FASTG_DONE)

megahit: $(MEGAHIT_FASTG_DONE)

