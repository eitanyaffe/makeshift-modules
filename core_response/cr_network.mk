##########################################################################################
# compute Hi-C matrix between core/anchors and elements
##########################################################################################

# add anchors when no cores are available
CR_HIC_SEGMENTS_DONE?=$(CR_HIC_DIR)/.done_segments
$(CR_HIC_SEGMENTS_DONE):
	$(call _start,$(CR_HIC_DIR))
	$(_R) R/cr_hic.r make.segments \
		ifn=$(CR_SEGMENTS) \
		ofn=$(CR_HIC_SEGMENTS)
	$(_end_touch)
cr_hic_segments: $(CR_HIC_SEGMENTS_DONE)

# code ee_map.mk
CR_MAP_DONE?=$(CR_HIC_LIB_DIR)/.done_map
$(CR_MAP_DONE): $(CR_HIC_SEGMENTS_DONE)
	$(_start)
	$(MAKE) m=anchors ee_map \
		EE_MAP_DATASET=$(CR_HIC_LIB) \
		EE_MAP_IN_TABLE=$(CR_HIC_SEGMENTS) \
		EE_MAP_DIR=$(CR_EE_MAP_DIR) \
		EE_MAP_SCOPE=all \
		DATASET_ANCHOR_DIR=$(CR_DATASET_ANCHOR_DIR)
	$(_end_touch)
cr_hic_base: $(CR_MAP_DONE)

# count the number of fends per element
CR_SET_FENDS_DONE?=$(CR_HIC_LIB_DIR)/.done_set_fends
$(CR_SET_FENDS_DONE): $(CR_MAP_DONE)
	$(_start)
	$(_R) R/cr_hic.r set.fends \
		ifn.sets=$(CR_SETS) \
		ifn.fends=$(CR_HIC_FENDS) \
		ofn=$(CR_SET_FENDS)
	$(_end_touch)
cr_set_fends: $(CR_SET_FENDS_DONE)

# organize matrix
CR_MAP_CLASSIFY_DONE?=$(CR_HIC_LIB_DIR)/.done_matrix
$(CR_MAP_CLASSIFY_DONE): $(CR_SET_FENDS_DONE)
	$(_start)
	$(_R) R/cr_hic.r make.anchor.matrix \
		ifn.sets=$(CR_SET_FENDS) \
		ifn.mat=$(CR_HIC_MATRIX) \
		ifn.anchors=$(ANCHOR_CLUSTER_TABLE) \
		min.contacts=$(CR_NETWORK_MIN_CONTACTS) \
		min.enrichment=$(CR_NETWORK_MIN_ENRICHMENT) \
		separate.min.contacts=$(CR_NETWORK_SEPARATE_MIN_CONTACTS) \
		separate.max.enrichment=$(CR_NETWORK_SEPARATE_MAX_SCORE) \
		ofn=$(CR_ANCHOR_MATRIX)
	$(_end_touch)
cr_hic: $(CR_MAP_CLASSIFY_DONE)

################################################################################################
# compare
################################################################################################

# TBD

# A) Hi-C
# 1. start from from here, generate a comparison map
# 2. selected persistent anchors and elements. Elements should also be consistent
# 3. plot pre/post scatter per anchor

# B) Temporal
# 1. Different mk file
# 2. Only consistent elements
# 3. Detailed temporal profile of element vs hosts.
# 4. Overview matrix of single-hosted that deviate from host
# 5. Overview matrix of shared

CR_COMPARE_DONE?=$(CR_HIC_COMPARE_DIR)/.done_compare
$(CR_COMPARE_DONE):
	$(call _start,$(CR_HIC_COMPARE_DIR))
	$(_R) R/cr_network_compare.r network.compare \
		ifn.map1=$(CR_ANCHOR_MATRIX1) \
		ifn.map2=$(CR_ANCHOR_MATRIX2) \
		min.support=$(CR_MIN_FIT_SUPPORT) \
		ofn.anchors=$(CR_ANCHOR_TABLE_COMPARE) \
		ofn.map=$(CR_MAP_COMPARE)
	$(_end_touch)
cr_hic_compare: $(CR_COMPARE_DONE)

################################################################################################

# TBD: move this code away into the temporal component

# corelation between host and associated elements
CR_ANCHOR_ELEMENTS_DONE?=$(CR_HIC_LIB_DIR)/.done_anchor_elements
$(CR_ANCHOR_ELEMENTS_DONE): $(CR_MAP_CLASSIFY_DONE)
	$(_start)
	$(_R) R/cr_hic.r anchor.elements \
		ifn.anchor.order=$(ANCHOR_CLUSTER_TABLE) \
		ifn.matrix=$(CR_ANCHOR_MATRIX) \
		ifn.means=$(CR_PATTERN_MEAN) \
		ofn=$(CR_ANCHOR_ELEMENTS)
	$(_end_touch)
cr_elements: $(CR_ANCHOR_ELEMENTS_DONE)
