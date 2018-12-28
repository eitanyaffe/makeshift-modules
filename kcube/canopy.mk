CC_DONE=$(CANOPY_DIR)/.done_init
$(CC_DONE):
	$(call _start,$(CANOPY_DIR))
	grep -v "^item" $(CUBE_MATRIX) > $(CANOPY_INPUT)
	dckr run -p /home/eitany/work/tools/dckr/profiles/base -i eitanyaffe/cc ./cc.bin \
		-i $(CANOPY_INPUT) \
		-o $(CANOPY_CLUSTERS) \
		-c $(CANOPY_PROFILES) \
		--progress_stat_file $(CANOPY_PROGRESS) \
		--filter_min_obs 0 \
		--cag_filter_max_top3_sample_contribution 1 \
		--stop_criteria 0 \
		-n 40 \
		-p kcube -t
	$(_end_touch)
canopy: $(CC_DONE)
