###########################################################################
# prepare library
###########################################################################

##########################################
##########################################
ifeq ($(TEMPO_INPUT_TYPE),hmd)
##########################################
##########################################

# subject init
SUBJECT_INIT_DONE?=$(SUBJECT_DIR)/.done_subject_init
$(SUBJECT_INIT_DONE):
	$(call _start,$(SUBJECT_DIR))
	$(_R) $(_md)/R/create_lib_table.r create.lib.table \
		sample.ifn=$(TEMPO_SAMPLE_TABLE_IN) \
		measure.ifn=$(TEMPO_MEASURE_TABLE_IN) \
		base.dna.dir=$(TEMPO_TRIMMED_BASE_DNA_DIR_IN) \
		base.rna.dir=$(TEMPO_TRIMMED_BASE_RNA_DIR_IN) \
		subject.id=$(SUBJECT_ID) \
		types=$(TEMPO_TYPES) \
		ofn.dna.lib.table=$(SUBJECT_DNA_LIB_TABLE) \
		ofn.dna.lib.ids=$(SUBJECT_DNA_LIB_IDS_FILE) \
		ofn.rna.lib.table=$(SUBJECT_RNA_LIB_TABLE) \
		ofn.rna.lib.ids=$(SUBJECT_RNA_LIB_IDS_FILE) \
		ofn.defs=$(SUBJECT_SAMPLE_DEFS)
	$(_end_touch)
tempo_subject_init: $(SUBJECT_INIT_DONE)

# single lib
TEMPO_LIB_INPUT_DONE?=$(LIB_DIR)/.done_tempo_input
$(TEMPO_LIB_INPUT_DONE):
	$(call _start,$(TRIMMOMATIC_OUTDIR))
	gunzip -c $(TEMPO_INPUT_R1) > $(TEMPO_R1)
	gunzip -c $(TEMPO_INPUT_R2) > $(TEMPO_R2)
	$(_end_touch)
tempo_lib_input: $(TEMPO_LIB_INPUT_DONE)
tempo_lib: $(TEMPO_LIB_INPUT_DONE)
	@$(MAKE) m=libs dups deconseq lib_final LIB_INPUT_STYLE=files

##########################################
##########################################
else ifeq ($(TEMPO_INPUT_TYPE),pass)
##########################################
##########################################

# subject init
SUBJECT_INIT_DONE?=$(SUBJECT_DIR)/.done_subject_init
$(SUBJECT_INIT_DONE):
	$(call _start,$(LIB_DIR))
	$(_R) $(_md)/R/passaging_libs.r create.tables \
		sample.ifn=$(TEMPO_PASS_SAMPLE_TABLE_IN) \
		seq.ifn=$(TEMPO_PASS_SEQ_TABLE_IN) \
		subject.lookup.ifn=$(TEMPO_PASS_SUBJECT_LOOKUP_IN) \
		base.dir=$(TEMPO_PASS_FASTQ_DIR_IN) \
		subject.id=$(SUBJECT_ID) \
		ofn.lib.table=$(SUBJECT_DNA_LIB_TABLE) \
		ofn.lib.ids=$(SUBJECT_DNA_LIB_IDS_FILE)
	$(_end_touch)
tempo_subject_init: $(SUBJECT_INIT_DONE)

tempo_lib:
	@$(MAKE) m=libs trimmomatic dups deconseq lib_final libs_clobber LIB_INPUT_STYLE=files

##########################################
##########################################
else # raw
##########################################
##########################################

# subject init
SUBJECT_INIT_DONE?=$(SUBJECT_DIR)/.done_subject_init
$(SUBJECT_INIT_DONE):
	$(call _start,$(LIB_DIR))
	cp $(TEMPO_SUBJECT_INPUT_LIB_IDS) $(SUBJECT_DNA_LIB_IDS_FILE)
	$(_end_touch)
tempo_subject_init: $(SUBJECT_INIT_DONE)

tempo_lib:
	@$(MAKE) m=libs trimmomatic dups deconseq lib_final LIB_INPUT_STYLE=dirs

endif
##########################################
##########################################

###########################################################################
# clean intermediate files
###########################################################################

tempo_clobber:
	@$(MAKE) m=libs libs_clobber

###########################################################################
# all libs of subject
###########################################################################

tempo_libs:
	$(_Rcall) $(CURDIR) $(_md)/R/multi_lib.r make \
		type=$(TEMPO_INPUT_TYPE) \
		ifn=$(SUBJECT_LIB_TABLE) \
		ids=$(SUBJECT_LIB_IDS) \
		target=tempo_lib \
		is.dry=$(DRY)

# remove transient files
tempo_libs_clobber:
	$(_Rcall) $(CURDIR) $(_md)/R/multi_lib.r make \
		type=$(TEMPO_INPUT_TYPE) \
		ifn=$(SUBJECT_LIB_TABLE) \
		ids=$(SUBJECT_LIB_IDS) \
		target=tempo_clobber \
		is.dry=$(DRY)

###########################################################################
# prepare Hi-C libs
###########################################################################

hic_lib:
	@$(MAKE) m=libs trimmomatic dups deconseq lib_final
