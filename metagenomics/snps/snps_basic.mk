#########################################################################################################
# create 1-bp vari profiles
#########################################################################################################

snps_vari_lib:
	@$(MAKE) m=map map_basic
	@$(MAKE) m=vari vari vari_compress

SNPS_VARI_DONE?=$(SNPS_DIR)/.done_vari
$(SNPS_VARI_DONE):
	$(call _start,$(SNPS_DIR))
	@$(foreach ID,$(SNPS_IDS),$(MAKE) LIB_ID=$(ID) snps_vari_lib; $(ASSERT);)
	$(_end_touch)
snps_vari: $(SNPS_VARI_DONE)

snps_map_clean:
	@$(foreach ID,$(SNPS_IDS),$(MAKE) LIB_ID=$(ID) m=map map_clean; $(ASSERT);)

#########################################################################################################
# merge snp over libs
#########################################################################################################

# base table
SNPS_BASE_DONE?=$(SNPS_DIR)/.done_base
$(SNPS_BASE_DONE): $(SNPS_VARI_DONE)
	$(call _start,$(SNPS_DIR))
	perl $(_md)/pl/combine_snp_tables.pl \
		$(SNPS_INPUT_CONTIG_TABLE) \
		$(SNPS_VARI_BASE_DIR) \
		$(SNPS_BASE_TABLE) \
		$(SNPS_BASE_IDS)
	$(_end_touch)
snps_base: $(SNPS_BASE_DONE)

# set table
SNPS_SET_DONE?=$(SNPS_SET_DIR)/.done_set
$(SNPS_SET_DONE):
	$(call _start,$(SNPS_SET_DIR))
	perl $(_md)/pl/combine_snp_tables.pl \
		$(SNPS_INPUT_CONTIG_TABLE) \
		$(SNPS_VARI_BASE_DIR) \
		$(SNPS_SET_TABLE) \
		$(SNPS_SET_IDS)
	$(_end_touch)
snps_set: $(SNPS_SET_DONE)

#########################################################################################################
# merge coverage over libs
#########################################################################################################

SNPS_BASE_COV_DONE?=$(SNPS_DIR)/.done_base_cov
$(SNPS_BASE_COV_DONE):
	$(call _start,$(SNPS_COVER_BASE_DIR))
	perl $(_md)/pl/combine_cov_vectors.pl \
		$(SNPS_VARI_BASE_DIR) \
		$(SNPS_INPUT_CONTIG_TABLE) \
		$(SNPS_COVER_BASE_DIR) \
		$(SNPS_BASE_IDS)
	$(_end_touch)
snps_base_cov: $(SNPS_BASE_COV_DONE)

SNPS_SET_COV_DONE?=$(SNPS_DIR)/.done_set_cov
$(SNPS_SET_COV_DONE):
	$(call _start,$(SNPS_COVER_SET_DIR))
	perl $(_md)/pl/combine_cov_vectors.pl \
		$(SNPS_VARI_BASE_DIR) \
		$(SNPS_INPUT_CONTIG_TABLE) \
		$(SNPS_COVER_SET_DIR) \
		$(SNPS_SET_IDS)
	$(_end_touch)
snps_set_cov: $(SNPS_SET_COV_DONE)

#########################################################################################################
# merge conditions into a single snp table
#########################################################################################################

# merge base and set
SNPS_MERGE_DONE?=$(SNPS_SET_DIR)/.done_merge
$(SNPS_MERGE_DONE): $(SNPS_BASE_DONE) $(SNPS_SET_DONE) $(SNPS_BASE_COV_DONE) $(SNPS_SET_COV_DONE)
	$(_start)
	perl $(_md)/pl/snp_merge.pl \
		$(SNPS_INPUT_CONTIG_TABLE) \
		$(SNPS_BASE_TABLE) \
		$(SNPS_COVER_BASE_DIR) \
		$(SNPS_SET_TABLE) \
		$(SNPS_COVER_SET_DIR) \
		$(SNPS_MERGE_TABLE)
	$(_end_touch)
snps_merge: $(SNPS_MERGE_DONE)

#########################################################################################################
# identify diverged and segragating positions
#########################################################################################################

# classify table
SNPS_CLASSIFY_DONE?=$(SNPS_SET_DIR)/.done_classify
$(SNPS_CLASSIFY_DONE): $(SNPS_MERGE_DONE)
	$(_start)
	perl $(_md)/pl/snp_classify.pl \
		$(SNPS_MERGE_TABLE) \
		$(SNPS_MIN_FIX_COUNT) \
		$(SNPS_FIX_THRESHOLD) \
		$(SNPS_MIN_POLY_COUNT) \
		$(SNPS_POLY_THRESHOLD) \
		$(SNPS_CLASSIFIED_TABLE)
	$(_end_touch)
snps_classify: $(SNPS_CLASSIFY_DONE)

snps_basic: $(SNPS_CLASSIFY_DONE)
