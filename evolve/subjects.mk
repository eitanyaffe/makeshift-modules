#########################################################
# obsolete
#########################################################

#########################################################
# core fix table
#########################################################

SUBJECTS_FIX_INPUT_DONE?=$(SUBJECTS_DIR)/.done_fix_table
$(SUBJECTS_FIX_INPUT_DONE):
	$(call _start,$(SUBJECTS_DIR))
	$(_R) R/subjects.r fix.input \
		ifn1=$(AAB_MKT_GENE_TABLE) \
		ifn2=$(FP_MKT_GENE_TABLE) \
		ofn=$(SUBJECTS_FIX_TABLE)
	$(_end_touch)
subjects_fix_table: $(SUBJECTS_FIX_INPUT_DONE)

#########################################################
# core fix table
#########################################################

SUBJECTS_HGT_INPUT_DONE?=$(SUBJECTS_DIR)/.done_hgt_table
$(SUBJECTS_HGT_INPUT_DONE):
	$(call _start,$(SUBJECTS_DIR))
	$(_R) R/subjects.r hgt.input \
		ifn1=$(AAB_HGT_TABLE) \
		ifn2=$(FP_HGT_TABLE) \
		ofn=$(SUBJECTS_HGT_TABLE)
	$(_end_touch)
subjects_hgt_table: $(SUBJECTS_HGT_INPUT_DONE)

subjects_table: subjects_fix_table subjects_hgt_table
