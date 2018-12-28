
# import Nielsen data
CATALOG_DONE=$(CATALOG_DIR)/.done
$(CATALOG_DONE):
	$(call _start,$(CATALOG_DIR))
	perl $(_md)/pl/import_nielsen.pl \
		$(CATALOG_INPUT_GENES) \
		$(CATALOG_INPUT_FILES) \
		$(OMIT_MGS) \
		$(CATALOG_FASTA) \
		$(CATALOG_GENE_TABLE)
	$(_end_touch)
cag_base: $(CATALOG_DONE)

NT2AA_DONE=$(CATALOG_DIR)/.done_nt2aa
$(NT2AA_DONE): $(CATALOG_DONE)
	$(_start)
	$(TRANSEQ) -sequence $(CATALOG_FASTA) -outseq $(CATALOG_FASTA_AA) -clean
	sed -i 's/_1$$//g' $(CATALOG_FASTA_AA)
	$(_end_touch)
cag_init: $(NT2AA_DONE)

# add kcube prevalance data and dependency
SUMMARY_DONE=$(CATALOG_DIR)/.done_summary
$(SUMMARY_DONE): $(CATALOG_DONE)
	$(_start)
	$(_R) $(_md)/R/cag_summary.r cag.summary \
		ifn.genes=$(CATALOG_GENE_TABLE)	 \
		ifn.kcube.summary=$(CUBE_ITEM_TABLE) \
		ifn.depend=$(CATALOG_INPUT_DEPEND_TABLE) \
		ofn=$(CAG_SUMMARY)
	$(_end_touch)
cag_summary: $(SUMMARY_DONE)

SELECT_DONE=$(CAG_SELECTION_DIR)/.done_select
$(SELECT_DONE): $(SUMMARY_DONE)
	$(call _start,$(CAG_SELECTION_DIR))
	$(_R) $(_md)/R/cag_summary.r cag.select \
		ifn=$(CAG_SUMMARY) \
		min.fraction=$(CAG_MIN_FRACTION) \
		min.xcov=$(CAG_MIN_XCOV) \
		min.identity=$(CAG_MIN_IDENTITY) \
		force.cags=$(CAG_SELECTION_FORCE) \
		ofn=$(CAG_SUMMARY_SELECT)
	$(_end_touch)
cag_select: $(SELECT_DONE)

GENES_DONE=$(CAG_SELECTION_DIR)/.done_genes
$(GENES_DONE): $(SELECT_DONE)
	$(_start)
	$(_R) $(_md)/R/cag_summary.r cag.genes \
		ifn=$(CAG_SUMMARY_SELECT) \
		ifn.genes=$(CATALOG_GENE_TABLE)	 \
		ifn.uniref=$(UNIREF_GENE_TAX_TABLE) \
		ofn=$(CAG_SUMMARY_SELECT_GENES)
	$(_end_touch)
cag_genes: $(GENES_DONE)

GENES_FASTA_DONE=$(CAG_SELECTION_DIR)/.done_genes_fasta
$(GENES_FASTA_DONE): $(GENES_DONE)
	$(_start)
	perl $(_md)/pl/select_items.pl \
		$(CAG_SUMMARY_SELECT_GENES) \
		gene \
		$(CATALOG_FASTA) \
		$(CAG_SUMMARY_SELECT_GENES_FASTA)
	$(_end_touch)
cag_genes_fasta: $(GENES_FASTA_DONE)

cag_basic: $(GENES_FASTA_DONE)

CATALOG_TAXA_DONE=$(CATALOG_TAXA_DIR)/.done
$(CATALOG_TAXA_DONE):
	$(call _start,$(CATALOG_TAXA_DIR))
	$(_R) $(_md)/R/cag_taxa.r cag.taxa \
		ifn.genes=$(CATALOG_GENE_TABLE) \
		ifn.taxa=$(UNIREF_GENE_TAX_TABLE) \
		ofn=$(CATALOG_TAXA)
	$(_end_touch)
cag_taxa: $(CATALOG_TAXA_DONE)

