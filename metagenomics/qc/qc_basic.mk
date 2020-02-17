QC_EXTRACT_DONE=$(QC_LIB_DIR)/.done_extract
$(QC_EXTRACT_DONE):
	$(call _start,$(QC_LIB_INPUT_DIR))
	gunzip -c $(QC_LIB_GZ_R1) > $(QC_LIB_R1)
	gunzip -c $(QC_LIB_GZ_R2) > $(QC_LIB_R2)
	$(_end_touch)
qc_extract: $(QC_EXTRACT_DONE)

QC_LIB_DONE=$(QC_LIB_DIR)/.done_qc_lib
$(QC_LIB_DONE): $(QC_EXTRACT_DONE)
	$(_start)
	$(MAKE) m=libs trimmomatic dups libs_clobber \
		LIB_INPUT_STYLE=files \
		LIB_DIR=$(QC_LIB_DIR) \
		LIB_INPUT_R1=$(QC_LIB_R1) \
		LIB_INPUT_R2=$(QC_LIB_R2)
	rm -rf $(QC_LIB_INPUT_DIR)
	$(_end_touch)
qc_lib: $(QC_LIB_DONE)

qc_libs:
	$(_Rcall) $(CURDIR) $(_md)/R/qc_libs.r make \
		ifn=$(QC_IN_SAMPLE_TABLE) \
		idir=$(QC_IN_FASTQ_DIR) \
		target=qc_lib \
		is.dry=$(DRY)
