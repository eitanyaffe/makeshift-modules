###############################################################################################
# process metaBAT results
###############################################################################################

# extract bins from fasta
METABAT_RAW_TABLE_DONE?=$(METABAT_WORK_DIR)/.done_raw_table
$(METABAT_RAW_TABLE_DONE): $(METABAT_DONE)
	$(_start)
	perl $(_md)/pl/fasta2bins.pl \
		$(METABAT_WORK_DIR)/result \
		$(METABAT_TABLE_RAW)
	$(_end_touch)
mb_raw_table: $(METABAT_RAW_TABLE_DONE)

METABAT_RAW_BIN_TABLE_DONE?=$(METABAT_WORK_DIR)/.done_raw_bin_table
$(METABAT_RAW_BIN_TABLE_DONE): $(METABAT_RAW_TABLE_DONE)
	$(_start)
	$(_R) $(_md)/R/bin_summary.r bin.summary \
		ifn.cb=$(METABAT_TABLE_RAW) \
		ifn.contigs=$(METABAT_CONTIG_TABLE) \
		ofn=$(METABAT_BIN_TABLE_RAW)
	$(_end_touch)
mb_raw_bin_table: $(METABAT_RAW_BIN_TABLE_DONE)

###############################################################################################
# contig and bin centroids
###############################################################################################

METABAT_VECTORS_DONE?=$(METABAT_WORK_DIR)/.done_vectors
$(METABAT_VECTORS_DONE): $(METABAT_RAW_TABLE_DONE)
	$(_start)
	$(_R) $(_md)/R/mb_centroids.r compute.vectors \
		ifn.cb=$(METABAT_TABLE_RAW) \
		ifn.depth=$(METABAT_DEPTH_TABLE) \
		ids=$(METABAT_MERGE_IDS) \
		ofn=$(METABAT_CONTIG_VECTORS)
	$(_end_touch)
mb_vectors: $(METABAT_VECTORS_DONE)

METABAT_CENTROID_DONE?=$(METABAT_WORK_DIR)/.done_centroid
$(METABAT_CENTROID_DONE): $(METABAT_VECTORS_DONE)
	$(_start)
	$(_R) $(_md)/R/mb_centroids.r compute.centroids \
		ifn.cb=$(METABAT_TABLE_RAW) \
		ifn.vec=$(METABAT_CONTIG_VECTORS) \
		ofn=$(METABAT_CENTROID_VECTORS)
	$(_end_touch)
mb_centroid: $(METABAT_CENTROID_DONE)

#####################################################################################################
# filter out low quality contigs and bins
#####################################################################################################

METABAT_CONTIG_SCORES_DONE?=$(METABAT_WORK_DIR)/.done_contig_zscores
$(METABAT_CONTIG_SCORES_DONE): $(METABAT_CENTROID_DONE) $(METABAT_VECTORS_DONE)
	$(_start)
	$(_R) $(_md)/R/mb_centroids.r compute.contig.scores \
		ifn.cb=$(METABAT_TABLE_RAW) \
		ifn.vec=$(METABAT_CONTIG_VECTORS) \
		ifn.centroid=$(METABAT_CENTROID_VECTORS) \
		ofn=$(METABAT_CONTIG_SCORE)
	$(_end_touch)
mb_contig_scores: $(METABAT_CONTIG_SCORES_DONE)

METABAT_SELECT_DONE?=$(METABAT_WORK_DIR)/.done_select
$(METABAT_SELECT_DONE): $(METABAT_RAW_BIN_TABLE_DONE) $(METABAT_CONTIG_SCORES_DONE)
	$(_start)
	$(_R) $(_md)/R/mb_select.r select.contigs \
		ifn=$(METABAT_CONTIG_SCORE) \
		filter=$(METABAT_FILTER) \
		min.pearson=$(METABAT_MIN_SCORE) \
		min.zscore=$(METABAT_MIN_ZSCORE) \
		max.discard.fraction=$(METABAT_MAX_DISCARD_FRACTION) \
		ofn.contigs=$(METABAT_CONTIG_SELECTED) \
		ofn.bins=$(METABAT_BIN_SELECTED)
	$(_end_touch)
mb_select: $(METABAT_SELECT_DONE)

METABAT_DISCARD_DONE?=$(METABAT_WORK_DIR)/.done_discard
$(METABAT_DISCARD_DONE): $(METABAT_SELECT_DONE)
	$(_start)
	$(_R) $(_md)/R/mb_select.r discard.contigs \
		ifn=$(METABAT_CONTIG_SELECTED) \
		ofn=$(METABAT_TABLE)
	$(_end_touch)
mb_discard: $(METABAT_DISCARD_DONE)

METABAT_BIN_TABLE_DONE?=$(METABAT_WORK_DIR)/.done_bin_table
$(METABAT_BIN_TABLE_DONE): $(METABAT_DISCARD_DONE)
	$(_start)
	$(_R) $(_md)/R/bin_summary.r bin.summary \
		ifn.cb=$(METABAT_TABLE) \
		ifn.contigs=$(METABAT_CONTIG_TABLE) \
		ofn=$(METABAT_BIN_TABLE)
	$(_end_touch)
mb_post: $(METABAT_BIN_TABLE_DONE)

