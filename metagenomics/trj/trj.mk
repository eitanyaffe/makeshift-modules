################################################################################
# libs
################################################################################

trj_lib:
	@$(MAKE) m=map coverage

ifeq ($(TRJ_IDS),)
$(error TRJ_IDS is not set)
endif

TRJ_LIB_DONE?=$(TRJ_DIR)/.done_libs
$(TRJ_LIB_DONE):
	$(call _start,$(TRJ_DIR))
	@$(foreach ID,$(TRJ_IDS),$(MAKE) LIB_ID=$(ID) trj_lib; $(ASSERT);)
	$(_end_touch)
trj_libs: $(TRJ_LIB_DONE)

################################################################################
# contig summary
################################################################################

# contig coverage matrix
TRJ_CONTIG_DONE?=$(TRJ_DIR)/.done_contigs
$(TRJ_CONTIG_DONE): $(TRJ_LIB_DONE)
	$(call _start,$(TRJ_DIR))
	$(_R) R/trj_contigs.r compute.contig.trj \
		ifn=$(TRJ_CONTIG_TABLE) \
		min.detected=$(TRJ_CONTIG_OBSERVED_MIN_DETECTED) \
		map.dir=$(TRJ_BASEMAP_DIR) \
		ids=$(TRJ_IDS) \
		ofn.observed=$(TRJ_CONTIG_OBSERVED) \
		ofn.expected=$(TRJ_CONTIG_EXPECTED) \
		ofn.norm=$(TRJ_CONTIG_NORM) \
		ofn.min.score=$(TRJ_CONTIG_NORM_DETECTION)
	$(_end_touch)
trj_contigs: $(TRJ_CONTIG_DONE)

################################################################################
# bin summary
################################################################################

# get host bins
TRJ_HOSTS_DONE?=$(TRJ_DIR)/.done_hosts
$(TRJ_HOSTS_DONE):
	$(call _start,$(TRJ_DIR))
	$(_R) R/trj_bins.r get.hosts \
		ifn=$(TRJ_BIN_TABLE_INPUT) \
		ofn=$(TRJ_BIN_TABLE)
	$(_end_touch)
trj_hosts: $(TRJ_HOSTS_DONE)

TRJ_PATTERN_DONE?=$(TRJ_DIR)/.done_pattern
$(TRJ_PATTERN_DONE): $(TRJ_CONTIG_DONE) $(TRJ_HOSTS_DONE)
	$(_start)
	$(_R) R/trj_bins.r bin.trj \
		ifn.bins=$(TRJ_BIN_TABLE) \
		ifn.c2b=$(TRJ_CONTIG_BIN) \
		ifn.norm=$(TRJ_CONTIG_NORM) \
		ifn.obs=$(TRJ_CONTIG_OBSERVED) \
		ifn.exp=$(TRJ_CONTIG_EXPECTED) \
		ofn.obs=$(TRJ_PATTERN_OBS) \
		ofn.exp=$(TRJ_PATTERN_EXP) \
		ofn.mean=$(TRJ_PATTERN_MEAN) \
		ofn.median=$(TRJ_PATTERN_MEDIAN) \
		ofn.top100=$(TRJ_PATTERN_TOP100) \
		ofn.bottom0=$(TRJ_PATTERN_BOTTOM0) \
		ofn.top95=$(TRJ_PATTERN_TOP95) \
		ofn.bottom05=$(TRJ_PATTERN_BOTTOM05) \
		ofn.top75=$(TRJ_PATTERN_TOP75) \
		ofn.bottom25=$(TRJ_PATTERN_BOTTOM25) \
		ofn.sd=$(TRJ_PATTERN_SD)
	$(_end_touch)
trj_pattern: $(TRJ_PATTERN_DONE)

TRJ_BIN_ORDER_DONE?=$(TRJ_DIR)/.done_host_cluster
$(TRJ_BIN_ORDER_DONE): $(TRJ_PATTERN_DONE)
	$(_start)
	$(_R) R/trj_bin_order.r bin.order \
		ifn.bins=$(TRJ_BIN_TABLE) \
		ifn.median=$(TRJ_PATTERN_MEDIAN) \
		ifn.detection=$(TRJ_CONTIG_NORM_DETECTION) \
		type=$(TRJ_CLASS_TYPE) \
		class.count=$(TRJ_N_CLASSES) \
		max.height=$(TRJ_CLASS_MAX_HEIGHT) \
		base.ids=$(TRJ_BASE_IDS) \
		ofn=$(TRJ_BIN_ORDER)
	$(_end_touch)
trj_bin_order: $(TRJ_BIN_ORDER_DONE)

trj_all: $(TRJ_BIN_ORDER_DONE)
