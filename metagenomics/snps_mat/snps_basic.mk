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
# define lib sets
#########################################################################################################

SNPS_SET_DEFS_DONE?=$(SNPS_SET_BASEDIR)/.done_set_defs
$(SNPS_SET_DEFS_DONE):
	$(call _start,$(SNPS_SET_BASEDIR))
	$(_R) R/snps_set_table.r create.table \
		ifn=$(SNPS_LIB_TABLE) \
		lib.count=$(SNPS_SET_COUNT) \
		respect.keys=$(SNPS_RESPECT_KEYS) \
		ofn=$(SNPS_SET_DEFS)
	$(_end_touch)
snps_set_defs: $(SNPS_SET_DEFS_DONE)

#########################################################################################################
# combine libs into a lib set
#########################################################################################################

SNPS_SET_DONE?=$(SNPS_SET_DIR)/.done_set_snps
$(SNPS_SET_DONE):
	$(call _start,$(SNPS_SET_DIR))
	perl $(_md)/pl/combine_snp_tables.pl \
		$(SNPS_INPUT_CONTIG_TABLE) \
		$(SNPS_VARI_BASE_DIR) \
		$(SNPS_SET_TABLE) \
		$(SNPS_SET_IDS)
	$(_end_touch)
snps_combine_snps: $(SNPS_SET_DONE)

SNPS_SET_COV_DONE?=$(SNPS_SET_DIR)/.done_set_cov
$(SNPS_SET_COV_DONE):
	$(call _start,$(SNPS_COVER_SET_DIR))
	perl $(_md)/pl/combine_cov_vectors.pl \
		$(SNPS_VARI_BASE_DIR) \
		$(SNPS_INPUT_CONTIG_TABLE) \
		$(SNPS_COVER_SET_DIR) \
		$(SNPS_SET_IDS)
	$(_end_touch)
snps_combine_coverage: $(SNPS_SET_COV_DONE)

snps_set: $(SNPS_SET_DONE) $(SNPS_SET_COV_DONE)

# do all sets
SNPS_SETS_DONE?=$(SNPS_SET_BASEDIR)/.done_sets
$(SNPS_SETS_DONE): $(SNPS_SET_DEFS_DONE)
	$(call _start,$(SNPS_SET_BASEDIR))
	$(_Rcall) $(CURDIR) $(_md)/R/snps_set_table.r make.sets \
		ifn=$(SNPS_SET_DEFS) \
		module=$(m) \
		is.dry=$(DRY)
	$(_end_touch)
snps_sets: $(SNPS_SETS_DONE)

#########################################################################################################
# TBD compare two lib sets
#########################################################################################################

# merge base and set
SNPS_MERGE_DONE?=$(SNPS_SETCMP_DIR)/.done_merge
$(SNPS_MERGE_DONE):
	$(_start)
	perl $(_md)/pl/snp_merge.pl \
		$(SNPS_INPUT_CONTIG_TABLE) \
		$(SNPS_SET_TABLE1) \
		$(SNPS_COVER_SET_DIR1) \
		$(SNPS_SET_TABLE2) \
		$(SNPS_COVER_SET_DIR2) \
		$(SNPS_MERGE_TABLE)
	$(_end_touch)
snps_merge: $(SNPS_MERGE_DONE)

# compare set combinations

#########################################################################################################
# identify diverged and segragating positions
#########################################################################################################

# classify table
SNPS_CLASSIFY_DONE?=$(SNPS_SETCMP_DIR)/.done_classify
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
