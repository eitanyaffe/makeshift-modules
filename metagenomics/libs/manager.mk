S_SETUP_DIRS_DONE?=$(LIB_INFO_DIR)/.done_setup_dirs
$(S_SETUP_DIRS_DONE):
	$(_start,$(LIB_INFO_DIR))
	mkdir -p  $(READ_STATS_DIR) $(RUN_STATS_DIR)
	touch $(READ_STATS_DIR)/.created
	touch $(RUN_STATS_DIR)/.created
	$(_end_touch)
s_setup_dirs: $(S_SETUP_DIRS_DONE)

S_EXTRACT_DONE?=$(LIB_INFO_DIR)/.done_uncompress
$(S_EXTRACT_DONE): $(S_SETUP_DIRS_DONE)
	$(_start)
	$(MAKE) m=par par \
		PAR_MODULE=libs \
		PAR_NAME=lib_unzip \
		PAR_WORK_DIR=$(LIB_INFO_DIR) \
		PAR_ODIR_VAR=LIB_INPUT_DIR \
		PAR_TARGET=lib_extract \
		PAR_EMAIL=F \
		PAR_MACHINE=n1-standard-2 \
		PAR_DISK_GB=$(LIBS_DISK_GB) \
		PAR_DISK_TYPE=$(LIBS_DISK_TYPE) \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_extract: $(S_EXTRACT_DONE)

S_TRIMMO_DONE?=$(LIB_INFO_DIR)/.done_trimmomatic
$(S_TRIMMO_DONE): $(S_EXTRACT_DONE)
	$(_start)
	$(MAKE) m=libs trimmomatic
	$(_end_touch)
s_trimmo: $(S_TRIMMO_DONE)

$(PP_COUNT_TRIMMOMATIC): $(S_TRIMMO_DONE)
	$(_start)
	perl $(_md)/pl/count_fastq.pl $(TRIMMOMATIC_OUTDIR) '*' '*.fastq' no_adapters $@
	$(_end)
trimmo_stats: $(PP_COUNT_TRIMMOMATIC)

S_DUPS_DONE?=$(LIB_INFO_DIR)/.done_dups
$(S_DUPS_DONE): $(PP_COUNT_TRIMMOMATIC)
	$(_start)
	$(MAKE) m=par par \
		PAR_MODULE=libs \
		PAR_NAME=lib_dups \
		PAR_WORK_DIR=$(LIB_INFO_DIR) \
		PAR_ODIR_VAR=DUP_DIR \
		PAR_TARGET=remove_dups \
		PAR_EMAIL=F \
		PAR_MACHINE=n1-highmem-8 \
		PAR_DISK_GB=$(LIBS_DISK_GB) \
		PAR_DISK_TYPE=$(LIBS_DISK_TYPE) \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_dups: $(S_DUPS_DONE)

S_SPLIT_DONE?=$(LIB_INFO_DIR)/.done_split
$(S_SPLIT_DONE): $(S_DUPS_DONE)
	$(_start)
	$(MAKE) m=par par \
		PAR_MODULE=libs \
		PAR_NAME=lib_split \
		PAR_WORK_DIR=$(LIB_INFO_DIR) \
		PAR_ODIR_VAR=SPLIT_DIR \
		PAR_TARGET=libs_split \
		PAR_EMAIL=F \
		PAR_MACHINE=n1-standard-2 \
		PAR_DISK_GB=$(LIBS_DISK_GB) \
		PAR_DISK_TYPE=$(LIBS_DISK_TYPE) \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_split: $(S_SPLIT_DONE)

S_DECONSEQ_DONE?=$(LIB_INFO_DIR)/.done_deconseq
$(S_DECONSEQ_DONE): $(S_SPLIT_DONE)
	$(_start)
	$(MAKE) m=par par_tasks_table \
		PAR_MODULE=libs \
		PAR_NAME=lib_deconseq \
		PAR_WORK_DIR=$(LIB_INFO_DIR) \
		PAR_TARGET=deconseq \
		PAR_EMAIL=F \
		PAR_TASK_ODIR_VAR=DECONSEQ_DIR \
		PAR_TASK_ITEM_VAR=CHUNK_ID \
		PAR_TASK_ITEM_TABLE=$(CHUNK_TABLE) \
		PAR_TASK_ITEM_FIELD?=chunk \
		PAR_MACHINE=n1-standard-4 \
		PAR_DISK_GB=$(LIBS_CHUNK_DISK_GB) \
		PAR_DISK_TYPE=$(LIBS_CHUNK_DISK_TYPE) \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(call _time,$(RUN_STATS_DIR),merge_stats) $(_R) R/merge.r merge.stats \
		ifn=$(CHUNK_TABLE) \
		idir=$(CHUNKS_DIR) \
		ofn=$(PP_COUNT_DECONSEQ)
	$(_end_touch)
s_deconseq: $(S_DECONSEQ_DONE)

S_PAIR_DONE?=$(LIB_INFO_DIR)/.done_pair
$(S_PAIR_DONE): $(S_DECONSEQ_DONE)
	$(_start)
	$(MAKE) m=par par_tasks_table \
		PAR_MODULE=libs \
		PAR_NAME=lib_pair \
		PAR_TARGET=pair \
		PAR_EMAIL=F \
		PAR_WORK_DIR=$(LIB_INFO_DIR) \
		PAR_TASK_ODIR_VAR=PAIRED_DIR \
		PAR_TASK_ITEM_VAR=CHUNK_ID \
		PAR_TASK_ITEM_TABLE=$(CHUNK_TABLE) \
		PAR_TASK_ITEM_FIELD?=chunk \
		PAR_MACHINE=n1-highmem-2 \
		PAR_DISK_GB=$(LIBS_CHUNK_DISK_GB) \
		PAR_DISK_TYPE=$(LIBS_DISK_TYPE) \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_pair: $(S_PAIR_DONE)

# merge into a single pair R1/R2
S_MERGE_DONE?=$(LIB_INFO_DIR)/.done_merge
$(S_MERGE_DONE): $(S_PAIR_DONE)
	$(_start)
	$(MAKE) m=par par \
		PAR_MODULE=libs \
		PAR_NAME=lib_merge \
		PAR_WORK_DIR=$(LIB_INFO_DIR) \
		PAR_ODIR_VAR=LIB_MERGE_DIR \
		PAR_TARGET=lib_merge \
		PAR_EMAIL=F \
		PAR_MACHINE=n1-standard-2 \
		PAR_DISK_GB=$(LIBS_DISK_GB) \
		PAR_DISK_TYPE=$(LIBS_DISK_TYPE) \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_merge: $(S_MERGE_DONE)

S_COMPRESS_DONE?=$(LIB_INFO_DIR)/.done_compress
$(S_COMPRESS_DONE): $(S_MERGE_DONE)
	$(_start)
	$(MAKE) m=par par \
		PAR_MODULE=libs \
		PAR_NAME=lib_compress \
		PAR_WORK_DIR=$(LIB_INFO_DIR) \
		PAR_ODIR_VAR=LIB_OUT_DIR \
		PAR_TARGET=lib_compress \
		PAR_EMAIL=F \
		PAR_MACHINE=n1-standard-2 \
		PAR_DISK_GB=$(LIBS_DISK_GB) \
		PAR_DISK_TYPE=$(LIBS_DISK_TYPE) \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_compress: $(S_COMPRESS_DONE)

S_COLLECT_STATS_DONE?=$(LIB_INFO_DIR)/.done_collect_stats
$(S_COLLECT_STATS_DONE): $(S_COMPRESS_DONE)
	$(_start)
	cp $(COMPLEXITY_TABLE) $(FINAL_COMPLEXITY_TABLE)
	cp $(SUMMARY_TABLE) $(FINAL_SUMMARY_TABLE)
	cp $(COUNT_INPUT) $(PP_COUNT_INPUT)
	cp $(COUNT_DUPS) $(PP_COUNT_DUPS)
	cp $(COUNT_MERGE) $(PP_COUNT_FINAL)
	cp \
		$(DUP_DIR)/.stat* \
		$(SPLIT_DIR)/.stat* \
		$(DECONSEQ_DIR)/.stat* \
		$(PAIRED_DIR)/.stat* \
		$(LIB_OUT_DIR)/.stat* \
		$(LIB_MERGE_DIR)/.stat* \
		$(RUN_STATS_DIR)/
	$(_end_touch)
s_stats: $(S_COLLECT_STATS_DONE)

S_CLEAN_DONE?=$(LIB_INFO_DIR)/.done_clean
$(S_CLEAN_DONE): $(S_COLLECT_STATS_DONE)
	$(_start)
	$(MAKE) m=par par_delete \
		PAR_REMOVE_PATHS="$(MERGED_R1) $(MERGED_R2)"
	$(MAKE) m=par par_delete_find \
		PAR_REMOVE_DIR=$(LIB_WORK_DIR) \
		PAR_REMOVE_NAME_PATTERN="*fq"
	$(MAKE) m=par par_delete_find \
		PAR_REMOVE_DIR=$(LIB_WORK_DIR) \
		PAR_REMOVE_NAME_PATTERN="*fastq"
	$(MAKE) m=par par_delete_find \
		PAR_REMOVE_DIR=$(SPLIT_DIR) \
		PAR_REMOVE_NAME_PATTERN="*fastq"
	$(MAKE) m=par par_delete_find \
		PAR_REMOVE_DIR=$(LIB_MERGE_DIR) \
		PAR_REMOVE_NAME_PATTERN="*fastq"
	$(MAKE) m=par par_delete_find \
		PAR_REMOVE_DIR=$(INPUT_DIR) \
		PAR_REMOVE_NAME_PATTERN="*fastq"
	$(_end_touch)
s_clean: $(S_CLEAN_DONE)

s_lib: s_clean

