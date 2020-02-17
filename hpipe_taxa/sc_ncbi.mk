SC_NCBI_DONE?=$(SC_NCBI_DIR)/.done
$(SC_NCBI_DONE):
	$(call _start,$(SC_NCBI_DIR))
	$(_R) R/sc_ncbi.r prepare.for.ncbi \
		ifn.anchors=$(SC_CORE_TABLE) \
		ifn.anchor2id=$(SC_SUMMARY_UNIQUE) \
		ifn.info=$(ANCHOR_INFO_TABLE) \
		ifn.taxa=$(SET_TAXA_REPS) \
		idir=$(SC_ANCHOR_DIR) \
		subject.id=$(SUBJECT_SHORT) \
		ofn=$(SC_NCBI_TABLE) \
		odir=$(SC_NCBI_GENOME_DIR)
	$(_end_touch)
sc_ncbi: $(SC_NCBI_DONE)
