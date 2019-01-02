####################################################################
# background
####################################################################

GO_CTRL_DONE?=$(SC_GO_DIR)/.done_GO_ctrl
$(GO_CTRL_DONE):
	$(_start)
	$(_md)/pl/GO_append.pl \
		$(UNIREF_GENE_TAX_TABLE) \
		$(UNIREF_GENE_TAX_TABLE) \
		$(UNIREF_GENE_GO) \
		$(GO_TREE) \
		$(GO_TABLE_CTRL)
	$(_md)/pl/GO_analysis.pl \
		$(GO_TABLE_CTRL) \
		$(GO_MIN_AA_IDENTITY) \
		$(GO_TREE) \
		$(GO_SUMMARY_CTRL_PREFIX)
	$(_end_touch)
GO_ctrl: $(GO_CTRL_DONE)

####################################################################
# GO over selected genes
####################################################################

GO_DONE?=$(SC_GO_DIR)/.done_GO
$(GO_DONE):
	$(call _start,$(SC_GO_DIR))
	$(_md)/pl/GO_append.pl \
		$(GO_INPUT_GENES) \
		$(UNIREF_GENE_TAX_TABLE) \
		$(UNIREF_GENE_GO) \
		$(GO_TREE) \
		$(GO_TABLE)
	$(_md)/pl/GO_analysis.pl \
		$(GO_TABLE) \
		$(GO_MIN_AA_IDENTITY) \
		$(GO_TREE) \
		$(GO_SUMMARY_PREFIX)
	$(_end_touch)
GO_main: $(GO_DONE)

MERGE_GO_DONE?=$(SC_GO_DIR)/.done_merge_GO
$(MERGE_GO_DONE): $(GO_DONE) $(GO_CTRL_DONE)
	$(_start)
	$(_R) R/merge_GO.r merge.GO \
		ifn.genes=$(GO_INPUT_GENES) \
		ifn.genes.ctrl=$(UNIREF_GENE_TAX_TABLE) \
		ifn.prefix=$(GO_SUMMARY_PREFIX) \
		ifn.prefix.ctrl=$(GO_SUMMARY_CTRL_PREFIX) \
		ofn=$(GO_MERGE)
	$(_end_touch)
GO_merge: $(MERGE_GO_DONE)

GO_plot:
	$(_R) R/plot_gene_annotation.r plot.GO \
		ifn=$(GO_MERGE) \
		min.count=$(GO_MIN_COUNT) \
		fdir=$(TAXA_FDIR)/GO/gene_diagram
