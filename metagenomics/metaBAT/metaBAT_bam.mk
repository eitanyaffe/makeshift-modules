
METABAT_BAM_DONE?=$(METABAT_LIB_DIR)/.done_bam
$(METABAT_BAM_DONE):
	$(call _start,$(METABAT_LIB_DIR))
	cp $(METABAT_IN_BAM) $(METABAT_LIB_BAM)
	$(_end_touch)
mb_bam: $(METABAT_BAM_DONE)

METABAT_BAMS_DONE?=$(METABAT_DIR)/.done_bams
$(METABAT_BAMS_DONE):
	$(call _start,$(METABAT_DIR))
	@$(foreach ID,$(METABAT_IDS),$(MAKE) LIB_ID=$(ID) METABAT_ID=$(ID) mb_bam; $(ASSERT);)
	$(_end_touch)
mb_bams: $(METABAT_BAMS_DONE)
