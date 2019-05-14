
############################################################################
# select anchors
############################################################################

CR_SELECT_ANCHORS_DONE?=$(CR_DIR)/.done_select_anchors
$(CR_SELECT_ANCHORS_DONE):
	$(_start)
	$(_R) R/cr_anchor_select.r select.anchors \
		ifn=$(CR_ANCHORS_TABLE_IN) \
		field=$(CR_ANCHORS_FIELD_IN) \
		values=$(CR_ANCHORS_VALUES_IN) \
		ofn=$(CR_ANCHORS_SELECTED)
	$(_end_touch)
cr_anchor_select: $(CR_SELECT_ANCHORS_DONE)

####################################################################################
# segments for cores and elements
####################################################################################

CR_CORE_SEGMENTS_DONE?=$(CR_DIR)/.done_core_segments
$(CR_CORE_SEGMENTS_DONE):
	$(call _start,$(CR_DIR))
	perl $(_md)/pl/geneset_segments.pl \
		$(GENE_TABLE) \
		$(CR_IN_SC_CORE_GENES) anchor \
		$(CR_CORE_SEGMENTS_BASE)
	$(_end_touch)
core_segments: $(CR_CORE_SEGMENTS_DONE)

CR_ELEMENT_SEGMENTS_DONE?=$(CR_DIR)/.done_element_segments
$(CR_ELEMENT_SEGMENTS_DONE):
	$(call _start,$(CR_DIR))
	perl $(_md)/pl/geneset_segments.pl \
		$(GENE_TABLE) \
		$(CR_IN_SC_GENE_ELEMENT) element.id \
		$(CR_ELEMENT_SEGMENTS_BASE)
	$(_end_touch)
element_segments: $(CR_ELEMENT_SEGMENTS_DONE)

CR_ANCHOR_SEGMENTS_DONE?=$(CR_DIR)/.done_anchor_segments
$(CR_ANCHOR_SEGMENTS_DONE):
	$(call _start,$(CR_DIR))
	$(_R) R/segments.r anchor.segments \
		ifn.anchor.order=$(ANCHOR_CLUSTER_TABLE) \
		ifn.ca=$(CA_ANCHOR_CONTIGS) \
		ifn.contigs=$(CONTIG_TABLE) \
		ifn.genes=$(GENE_TABLE) \
		ofn=$(CR_ANCHOR_SEGMENTS_BASE)
	$(_end_touch)
anchor_segments: $(CR_ANCHOR_SEGMENTS_DONE)

# merge segments
CR_MERGE_SEGMENTS_DONE?=$(CR_DIR)/.done_segments
$(CR_MERGE_SEGMENTS_DONE): $(CR_ELEMENT_SEGMENTS_DONE) $(CR_CORE_SEGMENTS_DONE) $(CR_ANCHOR_SEGMENTS_DONE)
	$(_start)
	$(_R) R/segments.r merge.segments \
		ifn.anchor.order=$(ANCHOR_CLUSTER_TABLE) \
		ifn.cores=$(CR_CORE_SEGMENTS_BASE) \
		ifn.elements=$(CR_ELEMENT_SEGMENTS_BASE) \
		ifn.anchors=$(CR_ANCHOR_SEGMENTS_BASE) \
		ofn=$(CR_SEGMENTS_BASE)
	$(_end_touch)
cr_segments: $(CR_MERGE_SEGMENTS_DONE)

CR_BIN_DONE?=$(CR_DIR)/.done_bin
$(CR_BIN_DONE): $(CR_MERGE_SEGMENTS_DONE)
	$(_start)
	$(_R) R/segments.r bin.segments \
		ifn.segments=$(CR_SEGMENTS_BASE) \
		ifn.contigs=$(CONTIG_TABLE) \
		binsize=$(CR_BINSIZE) \
		min.binsize=$(CR_MIN_BIN_SIZE) \
		min.segment.size=$(CR_MIN_SEGMENT_SIZE) \
		read.length=$(CR_READ_LENGTH) \
		ofn.segments=$(CR_SEGMENTS) \
		ofn.bins=$(CR_BINS)
	$(_end_touch)
cr_bins: $(CR_BIN_DONE)

CR_SETS_DONE?=$(CR_DIR)/.done_sets
$(CR_SETS_DONE): $(CR_BIN_DONE)
	$(_start)
	$(_R) R/segments.r segment.summary \
		ifn=$(CR_SEGMENTS) \
		ofn=$(CR_SETS)
	$(_end_touch)
cr_sets: $(CR_SETS_DONE)

####################################################################################
# count bin counts for library
####################################################################################

CR_BIN_READS_DONE?=$(CR_LIB_DIR)/.done
$(CR_BIN_READS_DONE):
	$(call _start,$(CR_LIB_DIR))
	$(_md)/pl/cr_bin_reads.pl \
		$(CR_BINS) \
		$(FILTER_DIR) \
		$(CR_LIB_TABLE) \
		$(CR_LIB_STATS)
	$(_end_touch)
cr_lib: $(CR_BIN_READS_DONE)

####################################################################################
# matrix
####################################################################################

# cr matrix
CR_MATRIX_DONE?=$(CR_DIR)/.done_matrix
$(CR_MATRIX_DONE):
	$(_start)
	$(_R) R/cr_matrix.r compute.matrix \
		ifn=$(CR_BINS) \
		min.detected=$(CR_MIN_DETECTED) \
		cr.dir=$(CR_DIR) \
		ids=$(CR_DATASETS) \
		ofn.total=$(CR_TOTAL) \
		ofn.observed=$(CR_OBSERVED) \
		ofn.expected=$(CR_EXPECTED) \
		ofn.norm=$(CR_NORM) \
		ofn.min.score=$(CR_NORM_DETECTION)
	$(_end_touch)
cr_matrix: $(CR_MATRIX_DONE)

# mean profiles
CR_PROFILE_DONE?=$(CR_DIR)/.done_profile
$(CR_PROFILE_DONE): $(CR_MATRIX_DONE)
	$(_start)
	$(_R) R/cr_profile.r compute.profile \
		ifn.bins=$(CR_BINS) \
		ifn.norm=$(CR_NORM) \
		ifn.obs=$(CR_OBSERVED) \
		ifn.exp=$(CR_EXPECTED) \
		ofn.obs=$(CR_PATTERN_OBS) \
		ofn.exp=$(CR_PATTERN_EXP) \
		ofn.mean=$(CR_PATTERN_MEAN) \
		ofn.median=$(CR_PATTERN_MEDIAN) \
		ofn.top100=$(CR_PATTERN_TOP100) \
		ofn.bottom0=$(CR_PATTERN_BOTTOM0) \
		ofn.top95=$(CR_PATTERN_TOP95) \
		ofn.bottom05=$(CR_PATTERN_BOTTOM05) \
		ofn.top75=$(CR_PATTERN_TOP75) \
		ofn.bottom25=$(CR_PATTERN_BOTTOM25) \
		ofn.sd=$(CR_PATTERN_SD)
	$(_end_touch)
cr_profiles: $(CR_PROFILE_DONE)

############################################################################
# select consistent elements
############################################################################

CR_BIN_COR_DONE?=$(CR_DIR)/.done_bin_cor
$(CR_BIN_COR_DONE): $(CR_MATRIX_DONE)
	$(_start)
	$(_R) R/cr_profile.r compute.bin.cor \
		ifn.bins=$(CR_BINS) \
		ifn.norm=$(CR_NORM) \
		ifn.median=$(CR_PATTERN_MEDIAN) \
		ofn=$(CR_BIN_DIST)
	$(_end_touch)
cr_bin_cor: $(CR_BIN_COR_DONE)

CR_SET_COR_DONE?=$(CR_DIR)/.done_set_cor
$(CR_SET_COR_DONE): $(CR_BIN_COR_DONE)
	$(_start)
	$(_R) R/cr_profile.r compute.set.cor \
		ifn=$(CR_BIN_DIST) \
		ofn=$(CR_SET_DIST)
	$(_end_touch)
cr_set_cor: $(CR_SET_COR_DONE)

############################################################################
# anchor order
############################################################################

CR_ANCHOR_ORDER_DONE?=$(CR_DIR)/.done_anchor_order
$(CR_ANCHOR_ORDER_DONE): $(CR_PROFILE_DONE)
	$(_start)
	$(_R) R/cr_anchor_order.r compute.anchor.order \
		ifn.segments=$(CR_SEGMENTS) \
		ifn.median=$(CR_PATTERN_MEDIAN) \
		ifn.detection=$(CR_NORM_DETECTION) \
		type=$(CR_CLASS_TYPE) \
		class.count=$(CR_N_CLASSES) \
		max.height=$(CR_CLASS_MAX_HEIGHT) \
		base.ids=$(CR_BASE_IDS) \
		ofn=$(CR_ANCHOR_ORDER)
	$(_end_touch)
cr_anchor_order: $(CR_ANCHOR_ORDER_DONE)

############################################################################

cr_base: $(CR_ANCHOR_ORDER_DONE) $(CR_SET_COR_DONE) $(CR_SELECT_ANCHORS_DONE)

