#####################################################################################################
# cluster segments
#####################################################################################################

COV_CLUSTER_THREADS?=80
COV_CLUSTER_P_THRESHOLD?=0.01
COV_CLUSTER_SAMPLE_SIZE?=100
COV_CLUSTER_RANDOM_SEED?=1

COV_CLUSTER_MIN_LENGTH?=2000
COV_CLUSTER_ONLY_CENTER?=T
COV_CLUSTER_ADD_SHORT?=F
COV_CLUSTER_ADD_OUTLIERS?=F

# for debug
COV_CLUSTER_MAX_LIBS?=0

COV_SEGMENT_CLUSTER?=$(COV_ANALYSIS_DIR)/segments.cluster

COV_CLUSTER_DONE?=$(COV_ANALYSIS_DIR)/.done_cluster
$(COV_CLUSTER_DONE): $(COV_BREAK_DONE)
	$(_start)
	$(COV_BIN) bin \
		-ifn_libs $(COV_LIB_TABLE) \
		-ifn_segments $(COV_SEGMENT_TABLE) \
		-ofn $(COV_SEGMENT_CLUSTER) \
		-threads $(COV_CLUSTER_THREADS) \
		-p_value $(COV_CLUSTER_P_THRESHOLD) \
		-sample_size $(COV_CLUSTER_SAMPLE_SIZE) \
		-pseudo_count $(COV_PSEUDO_COUNT) \
		-random_seed $(COV_CLUSTER_RANDOM_SEED) \
		-min_segment_length $(COV_CLUSTER_MIN_LENGTH) \
		-only_center $(COV_CLUSTER_ONLY_CENTER) \
		-add_short $(COV_CLUSTER_ADD_SHORT) \
		-add_outliers $(COV_CLUSTER_ADD_OUTLIERS) \
		-max_lib_count $(COV_CLUSTER_MAX_LIBS)
#	$(_end_touch)
cov_cluster: $(COV_CLUSTER_DONE)
