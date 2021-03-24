#####################################################################################################
# extract segments per bin
#####################################################################################################

NLV_BIN_SEGMENTS_DONE?=$(NLV_BIN_DIR)/.done_bin_segment
$(NLV_BIN_SEGMENTS_DONE):
	$(call _start,$(NLV_BIN_DIR))
	$(_R) R/nlv_bins.r generage.bin.segments \
		ifn.contigs=$(NLV_INPUT_CONTIG_TABLE) \
		ifn.bins=$(NLV_INPUT_BIN_TABLE) \
		ifn.c2b=$(NLV_INPUT_CONTIG2BIN) \
		bin.field=$(NLV_BIN_FIELD) \
		bin.value=$(NLV_BIN_VALUE) \
		margin=$(NLV_BIN_MARGIN) \
		ofn.segments=$(NLV_BIN_SEGMENTS) \
		ofn.bins=$(NLV_BIN_BASE)
	$(_end_touch)
nlv_bin_segments: $(NLV_BIN_SEGMENTS_DONE)

#####################################################################################################
# bin-level median coverage
#####################################################################################################

# Generate bin coverage using nlv for all libsets
NLV_BIN_COVERAGE_DONE?=$(NLV_BIN_COVERAGE_DIR)/.done_bin_coverage
$(NLV_BIN_COVERAGE_DONE):
	$(call _start,$(NLV_BIN_COVERAGE_DIR))
	$(NLV_BIN) coverage \
		-ifn_nlv $(NLV_SET_DS) \
		-ifn_segments $(NLV_BIN_SEGMENTS) \
		-summary_field bin \
		-ofn $(NLV_BIN_COVERAGE)
	$(_end_touch)
nlv_bin_cov: $(NLV_BIN_COVERAGE_DONE)

NLV_BIN_COV_SETS_DONE?=$(NLV_BIN_DIR)/.done_bin_coverage
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

NLV_BIN_SEGREGATE_DONE?=$(NLV_SEGREGATE_DIR)/.done_segregate_bin
$(NLV_BIN_SEGREGATE_DONE):
	$(_start)
	perl $(_md)/pl/assign_sites_to_bins.pl \
		$(NLV_BIN_SEGMENTS) \
		$(NLV_SEGREGATE_TABLE) \
		$(NLV_BIN_SEGREGATE_SITES)
#	$(_R) R/nlv_bins.r segregate.filter \
#		ifn=$(NLV_BIN_SEGREGATE_SITES_BASE) \
#		ifn.cov=$(NLV_BIN_COVERAGE) \
#		min.p=$(NLV_COV_MIN_P) \
#		max.p=$(NLV_COV_MAX_P) \
#		ofn=$(NLV_BIN_SEGREGATE_SITES)
	$(_R) R/nlv_bins.r bins.site.summary \
		ifn.sites=$(NLV_BIN_SEGREGATE_SITES) \
		ifn.bins=$(NLV_BIN_BASE) \
		ofn=$(NLV_BIN_SEGREGATE_TABLE)
	$(_end_touch)
nlv_bin_segregate: $(NLV_BIN_SEGREGATE_DONE)

NLV_BIN_SEGREGATE_SETS_DONE?=$(NLV_SEGREGATE_BASE_DIR)/.done_segregate_bins
$(NLV_BIN_SEGREGATE_SETS_DONE): $(NLV_BIN_SEGMENTS_DONE) $(NLV_SEGREGATE_SETS_DONE)
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
NLV_BIN_DIVERGE_DONE?=$(NLV_DIVERGE_DIR)/.done_diverge_bin
$(NLV_BIN_DIVERGE_DONE):
	$(_start)
	perl $(_md)/pl/assign_sites_to_bins.pl \
		$(NLV_BIN_SEGMENTS) \
		$(NLV_DIVERGE_TABLE) \
		$(NLV_BIN_DIVERGE_SITES)
#	$(_R) R/nlv_bins.r diverge.filter \
#		ifn=$(NLV_BIN_DIVERGE_SITES_BASE) \
#		min.major.freq=$(NLV_DIVERGE_MAJOR_MIN_FREQUENCY) \
#		max.p=$(NLV_COV_MAX_P) \
#		ifn.cov1=$(NLV_BIN_COVERAGE1) \
#		ifn.cov2=$(NLV_BIN_COVERAGE2) \
#		max.p=$(NLV_DIVERGE_P_VALUE) \
#		min.p=$(NLV_COV_MIN_P) \
#		ofn=$(NLV_BIN_DIVERGE_SITES)
	$(_R) R/nlv_bins.r bins.site.summary \
		ifn.sites=$(NLV_BIN_DIVERGE_SITES) \
		ifn.bins=$(NLV_BIN_BASE) \
		ofn=$(NLV_BIN_DIVERGE_TABLE)
	$(_end_touch)
nlv_bin_diverge: $(NLV_BIN_DIVERGE_DONE)

NLV_BIN_DIVERGE_SETS_DONE?=$(NLV_DIVERGE_BASE_DIR)/.done_diverge_bins
$(NLV_BIN_DIVERGE_SETS_DONE): $(NLV_BIN_SEGMENTS_DONE) $(NLV_DIVERGE_SETS_DONE)
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

NLV_BIN_SETS_DONE?=$(NLV_BIN_DIR)/.done_bin_sets
$(NLV_BIN_SETS_DONE): $(NLV_BIN_SEGREGATE_SETS_DONE) $(NLV_BIN_DIVERGE_SETS_DONE) $(NLV_BIN_COV_SETS_DONE)
	$(_start)
	$(_R) R/nlv_collect.r collect.data \
		ifn=$(NLV_SET_DEFS) \
		idir=$(NLV_SET_BASEDIR) \
		ofn.sets=$(NLV_BIN_SET_SUMMARY) \
		ofn.set.pairs=$(NLV_BIN_SET_PAIR_SUMMARY) \
		ofn.segregating.sites=$(NLV_SEGREGATE_SITES) \
		ofn.diverge.sites=$(NLV_DIVERGE_SITES)
	$(_end_touch)
nlv_bins_collect: $(NLV_BIN_SETS_DONE)

NLV_MERGE_SITES_DONE?=$(NLV_BIN_DIR)/.done_merge_sites_bins
$(NLV_MERGE_SITES_DONE): $(NLV_BIN_SETS_DONE)
	$(_start)
	$(_R) R/nlv_collect.r merge.sites \
		ifn.segregating.sites=$(NLV_SEGREGATE_SITES) \
		ifn.diverge.sites=$(NLV_DIVERGE_SITES) \
		ofn.sites=$(NLV_COMBINED_SITES) \
		ofn.bins=$(NLV_COMBINED_SITES_BINS)
	$(_end_touch)
nlv_merge_sites: $(NLV_MERGE_SITES_DONE)

#####################################################################################################
# compute distance matrix
#####################################################################################################

NLV_DISTANCE_DONE?=$(NLV_BIN_DIR)/.done_distance
$(NLV_DISTANCE_DONE): $(NLV_BIN_DIVERGE_SETS_DONE)
	$(_start)
	$(_R) R/nlv_distance.r distance.matrix \
		ifn.bins=$(NLV_BIN_BASE) \
		ifn.sets=$(NLV_SET_DEFS) \
		p.value=$(NLV_DIVERGE_P_VALUE) \
		idir=$(NLV_SET_BASEDIR) \
		ofn=$(NLV_DISTANCE_MATRIX)
	$(_end_touch)
nlv_dist: $(NLV_DISTANCE_DONE)

# main rule
nlv_bins: $(NLV_BIN_SEGREGATE_SETS_DONE) $(NLV_BIN_DIVERGE_SETS_DONE) $(NLV_BIN_COV_SETS_DONE) $(NLV_MERGE_SITES_DONE) $(NLV_DISTANCE_DONE)

