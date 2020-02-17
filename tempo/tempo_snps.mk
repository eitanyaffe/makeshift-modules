##########################################
##########################################
ifeq ($(TEMPO_INPUT_TYPE),hmd)
##########################################
##########################################

SUBJECT_SETS_DONE?=$(SUBJECT_DIR)/.done_lib_defs
$(SUBJECT_SETS_DONE):
	$(call _start,$(SUBJECT_DIR))
	$(_R) $(_md)/R/tempo_snps.r create.lib.set.table \
		ifn=$(SUBJECT_LIB_TABLE) \
		n.libs=$(SUBJECT_LIBSET_COUNT) \
		ofn=$(SUBJECT_LIB_DEF_TABLE)
	$(_end_touch)

##########################################
##########################################
else
##########################################
##########################################

SUBJECT_SETS_DONE?=$(SUBJECT_DIR)/.done_subject_sets
$(SUBJECT_SETS_DONE):
	$(call _start,$(SUBJECT_DIR))
	cp $(SUBJECT_LIB_DEF_TABLE_INPUT) $(SUBJECT_LIB_DEF_TABLE)
	cp $(SUBJECT_LIB_DEF_TABLE_INPUT) $(SUBJECT_SAMPLE_DEFS)
	$(_end_touch)

endif
##########################################
##########################################

tempo_snp_lib_table: $(SUBJECT_SETS_DONE)

SUBJECT_SETS_EXPLODE_DONE?=$(SUBJECT_DIR)/.done_subject_sets_explode
$(SUBJECT_SETS_EXPLODE_DONE): $(SUBJECT_SETS_DONE)
	$(_start)
	$(_R) $(_md)/R/tempo_snps.r lib.sets.explode \
		ifn=$(SUBJECT_LIB_DEF_TABLE) \
		ofn.base=$(SUBJECT_BASE_IDS_FILE) \
		ofn.mid=$(SUBJECT_MID_IDS_FILE) \
		ofn.post=$(SUBJECT_POST_IDS_FILE)
	$(_end_touch)
tempo_snps_explode: $(SUBJECT_SETS_EXPLODE_DONE)

tempo_snps_init: $(SUBJECT_SETS_EXPLODE_DONE)
