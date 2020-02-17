###############################################################################################
# run metaBAT using docker
###############################################################################################

METABAT_INPUT_DONE?=$(METABAT_DIR)/.done_input
$(METABAT_INPUT_DONE):
	$(call _start,$(METABAT_DIR))
	cp $(METABAT_IN_CONTIGS) $(METABAT_CONTIGS)
	$(_end_touch)
mb_input: $(METABAT_INPUT_DONE)

METABAT_DCKR_PROFILE_DONE?=$(METABAT_WORK_DIR)/.done_dckr_profile
$(METABAT_DCKR_PROFILE_DONE): $(METABAT_INPUT_DONE)
	$(call _start,$(METABAT_WORK_DIR))
	echo "DOCKER_RUN_USER_OPTS=\"-v $(METABAT_DIR):/work\"" > $(METABAT_DCKR_PROFILE)
	$(_end_touch)
mb_dckr: $(METABAT_DCKR_PROFILE_DONE)

# calculate depth
METABAT_DEPTH_DONE?=$(METABAT_WORK_DIR)/.done_depth
$(METABAT_DEPTH_DONE): $(METABAT_INPUT_DONE) $(METABAT_DCKR_PROFILE_DONE)
	$(call _start,$(METABAT_WORK_DIR))
	$(METABAT_DOCKER) \
	jgi_summarize_bam_contig_depths \
		--outputDepth /work/output/$(METABAT_SUB_VER)/depth.txt \
		$(METABAT_BAMS)
	$(_end_touch)
mb_depth: $(METABAT_DEPTH_DONE)

# run metabat
METABAT_DONE?=$(METABAT_WORK_DIR)/.done_main
$(METABAT_DONE): $(METABAT_DEPTH_DONE) $(METABAT_DCKR_PROFILE_DONE)
	$(_start)
	rm -rf $(METABAT_WORK_DIR)/result
	$(METABAT_DOCKER) \
	metabat2 \
		-i /work/contigs.fa \
		-a /work/output/$(METABAT_SUB_VER)/depth.txt \
		-o /work/output/$(METABAT_SUB_VER)/result/bin \
		-s $(METABAT_MIN_BIN_SIZE) \
		-m $(METABAT_MIN_CONTIG_SIZE) \
		-t $(METABAT_THREADS) \
		--seed $(METABAT_SEED)
	$(_end_touch)
mb_main: $(METABAT_DONE)
