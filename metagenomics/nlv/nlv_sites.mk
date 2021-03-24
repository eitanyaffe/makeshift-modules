#####################################################################################################
# extract dynamic sites
#####################################################################################################

NLV_SITES_DONE?=$(NLV_SET_BASEDIR)/.done_sites
$(NLV_SITES_DONE): $(NLV_TABLE_DONE)
	$(call _start,$(NLV_SET_BASEDIR))
	$(NLV_BIN) sites \
		-ifn $(NLV_LIB_TABLE) \
		-min_var_count $(NLV_SITES_MIN_VAR_COUNT) \
		-min_total_count $(NLV_SITES_MIN_TOTAL_COUNT) \
		-min_sample_count $(NLV_SITES_MIN_SAMPLES) \
		-pvalue_threshold $(NLV_SITES_P_VALUE) \
		-ofn $(NLV_SITES)
	$(_end_touch)
nlv_extract_sites: $(NLV_SITES_DONE)

#####################################################################################################
# 1D: segregation per set
#####################################################################################################

NLV_SEGREGATE_DONE?=$(NLV_SEGREGATE_DIR)/.done_segregate
$(NLV_SEGREGATE_DONE): $(NLV_SITES_DONE)
	$(call _start,$(NLV_SEGREGATE_DIR))
	$(NLV_BIN) segregation \
		-ifn $(NLV_SITES) \
		-nlv $(NLV_SET_DS) \
		-min_cov $(NLV_SEGREGATE_MIN_COVERAGE) \
		-max_freq $(NLV_SEGREGATE_MAX_FREQUENCY) \
		-ofn $(NLV_SEGREGATE_TABLE)
	$(_end_touch)
nlv_segregate: $(NLV_SEGREGATE_DONE)

NLV_SEGREGATE_SETS_DONE?=$(NLV_SEGREGATE_BASE_DIR)/.done_segregate_all
$(NLV_SEGREGATE_SETS_DONE): $(NLV_SETS_DONE) $(NLV_SITES_DONE)
	$(_start)
	$(_Rcall) $(CURDIR) $(_md)/R/nlv_sets.r make.sets \
		ifn=$(NLV_SET_DEFS) \
		module=$(m) \
		target=nlv_segregate \
		is.dry=$(DRY)
	$(_end_touch)
nlv_segregate_sets: $(NLV_SEGREGATE_SETS_DONE)

#####################################################################################################
# 2D: pairwise compare sets
#####################################################################################################

NLV_DIVERGE_DONE?=$(NLV_DIVERGE_DIR)/.done
$(NLV_DIVERGE_DONE): $(NLV_SITES_DONE)
	$(call _start,$(NLV_DIVERGE_DIR))
	$(NLV_BIN) diverge \
		-ifn $(NLV_SITES) \
		-nlv1 $(NLV_SET_DS1) \
		-nlv2 $(NLV_SET_DS2) \
		-yates_correct $(NLV_DIVERGE_YATES_CORRECT) \
		-ofn $(NLV_DIVERGE_TABLE)
	$(_end_touch)
nlv_diverge: $(NLV_DIVERGE_DONE)

NLV_DIVERGE_SETS_DONE?=$(NLV_DIVERGE_BASE_DIR)/.done_diverge_all
$(NLV_DIVERGE_SETS_DONE): $(NLV_SETS_DONE) $(NLV_SITES_DONE)
	$(_start)
	$(_Rcall) $(CURDIR) $(_md)/R/nlv_sets.r make.set.pairs \
		ifn=$(NLV_SET_DEFS) \
		module=$(m) \
		target=nlv_diverge \
		is.dry=$(DRY)
	$(_end_touch)
nlv_diverge_sets: $(NLV_DIVERGE_SETS_DONE)

nlv_sites: nlv_diverge_sets nlv_segregate_sets
