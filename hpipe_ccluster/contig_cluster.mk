#######################################################################################
# select the large and abundant contigs
#######################################################################################

CONTIG_MATRIX_SELECTED_DONE?=$(CONTIG_MATRIX_DIR)/.done_select_contigs
$(CONTIG_MATRIX_SELECTED_DONE): $(CONTIG_MATRIX_STATS_DONE)
	$(call _start,$(CONTIG_MATRIX_DIR))
		perl $(_md)/pl/contig_matrix_select.pl \
		$(CONTIG_TABLE) \
		$(CONTIG_MATRIX) \
		$(CCLUSTER_MIN_LENGTH) \
		$(CCLUSTER_MIN_COVERAGE) \
		$(CONTIG_MATRIX_SELECTED)
	$(_end_touch)
cmatrix_select: $(CONTIG_MATRIX_SELECTED_DONE)

#######################################################################################
# filter out of contact matrix to reduce total neighbor size
#######################################################################################

CONTIG_MATRIX_FILTER_TABLE_DONE?=$(CONTIG_MATRIX_DIR)/.done_filter_threshold
$(CONTIG_MATRIX_FILTER_TABLE_DONE): $(CONTIG_MATRIX_SELECTED_DONE)
	$(_start)
	$(_R) R/filter_cmatrix.r compute.score.threshold \
		ifn.mat=$(CONTIG_MATRIX_SELECTED) \
		ifn.contigs=$(CONTIG_TABLE) \
		mb.threshold=$(CONTIG_MATRIX_MAX_MB) \
		ofn.table=$(CONTIG_MATRIX_NEIGHBOR_MB) \
		ofn.threshold=$(CONTIG_MATRIX_FILTER_SCORE_THRESHOLD)
	$(_end_touch)
cmatrix_filter_table: $(CONTIG_MATRIX_FILTER_TABLE_DONE)

CONTIG_MATRIX_FILTERED_DONE?=$(CONTIG_MATRIX_DIR)/.done_filter
$(CONTIG_MATRIX_FILTERED_DONE): $(CONTIG_MATRIX_FILTER_TABLE_DONE)
	$(_start)
	$(_R) R/filter_cmatrix.r filter.matrix \
		ifn.contigs=$(CONTIG_TABLE) \
		ifn.mat=$(CONTIG_MATRIX_SELECTED) \
		ifn.threshold=$(CONTIG_MATRIX_FILTER_SCORE_THRESHOLD) \
		ofn.mat=$(CONTIG_MATRIX_FILTERED) \
		ofn.contigs=$(CONTIG_TABLE_FILTERED) \
		ofn.stats=$(CONTIG_MATRIX_FILTER_STATS)
	$(_end_touch)
cmatrix_filter: $(CONTIG_MATRIX_FILTERED_DONE)

plot_filter_threshold:
	$(_R) R/filter_cmatrix.r plot.score.threshold \
		ifn.table=$(CONTIG_MATRIX_NEIGHBOR_MB) \
		ifn.threshold=$(CONTIG_MATRIX_FILTER_SCORE_THRESHOLD) \
		fdir=$(CCLUSTER_FIGURE_DIR)/filter

plot_filter_scatter:
	$(_R) R/filter_cmatrix.r plot.filter.scatter \
		ifn.mat=$(CONTIG_MATRIX_SELECTED) \
		ifn.threshold=$(CONTIG_MATRIX_FILTER_SCORE_THRESHOLD) \
		fdir=$(CCLUSTER_FIGURE_DIR)/filter
cmatrix_filter: $(CONTIG_MATRIX_FILTERED_DONE)

##########################################################################################
# seed clustering
##########################################################################################

#CCLUSTER=$(_md)/bin/ccluster
#CASSIGN=$(_md)/bin/assign_clusters
#CMETRIC=$(_md)/bin/metric

CCLUSTER_BIN?=$(_md)/bin.$(_binary_suffix)/ccluster
CASSIGN_BIN?=$(_md)/bin.$(_binary_suffix)/assign_clusters
CMETRIC_BIN?=$(_md)/bin.$(_binary_suffix)/metric
CEXPLODE_BIN?=$(_md)/bin.$(_binary_suffix)/explode_contig_matrix

CCLUSTER_DONE?=$(CCLUSTER_DIR)/.done_ccluster
$(CCLUSTER_DONE): $(CONTIG_MATRIX_FILTERED_DONE)
	$(call _start,$(CCLUSTER_DIR))
	$(call _time,$(CCLUSTER_DIR)) \
		$(CCLUSTER_BIN) \
		    -contigs $(CONTIG_TABLE_FILTERED) \
	            -contacts $(CONTIG_MATRIX_FILTERED) \
	            -max_contig_pairs $(CCLUSTER_MAX_CONTIG_PAIRS) \
	            -min_score $(CCLUSTER_MIN_SCORE) \
	            -score_type $(CCLUSTER_SCORE_TYPE) \
		    -cluster_normalize $(CCLUSTER_NORMALIZE_SIZE) \
	            -out_contigs $(CCLUSTER_CONTIGS) \
	            -out_tree $(CCLUSTER_TREE) \
	            -out_scores $(CCLUSTER_SCORES)
	$(_end_touch)
ccluster: $(CCLUSTER_DONE)

##########################################################################################
# assign initial clusters
##########################################################################################

CASSIGN_DONE?=$(CELL_DIR)/.done
$(CASSIGN_DONE): $(CCLUSTER_DONE)
	$(call _start,$(CELL_DIR))
	$(CASSIGN_BIN) \
		-contigs $(CCLUSTER_CONTIGS) \
	        -tree $(CCLUSTER_TREE) \
	        -min_score $(CCLUSTER_CUTOFF) \
	        -min_elements $(CCLUSTER_MIN_ELEMENTS) \
	        -min_length $(CCLUSTER_MIN_CLUSTER_NT) \
	        -out_contigs $(INITIAL_ANCHOR_TABLE)
	$(_end_touch)
cassign: $(CASSIGN_DONE)

make_ianchors: $(CASSIGN_DONE)
	@echo "DONE contig clustering, INITIAL_ANCHOR_TABLE=$(INITIAL_ANCHOR_TABLE)"


##########################################################################################
# plotting
##########################################################################################

plot_seed_anchors:
	$(_R) R/plot_ccluster.r plot.basic \
		ifn=$(INITIAL_ANCHOR_TABLE) \
		ifn.contigs=$(CONTIG_TABLE) \
		fdir=$(CCLUSTER_FIGURE_DIR)/cluster_sizes

plot_marginals: $(CONTIG_MATRIX_FILTERED)
	$(_start)
	$(_R) R/ccluster.r plot.marginals \
		contigs.ifn=$(CONTIG_TABLE) \
		contacts.ifn=$(CONTIG_MATRIX_FILTERED) \
		threshold=$(CCLUSTER_MIN_COVERAGE) \
		fdir=$(CCLUSTER_FIGURE_DIR)/marginals
	$(_end)

plot_gene_graph: $(INITIAL_ANCHOR_TABLE)
	$(_start)
	$(_R) R/ccluster.r plot.complete.graph \
		contigs.ifn=$(CONTIG_TABLE) \
		contacts.ifn=$(CONTIG_MATRIX_FILTERED) \
		fdir=$(CCLUSTER_FIGURE_DIR)/graph \
		anchor.ifn=$(INITIAL_ANCHOR_TABLE) \
		known.ifn=$(CLASSIFY_CONTIG_TABLE)
	$(_end)

plot_cluster_tree: $(INITIAL_ANCHOR_TABLE)
	$(_start)
	$(_R) R/ccluster.r plot.cluster.tree \
		contigs.ifn=$(CCLUSTER_CONTIGS) \
		cluster.table.ifn=$(INITIAL_ANCHOR_TABLE) \
		tree.ifn=$(CCLUSTER_TREE) \
		fdir=$(CCLUSTER_FIGURE_DIR)/tree
	$(_end)

plot_ccluster_matrix:
	$(_Rcall) $(PVIEW_DIR) batch/ccluster.r plot.ccluster \
		ifn=$(EXPORT_TABLE) \
		fdir=$(CCLUSTER_FIGURE_DIR)/matrix

ccluster_init: $(CCLUSTER_BIN) $(CASSIGN_BIN) $(CMETRIC_BIN) $(CEXPLODE_BIN)

iplots: make_plot_contig_matrix \
	plot_filter_threshold plot_filter_scatter \
	plot_seed_anchors \
	plot_cluster_tree \
	plot_gene_graph \
	plot_marginals

iplots_short: \
	plot_seed_anchors \
	plot_cluster_tree \
	plot_gene_graph \
	plot_marginals
