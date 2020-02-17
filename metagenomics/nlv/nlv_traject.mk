#####################################################################################################
# extract data for all divergent sites
#####################################################################################################

NLV_TRJ_DIVERGE_DONE?=$(NLV_SET_DIR)/.done_trj_diverge_sites
$(NLV_TRJ_DIVERGE_DONE): $(NLV_BIN_SETS_DONE) $(NLV_DIVERGE_SETS_DONE)
	$(_start)
	$(NLV_BIN) query \
		-nlv $(NLV_SET_DS) \
		-table $(NLV_DIVERGE_SITES) \
		-ofn $(NLV_TRJ_DIVERGE)
	$(_end_touch)
nlv_trj_diverge: $(NLV_TRJ_DIVERGE_DONE)

NLV_TRJ_DIVERGE_SETS_DONE?=$(NLV_SET_BASEDIR)/.done_trj_diverge_sites
$(NLV_TRJ_DIVERGE_SETS_DONE): $(NLV_BIN_SEGMENTS_DONE) $(NLV_SETS_DONE) $(NLV_DIVERGE_SETS_DONE)
	$(_start)
	$(_Rcall) $(CURDIR) $(_md)/R/nlv_sets.r make.sets \
		ifn=$(NLV_SET_DEFS) \
		module=$(m) \
		target=nlv_trj_diverge \
		is.dry=$(DRY)
	$(_end_touch)
nlv_trj_diverge_sets: $(NLV_TRJ_DIVERGE_SETS_DONE)

#####################################################################################################
# combine to a single table
#####################################################################################################

NLV_TRJ_DIVERGE_MAT_DONE?=$(NLV_SET_BASEDIR)/.done_trj_diverge_mat
$(NLV_TRJ_DIVERGE_MAT_DONE): $(NLV_TRJ_DIVERGE_SETS_DONE)
	$(_start)
	$(_R) R/nlv_sets.r collect.trajectory \
		ifn.libs=$(NLV_SET_DEFS) \
		ifn.sites=$(NLV_DIVERGE_SITES) \
		tag=trj_diverge \
		idir=$(NLV_SET_BASEDIR) \
		ofn.count=$(NLV_TRJ_DIVERGE_MAT_COUNT) \
		ofn.total=$(NLV_TRJ_DIVERGE_MAT_TOTAL)
	$(_end_touch)
nlv_trj_diverge_matrix: $(NLV_TRJ_DIVERGE_MAT_DONE)

nlv_trj: $(NLV_TRJ_DIVERGE_MAT_DONE)
