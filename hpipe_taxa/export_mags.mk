SC_MAGS_DONE?=$(SC_MAGS_DIR)/.done
$(SC_MAGS_DONE):
	$(call _start,$(SC_MAGS_DIR))
	$(_R) R/export_mags.r export.mags \
		ifn=$(SC_SUMMARY_UNIQUE) \
		idir=$(SC_ANCHOR_DIR) \
		subject.id=$(SUBJECT_SHORT) \
		ofn=$(SC_MAGS_TABLE) \
		odir=$(SC_MAGS_FASTA_DIR)
	$(_end_touch)
sc_mags: $(SC_MAGS_DONE)
