
# uncompress hmp libs
HMP_DONE=$(HMP_DIR)/.done_$(HMP_LABEL)
$(HMP_DONE):
	$(call _start,$(HMP_DIR))
	$(_R) $(_md)/R/hmp.r uncompress \
		idir=$(HMP_INPUT) \
		count=$(HMP_LIB_COUNT) \
		ofn.table=$(HMP_LIB_TABLE) \
		odir=$(HMP_DIR)
	$(_end_touch)
prepare_hmp: $(HMP_DONE)
