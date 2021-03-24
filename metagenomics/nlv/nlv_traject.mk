#####################################################################################################
# extract data for all sites
#####################################################################################################

NLV_TRJ_DONE?=$(NLV_TRJ_DIR)/.done_trj
$(NLV_TRJ_DONE):
	$(call _start,$(NLV_TRJ_DIR))
	$(NLV_BIN) query \
		-nlv $(NLV_SET_DS) \
		-table $(NLV_TRJ_INPUT) \
		-field $(NLV_TRJ_FIELD) \
		-ofn $(NLV_TRJ_SITES)
	$(_end_touch)
nlv_trj_single: $(NLV_TRJ_DONE)

NLV_TRJ_SETS_DONE?=$(NLV_TRJ_BASE_DIR)/.done_all
$(NLV_TRJ_SETS_DONE): $(NLV_MERGE_SITES_DONE)
	$(_start)
	$(_Rcall) $(CURDIR) $(_md)/R/nlv_sets.r make.sets \
		ifn=$(NLV_SET_DEFS) \
		module=$(m) \
		target=nlv_trj_single \
		is.dry=$(DRY)
	$(_end_touch)
nlv_trj_all: $(NLV_TRJ_SETS_DONE)

#####################################################################################################
# combine to a single table
#####################################################################################################

NLV_TRJ_MAT_DONE?=$(NLV_TRJ_BASE_DIR)/.done_mat
$(NLV_TRJ_MAT_DONE): $(NLV_TRJ_SETS_DONE)
	$(_start)
	$(_R) R/nlv_collect.r collect.trajectory \
		ifn.libs=$(NLV_SET_DEFS) \
		ifn.sites=$(NLV_TRJ_INPUT) \
		field=$(NLV_TRJ_FIELD) \
		tag=sites \
		idir=$(NLV_TRJ_BASE_DIR) \
		ofn.count=$(NLV_TRJ_MAT_COUNT) \
		ofn.total=$(NLV_TRJ_MAT_TOTAL)
	$(_end_touch)
nlv_trj_matrix: $(NLV_TRJ_MAT_DONE)

NLV_TRJ_BINS_DONE?=$(NLV_TRJ_BASE_DIR)/.done_bins
$(NLV_TRJ_BINS_DONE): $(NLV_TRJ_MAT_DONE)
	$(_start)
	perl $(_md)/pl/assign_sites_to_bins.pl \
		$(NLV_BIN_SEGMENTS) \
		$(NLV_TRJ_MAT_COUNT) \
		$(NLV_TRJ_MAT_COUNT_BINS)
	perl $(_md)/pl/assign_sites_to_bins.pl \
		$(NLV_BIN_SEGMENTS) \
		$(NLV_TRJ_MAT_TOTAL) \
		$(NLV_TRJ_MAT_TOTAL_BINS)
	$(_end_touch)
nlv_trj_bins: $(NLV_TRJ_BINS_DONE)

nlv_trj: $(NLV_TRJ_BINS_DONE)
