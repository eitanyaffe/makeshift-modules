##############################################################################
# input
##############################################################################

# anchor genes
CHECKM_ANCHOR_GENES_DONE?=$(CHECKM_DIR)/.done_anchor_genes
$(CHECKM_ANCHOR_GENES_DONE):
	$(call _start,$(CHECKM_ANCHOR_GENE_DIR))
	$(_md)/pl/get_anchor_genes.pl \
		$(GENE_FASTA_AA) \
		$(CONTIG_TABLE) \
		$(GENE_TABLE) \
		$(CA_ANCHOR_CONTIGS) \
		$(CHECKM_TYPE) \
		$(CHECKM_GENE_GAP) \
		$(CHECKM_BINS)
	$(_end_touch)
checkm_bins_genes: $(CHECKM_ANCHOR_GENES_DONE)

##############################################################################
# output
##############################################################################

# tree/lineage/analyze
CHECKM_DONE?=$(CHECKM_DIR)/.done_main
$(CHECKM_DONE): $(CHECKM_ANCHOR_GENES_DONE)
	$(_start)
	rm -rf $(CHECKM_OUTPUT)
ifeq ($(CHECKM_STYLE),lineage)
	$(CHECKM) tree -x $(CHECKM_EXT) -t $(CHECKM_THREADS) --pplacer_threads $(CHECKM_PPLACER_THREADS) -g $(CHECKM_BINS) $(CHECKM_OUTPUT)
	$(CHECKM) lineage_set $(CHECKM_OUTPUT) $(CHECKM_MARKER_SET)
else
	$(CHECKM) taxon_set $(CHECKM_RANK) $(CHECKM_TAXON) $(CHECKM_MARKER_SET)
endif
	$(CHECKM) analyze -x $(CHECKM_EXT) -t $(CHECKM_THREADS) -g $(CHECKM_MARKER_SET) $(CHECKM_BINS) $(CHECKM_OUTPUT)
	$(_end_touch)
checkm_main: $(CHECKM_DONE)

# qa tree
CHECKM_QA_TREE_DONE?=$(CHECKM_DIR)/.done_qa_tree
$(CHECKM_QA_TREE_DONE): $(CHECKM_DONE)
	$(_start)
	$(CHECKM) tree_qa --tab_table -f $(CHECKM_TREE_QA) $(CHECKM_OUTPUT)
	$(_end_touch)
checkm_qa_tree: $(CHECKM_QA_TREE_DONE)

# qa
CHECKM_QA_DONE?=$(CHECKM_DIR)/.done_qa_$(CHECKM_QA_TYPE)
$(CHECKM_QA_DONE): $(CHECKM_DONE)
	$(_start)
	$(CHECKM) qa -o $(CHECKM_QA_TYPE) --tab_table -f $(CHECKM_QA) -a $(CHECKM_MULTI_FILE) --aai_strain $(CHECKM_AAI) $(CHECKM_MARKER_SET) $(CHECKM_OUTPUT)
	$(_end_touch)
checkm_qa: $(CHECKM_QA_DONE)

# CHECKM_SELECT_DONE?=$(CHECKM_DIR)/.done_selected_$(CHECKM_QA_TYPE)
# $(CHECKM_SELECT_DONE): $(CHECKM_QA_DONE)
# 	$(_start)
# 	$(_R) R/checkm.r select.anchors \
# 		ifn.qa=$(CHECKM_QA_PREFIX).1 \
# 		ifn.ga=$(CA_ANCHOR_GENES_BASE) \
# 		ifn.ca=$(CA_ANCHOR_CONTIGS_BASE) \
# 		min.complete=$(CHECKM_MIN_COMPLETE) \
# 		max.contam=$(CHECKM_MAX_CONTAM) \
# 		ofn.anchors=$(CHECKM_ANCHORS) \
# 		ofn.ga=$(CA_ANCHOR_GENES_SELECTED) \
# 		ofn.ca=$(CA_ANCHOR_CONTIGS_SELECTED)
# 	$(_end_touch)
# checkm_select: $(CHECKM_SELECT_DONE)

make_checkm: $(CHECKM_QA_DONE)

##############################################################################
# plot
##############################################################################

checkm_plot:
	$(_R) R/checkm_plot.r plot.analysis \
		ifn.qa=$(CHECKM_QA_PREFIX).1 \
		ifn.ca=$(CA_ANCHOR_CONTIGS) \
		ifn.contigs=$(CONTIG_TABLE) \
		ifn.info=$(ANCHOR_INFO_TABLE) \
		type=$(CHECKM_TYPE) \
		min.complete=$(CHECKM_MIN_COMPLETE) \
		max.contam=$(CHECKM_MAX_CONTAM) \
		fdir=$(CHECKM_FDIR)

checkm_simple_plot:
	$(_R) R/checkm_plot.r plot.analysis.simple \
		ifn.qa=$(CHECKM_QA_PREFIX).1 \
		min.complete=$(CHECKM_MIN_COMPLETE) \
		max.contam=$(CHECKM_MAX_CONTAM) \
		fdir=$(CHECKM_FDIR)

make_checkm_plots: checkm_plot
