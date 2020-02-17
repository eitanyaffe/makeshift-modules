#####################################################################################################
# extract segments per bin
#####################################################################################################

NLV_BIN_SEGMENTS_DONE?=$(NLV_DIR)/.done_bin_segment
$(NLV_BIN_SEGMENTS_DONE):
	$(_start)
	$(_R) R/nlv_bins.r generage.bin.segments \
		ifn.contigs=$(NLV_INPUT_CONTIG_TABLE) \
		ifn.bins=$(NLV_INPUT_BIN_TABLE) \
		ifn.c2b=$(NLV_INPUT_CONTIG2BIN) \
		margin=$(NLV_BIN_MARGIN) \
		ofn.segments=$(NLV_BIN_SEGMENTS) \
		ofn.bins=$(NLV_BIN_BASE)
	$(_end_touch)
nlv_bin_segments: $(NLV_BIN_SEGMENTS_DONE)

#####################################################################################################
# bin-level median coverage
#####################################################################################################

# Generate bin coverage using nlv for all libsets
NLV_BIN_COVERAGE_DONE?=$(NLV_SET_DIR)/.done_bin_coverage
$(NLV_BIN_COVERAGE_DONE):
	$(_start)
	$(NLV_BIN) coverage \
		-ifn_nlv $(NLV_SET_DS) \
		-ifn_segments $(NLV_BIN_SEGMENTS) \
		-summary_field bin \
		-ofn $(NLV_BIN_COVERAGE)
	$(_end_touch)
nlv_bin_cov: $(NLV_BIN_COVERAGE_DONE)

NLV_BIN_COV_SETS_DONE?=$(NLV_SET_BASEDIR)/.done_bin_coverage
$(NLV_BIN_COV_SETS_DONE): $(NLV_BIN_SEGMENTS_DONE) $(NLV_SETS_DONE)
	$(_start)
	$(_Rcall) $(CURDIR) $(_md)/R/nlv_sets.r make.sets \
		ifn=$(NLV_SET_DEFS) \
		module=$(m) \
		target=nlv_bin_cov \
		is.dry=$(DRY)
	$(_end_touch)
nlv_bin_cov_sets: $(NLV_BIN_COV_SETS_DONE)

#####################################################################################################
# bin segregation
#####################################################################################################

NLV_BIN_SEGREGATE_DONE?=$(NLV_SET_DIR)/.done_segregate_bin_v2
$(NLV_BIN_SEGREGATE_DONE):
	$(_start)
	perl $(_md)/pl/assign_sites_to_bins.pl \
		$(NLV_BIN_SEGMENTS) \
		$(NLV_SEGREGATE_TABLE_MASKED) \
		$(NLV_BIN_SEGREGATE_SITES_BASE)
	$(_R) R/nlv_bins.r segregate.filter \
		ifn=$(NLV_BIN_SEGREGATE_SITES_BASE) \
		ifn.cov=$(NLV_BIN_COVERAGE) \
		min.p=$(NLV_COV_MIN_P) \
		max.p=$(NLV_COV_MAX_P) \
		ofn=$(NLV_BIN_SEGREGATE_SITES)
	$(_R) R/nlv_bins.r bins.site.summary \
		ifn.sites=$(NLV_BIN_SEGREGATE_SITES) \
		ifn.bins=$(NLV_BIN_BASE) \
		ofn=$(NLV_BIN_SEGREGATE_TABLE)
	$(_end_touch)
nlv_bin_segregate: $(NLV_BIN_SEGREGATE_DONE)

NLV_BIN_SEGREGATE_SETS_DONE?=$(NLV_SET_BASEDIR)/.done_segregate_bins_v2
$(NLV_BIN_SEGREGATE_SETS_DONE): $(NLV_BIN_SEGMENTS_DONE) $(NLV_SEGREGATE_SETS_DONE) $(NLV_BIN_COV_SETS_DONE)
	$(_start)
	$(_Rcall) $(CURDIR) $(_md)/R/nlv_sets.r make.sets \
		ifn=$(NLV_SET_DEFS) \
		module=$(m) \
		target=nlv_bin_segregate \
		is.dry=$(DRY)
	$(_end_touch)
nlv_bin_segregate_sets: $(NLV_BIN_SEGREGATE_SETS_DONE)

#####################################################################################################
# pairwise bin divergence
#####################################################################################################

# divergent SNPs per bin for libset pair
NLV_BIN_DIVERGE_DONE?=$(NLV_DIVERGE_DIR)/.done_diverge_bin_v2
$(NLV_BIN_DIVERGE_DONE):
	$(_start)
	perl $(_md)/pl/assign_sites_to_bins.pl \
		$(NLV_BIN_SEGMENTS) \
		$(NLV_DIVERGE_TABLE_MASKED) \
		$(NLV_BIN_DIVERGE_SITES_BASE)
	$(_R) R/nlv_bins.r diverge.filter \
		ifn=$(NLV_BIN_DIVERGE_SITES_BASE) \
		min.freq=$(NLV_DIVERGENCE_MAJOR_MIN_FREQUENCY) \
		ifn.cov1=$(NLV_BIN_COVERAGE1) \
		ifn.cov2=$(NLV_BIN_COVERAGE2) \
		min.p=$(NLV_COV_MIN_P) \
		max.p=$(NLV_COV_MAX_P) \
		ofn=$(NLV_BIN_DIVERGE_SITES)
	$(_R) R/nlv_bins.r bins.site.summary \
		ifn.sites=$(NLV_BIN_DIVERGE_SITES) \
		ifn.bins=$(NLV_BIN_BASE) \
		ofn=$(NLV_BIN_DIVERGE_TABLE)
	$(_end_touch)
nlv_bin_diverge: $(NLV_BIN_DIVERGE_DONE)

NLV_BIN_DIVERGE_SETS_DONE?=$(NLV_SET_BASEDIR)/.done_diverge_bins_v2
$(NLV_BIN_DIVERGE_SETS_DONE): $(NLV_BIN_SEGMENTS_DONE) $(NLV_DIVERGE_SETS_DONE) $(NLV_BIN_COV_SETS_DONE)
	$(_start)
	$(_Rcall) $(CURDIR) $(_md)/R/nlv_sets.r make.set.pairs \
		ifn=$(NLV_SET_DEFS) \
		module=$(m) \
		target=nlv_bin_diverge \
		is.dry=$(DRY)
	$(_end_touch)
nlv_bin_diverge_sets: $(NLV_BIN_DIVERGE_SETS_DONE)

#####################################################################################################
# collect data across lib sets
#####################################################################################################

NLV_BIN_SETS_DONE?=$(NLV_SET_BASEDIR)/.done_bin_sets
$(NLV_BIN_SETS_DONE): $(NLV_BIN_SEGREGATE_SETS_DONE) $(NLV_BIN_DIVERGE_SETS_DONE) $(NLV_BIN_COV_SETS_DONE)
	$(_start)
	$(_R) R/nlv_sets.r collect.data \
		ifn=$(NLV_SET_DEFS) \
		idir=$(NLV_SET_BASEDIR) \
		ofn.sets=$(NLV_BIN_SET_SUMMARY) \
		ofn.set.pairs=$(NLV_BIN_SET_PAIR_SUMMARY) \
		ofn.segregating.sites=$(NLV_SEGREGATE_SITES) \
		ofn.diverge.sites=$(NLV_DIVERGE_SITES)
	$(_end_touch)
nlv_bins_collect: $(NLV_BIN_SETS_DONE)

# main rule
nlv_bins: $(NLV_BIN_SEGREGATE_SETS_DONE) $(NLV_BIN_DIVERGE_SETS_DONE) $(NLV_BIN_COV_SETS_DONE) $(NLV_BIN_SETS_DONE)

