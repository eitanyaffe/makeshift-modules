#####################################################################################################
# basic blast analysis
#####################################################################################################

FUNC_BLAST_DONE?=$(FUNC_SET_DIR)/.done_blast
$(FUNC_BLAST_DONE):
	$(call _start,$(FUNC_SET_DIR))
	$(_R) R/func_blast.r blast.analysis \
		title=$(FUNC_ID) \
		ifn.uniref=$(UNIREF_GENE_TAX_TABLE) \
		ifn.genes=$(FUNC_INPUT_GENES) \
		breaks=$(FUNC_BLAST_BREAKS) \
		ofn.summary=$(FUNC_BLAST_SUMMARY) \
		ofn.poor=$(FUNC_POOR_RATE)
	$(_end_touch)
func_blast: $(FUNC_BLAST_DONE)

# get gene fasta
FUNC_EXTRACT_DONE?=$(FUNC_SET_DIR)/.done_extract
$(FUNC_EXTRACT_DONE):
	$(_start)
	perl $(_md)/pl/extract_genes.pl \
		$(FUNC_INPUT_GENES) \
		$(FUNC_GENES_AA_BG) \
		$(FUNC_GENES_AA)
	$(_end_touch)
func_aa: $(FUNC_EXTRACT_DONE)

#####################################################################################################
# key words
#####################################################################################################

FUNC_GENE_WORDS_DONE?=$(FUNC_SET_DIR)/.done_gene_words
$(FUNC_GENE_WORDS_DONE):
	$(_start)
	perl $(_md)/pl/gene_word.pl \
		$(FUNC_INPUT_GENES) \
		$(UNIREF_GENE_TAX_TABLE) \
		prot_desc \
		$(FUNC_GENE_WORD_TABLE) \
		$(FUNC_GENE_WORD_BACKTABLE) \
		$(FUNC_GENE_WORD_WHOLE) \
		$(UNIREF_POOR_ANNOTATION)
	$(_end_touch)
func_words: $(FUNC_GENE_WORDS_DONE)

#####################################################################################################
# abx resistance
#####################################################################################################

# not used
FUNC_AMR_DONE?=$(FUNC_SET_DIR)/.done_amr
$(FUNC_AMR_DONE):
	$(call _start,$(FUNC_SET_DIR))
	$(_R) R/func_amr.r amr.enrichment \
		ifn.genes=$(FUNC_INPUT_GENES) \
		ifn.amr=$(RESFAMS_TABLE_SELECTED) \
		ofn=$(FUNC_AMR_TABLE)
	$(_end_touch)
func_amr: $(FUNC_AMR_DONE)

#####################################################################################################
# GO
#####################################################################################################

GO_BASE_DONE?=$(FUNC_SET_DIR)/.done_GO_base
$(GO_BASE_DONE):
	$(call _start,$(FUNC_SET_DIR))
	$(_md)/pl/GO_append.pl \
		$(FUNC_INPUT_GENES) \
		$(UNIREF_GENE_TAX_TABLE) \
		$(UNIREF_GENE_GO) \
		$(GO_TREE) \
		$(GO_TABLE)
	$(_end_touch)
GO_base: $(GO_BASE_DONE)

GO_DONE?=$(FUNC_SET_DIR)/.done_GO_main
$(GO_DONE): $(GO_BASE_DONE)
	$(_start)
	$(_md)/pl/GO_analysis.pl \
		$(GO_TABLE) \
		$(GENE_TABLE) \
		$(GO_MIN_AA_IDENTITY) \
		$(GO_TREE) \
		$(GO_SUMMARY_PREFIX)
	$(_end_touch)
GO: $(GO_DONE)

GO_MERGE_DONE?=$(FUNC_SET_DIR)/.done_GO_merged
$(GO_MERGE_DONE): $(GO_DONE)
	$(_start)
	$(_R) R/merge_GO.r merge.GO \
		ifn.genes=$(FUNC_INPUT_GENES) \
		ifn.genes.ctrl=$(FUNC_GENES_BG) \
		ifn.prefix=$(GO_SUMMARY_PREFIX) \
		ifn.prefix.ctrl=$(GO_PREFIX_BG) \
		ofn=$(GO_MERGE)
	$(_end_touch)
GO_merge: $(GO_MERGE_DONE)

GO_bg: $(GO_DONE) $(FUNC_BLAST_DONE)

#####################################################################################################
# append stats
#####################################################################################################

GO_STATS_DONE?=$(FUNC_SET_DIR)/.done_GO_stats
$(GO_STATS_DONE): $(GO_MERGE_DONE)
	$(_start)
	$(_md)/pl/GO_stats.pl \
		$(FUNC_INPUT_GENES) \
		$(GO_MERGE) \
		$(GO_TABLE) \
		$(GO_APPEND_ANCHOR) \
		$(GO_ELEMENT_ANCHOR) \
		"$(GO_STAT_FIELDS)" \
		$(GO_STATS)
	$(_end_touch)
GO_stats: $(GO_STATS_DONE)

GO_FINAL_DONE?=$(FUNC_SET_DIR)/.done_GO_final
$(GO_FINAL_DONE): $(GO_STATS_DONE)
	$(_start)
	$(_R) R/select_GO.r append.stats \
		ifn.merge=$(GO_MERGE) \
		ifn.stats=$(GO_STATS) \
		ofn=$(GO_FINAL)
	$(_end_touch)
GO_final: $(GO_FINAL_DONE)

#####################################################################################################
# select significant GOs
#####################################################################################################

GO_SELECT_DONE?=$(GO_SELECT_DIR)/.done_select
$(GO_SELECT_DONE): $(GO_FINAL_DONE)
	$(call _start,$(GO_SELECT_DIR))
	$(_R) R/select_GO.r select.GO \
		ifn=$(GO_FINAL) \
		min.gene.count=$(GO_MIN_GENE_COUNT) \
		min.enrichment=$(GO_MIN_ENRICHMENT) \
		min.ml.pvalue=$(GO_MIN_MINUS_LOG_PVALUE) \
		ofn=$(GO_SELECT)
	$(_end_touch)
GO_select: $(GO_SELECT_DONE)

#####################################################################################################
# reduce to leaves and explode genes
#####################################################################################################

GO_LEAVES_DONE?=$(GO_SELECT_DIR)/.done_leaves
$(GO_LEAVES_DONE): $(GO_SELECT_DONE)
	$(_start)
	$(_md)/pl/GO_leaves.pl \
		$(GO_SELECT) \
		$(GO_TREE) \
		$(GO_LEAVES)
	$(_end_touch)
GO_leaves: $(GO_LEAVES_DONE)

GO_GENES_DONE?=$(GO_SELECT_DIR)/.done_genes
$(GO_GENES_DONE): $(GO_LEAVES_DONE)
	$(_start)
	$(_md)/pl/GO_genes.pl \
		$(GO_TABLE) \
		$(GO_SELECT) \
		$(GO_GENES)
	$(_end_touch)
GO_genes: $(GO_GENES_DONE)

#####################################################################################################
# random samples for FDR
#####################################################################################################

GO_FDR_TABLES_DONE?=$(FUNC_SET_DIR)/.done_random_$(GO_FDR_PERMUTE_COUNT)
$(GO_FDR_TABLES_DONE):
	$(_start)
	$(_Rcall) $(CURDIR) $(_md)/R/FDR_GO.r FDR.GO.tables \
		ifn.genes.bg=$(FUNC_GENES_BG) \
		ifn.genes=$(FUNC_INPUT_GENES) \
		ea.ifn=$(GO_ELEMENT_ANCHOR) \
		count=$(GO_FDR_PERMUTE_COUNT) \
		dry=$(FUNC_DRY) \
		odir=$(GO_FDR_DIR)
	$(_end_touch)
GO_FDR_tables: $(GO_FDR_TABLES_DONE)

#####################################################################################################
# FDR q-values
#####################################################################################################

GO_FDR_QVALUE_DONE?=$(FUNC_SET_DIR)/.done_qvals_$(GO_FDR_PERMUTE_COUNT)
$(GO_FDR_QVALUE_DONE): $(GO_FDR_TABLES_DONE) $(GO_FINAL_DONE)
	$(_start)
	$(_R) R/FDR_GO.r FDR.qvalues \
		ifn=$(GO_FINAL) \
		idir=$(GO_FDR_DIR) \
		count=$(GO_FDR_PERMUTE_COUNT) \
		min.gene.count=$(GO_MIN_GENE_COUNT) \
		min.enrichment=$(GO_MIN_ENRICHMENT) \
		min.ml.pvalue=$(GO_MIN_MINUS_LOG_PVALUE) \
		ofn=$(GO_QVALS)
	$(_end_touch)
GO_qvalues: $(GO_FDR_QVALUE_DONE)

#####################################################################################################
# merge subjects
#####################################################################################################

func_GO_tables_subjects:
	$(_R) R/GO_tables.r GO.table.subjects \
		idir1=$(FUNC_DIR1) \
		idir2=$(FUNC_DIR2) \
		select.ver=$(GO_SELECT_VERSION) \
		ids=$(FUNC_IDS) \
		min.log.pvalue=$(GO_MIN_MINUS_LOG_PVALUE) \
		min.gene.count=$(GO_MIN_GENE_COUNT) \
		min.enrichment=$(GO_MIN_ENRICHMENT) \
		reduce.tree.script=$(_md)/pl/GO_leaves.pl \
		ifn.go.tree=$(GO_TREE) \
		rnd.count=$(GO_FDR_PERMUTE_COUNT) \
		odir=$(FUNC_COMPARE_DIR)
	mkdir -p $(FUNC_FDIR)/9_GO_tables_subjects
	cp -r $(FUNC_COMPARE_DIR)/* $(FUNC_FDIR)/9_GO_tables_subjects

#####################################################################################################
# run over multiple genesets
#####################################################################################################

GO_single: $(FUNC_BLAST_DONE) $(GO_GENES_DONE) $(FUNC_EXTRACT_DONE) $(GO_FDR_TABLES_DONE)

GO_test:
	@$(MAKE) GO_single FUNC_ID=acc FUNC_INPUT_GENES=$(FUNC_GENES_ACC)

GO_multi:
	@$(MAKE) GO_bg FUNC_ID=bg FUNC_INPUT_GENES=$(FUNC_GENES_BG)
	@$(MAKE) GO_single FUNC_ID=acc FUNC_INPUT_GENES=$(FUNC_GENES_ACC)
	@$(MAKE) GO_single FUNC_ID=free FUNC_INPUT_GENES=$(FUNC_GENES_FREE)
	@$(MAKE) GO_single FUNC_ID=depend FUNC_INPUT_GENES=$(FUNC_GENES_DEPEND)
	@$(MAKE) GO_single FUNC_ID=persist FUNC_INPUT_GENES=$(FUNC_GENES_PERSIST)
	@$(MAKE) GO_single FUNC_ID=turnover FUNC_INPUT_GENES=$(FUNC_GENES_TURNOVER)
#	@$(MAKE) GO_single FUNC_ID=single_simple FUNC_INPUT_GENES=$(FUNC_GENES_SINGLE_SIMPLE)
#	@$(MAKE) GO_single FUNC_ID=shared_simple FUNC_INPUT_GENES=$(FUNC_GENES_SHARED_SIMPLE)

GO_evolve:
	@$(MAKE) GO_single FUNC_ID=fix FUNC_INPUT_GENES=$(MKT_GENE_TABLE) GO_STAT_FIELDS=$(GO_STAT_FIX_FIELDS) GO_APPEND_ANCHOR=F
	@$(MAKE) GO_single FUNC_ID=hgt FUNC_INPUT_GENES=$(EVO_CORE_GENE_SELECT_10Y)

make_func: GO_multi GO_evolve

#####################################################################################################
# tests
#####################################################################################################

GO_bg:
	@$(MAKE) GO FUNC_ID=bg FUNC_INPUT_GENES=$(FUNC_GENES_BG)

GO_qtest:
	@$(MAKE) GO_single FUNC_ID=acc FUNC_INPUT_GENES=$(FUNC_GENES_ACC)
	@$(MAKE) GO_single FUNC_ID=fix FUNC_INPUT_GENES=$(MKT_GENE_TABLE) GO_STAT_FIELDS=$(GO_STAT_FIX_FIELDS) GO_APPEND_ANCHOR=F
	@$(MAKE) GO_single FUNC_ID=hgt FUNC_INPUT_GENES=$(EVO_CORE_GENE_SELECT_10Y)

func_words_all:
	@$(MAKE) func_words FUNC_ID=acc FUNC_INPUT_GENES=$(FUNC_GENES_ACC)
	@$(MAKE) func_words FUNC_ID=fix FUNC_INPUT_GENES=$(MKT_GENE_TABLE)
	@$(MAKE) func_words FUNC_ID=hgt FUNC_INPUT_GENES=$(EVO_CORE_GENE_SELECT_10Y)

#####################################################################################################
# merge subjects
#####################################################################################################

func_GO_tables_subjects_plots:
	$(_R) R/GO_tables.r GO.table.subjects.plots \
		ids=$(FUNC_IDS) \
		table.dir=$(FUNC_COMPARE_DIR) \
		fdir=$(FUNC_FDIR)/10_GO_subjects_plots

#####################################################################################################
# plotting
#####################################################################################################

func_blast_plot:
	$(_R) R/func_blast.r plot.blast \
		idir=$(FUNC_DIR) \
		func.blast.ver=$(FUNC_BLAST_VERSION) \
		ids=$(FUNC_IDS) \
		colors=$(FUNC_COLORS) \
		breaks=$(FUNC_BLAST_BREAKS) \
		fdir=$(FUNC_FDIR)/1_blast

func_GO_plot_single:
	$(_R) R/plot_gene_annotation.r plot.GO \
		ifn=$(GO_SELECT) \
		fdir=$(FUNC_FDIR)/2_GO/$(FUNC_ID)

func_GO_plot_compare_fate:
	$(_R) R/plot_GO_compare.r plot.GO.compare \
		idir=$(FUNC_DIR) \
		select.ver=$(GO_SELECT_VERSION) \
		ids="acc persist turnover" \
		colors="gray darkgreen orange" \
		fdir=$(FUNC_FDIR)/4_GO_compare_fate

func_GO_plot_compare_shared:
	$(_R) R/plot_GO_compare.r plot.GO.compare \
		idir=$(FUNC_DIR) \
		select.ver=$(GO_SELECT_VERSION) \
		ids="acc single_simple shared_simple" \
		colors="gray blue orange" \
		fdir=$(FUNC_FDIR)/5_GO_compare_shared

func_GO_plot_compare_pop:
	$(_R) R/plot_GO_compare.r plot.GO.compare \
		idir=$(FUNC_DIR) \
		select.ver=$(GO_SELECT_VERSION) \
		ids="acc depend free" \
		colors="gray red blue" \
		fdir=$(FUNC_FDIR)/6_GO_compare_pop

func_GO_plot_compare_selection:
	$(_R) R/plot_GO_compare.r plot.GO.compare \
		idir=$(FUNC_DIR) \
		select.ver=$(GO_SELECT_VERSION) \
		ids="acc fix hgt" \
		colors="gray darkgreen orange" \
		fdir=$(FUNC_FDIR)/7_GO_compare_selection

func_GO_tables:
	$(_R) R/GO_tables.r GO.tables \
		idir=$(FUNC_DIR) \
		select.ver=$(GO_SELECT_VERSION) \
		ids=$(FUNC_IDS) \
		odir=$(FUNC_FDIR)/8_GO_tables

# summary of anchor/element/gene tables
func_tables:
	mkdir -p $(ATABLE_DIR)
	$(_R) R/generate_tables.r gen.tables \
		taxa.ifn=$(SET_TAXA_REPS) \
		ref.ifn=$(SC_SUMMARY_UNIQUE) \
		cores.ifn=$(SC_CORE_TABLE) \
		evo.host.current.ifn=$(EVO_CORE_LIVE_CLASS_CURRENT) \
		evo.host.10y.ifn=$(EVO_CORE_FATE_CLASS_10Y) \
		evo.element.current.ifn=$(EVO_ELEMENT_LIVE_CLASS_CURRENT) \
		evo.element.10y.ifn=$(EVO_ELEMENT_FATE_CLASS_10Y) \
		evo.element.host.10y.ifn=$(EVO_ELEMENT_HOST_FATE_10Y) \
		pop.ifn=$(POP_ELEMENT_CLASSIFY) \
		ea.ifn=$(SC_ELEMENT_ANCHOR) \
		odir=$(ATABLE_DIR)
	cp $(SC_ELEMENT_GENE_TABLE) $(ATABLE_DIR)/genes.txt

func_compare: func_GO_plot_compare_fate func_GO_plot_compare_pop func_GO_plot_compare_selection
plot_func: func_blast_plot func_GO_plot_single func_compare func_tables func_GO_tables

##############################################################################
# volcano plots
##############################################################################

func_volcano_plot_subject:
	$(_R) R/plot_volcano.r plot.volcano \
		id=$(FUNC_ID) \
		idir=$(FUNC_DIR) \
		select.ver=$(GO_SELECT_VERSION) \
		compare.dir=$(FUNC_COMPARE_DIR) \
		min.enrichment=$(GO_MIN_ENRICHMENT) \
		min.ml.pvalue=$(GO_MIN_MINUS_LOG_PVALUE) \
		fdir=$(FUNC_FDIR)/3_volcano/$(SUBJECT)/$(FUNC_ID)
func_volcano_plot_single:
	@$(MAKE) func_volcano_plot_subject FUNC_DIR=$(FUNC_DIR1) SUBJECT=$(SUBJECT1)
	@$(MAKE) func_volcano_plot_subject FUNC_DIR=$(FUNC_DIR2) SUBJECT=$(SUBJECT2)
func_volcano_plot:
	@$(MAKE) func_volcano_plot_single FUNC_ID=acc
	@$(MAKE) func_volcano_plot_single FUNC_ID=fix
	@$(MAKE) func_volcano_plot_single FUNC_ID=hgt
	@$(MAKE) func_volcano_plot_single FUNC_ID=free
	@$(MAKE) func_volcano_plot_single FUNC_ID=depend

##############################################################################
# compare subjects
##############################################################################

func_compare_subjects:
	$(_R) R/plot_subjects.r plot.subject.pvals \
		ifn1=$(GO_FINAL1) \
		ifn2=$(GO_FINAL2) \
		ifn.select1=$(GO_SELECT1) \
		ifn.select2=$(GO_SELECT2) \
		fdir=$(FUNC_FDIR)/12_subjects/$(FUNC_ID)

##############################################################################
# word plot
##############################################################################

plot_gene_words:
	$(_R) R/plot_gene_annotation.r plot.words \
		ifn=$(FUNC_GENE_WORD_TABLE) \
		filter.words=$(FUNC_GENE_WORD_FILTER) \
		min.count=$(FUNC_GENE_WORD_MIN_COUNT) \
		fdir=$(FUNC_FDIR)/11_words/$(FUNC_ID)

