CARD_INIT?=$(CARD_DIR)/.done_init
$(CARD_INIT):
	$(call _start,$(CARD_DIR))
	$(RGI_COMMAND) rgi clean --local
	$(RGI_COMMAND) rgi load -i $(CARD_JSON) --local
	$(_end_touch)
card_init: $(CARD_INIT)

# !!! called twice due to rgi bug, see https://github.com/arpcard/rgi/issues/93
CARD_DONE?=$(CARD_DIR)/.done_main
$(CARD_DONE): $(CARD_INIT)
	$(call _start,$(CARD_DIR))
	-$(RGI_COMMAND) rgi main --include_loose --debug \
		--local -a DIAMOND \
		-n $(CARD_THREADS) \
		--input_sequence $(GENE_FASTA_AA) \
		--input_type protein \
		--output_file $(CARD_OUT_PREFIX)
	$(RGI_COMMAND) rgi main --include_loose --debug \
		--local -a DIAMOND \
		-n $(CARD_THREADS) \
		--input_sequence $(GENE_FASTA_AA) \
		--input_type protein \
		--output_file $(CARD_OUT_PREFIX)
	$(_end_touch)
card_main: $(CARD_DONE)

CARD_ABX_DONE?=$(CARD_DIR)/.done_abx_summary
$(CARD_ABX_DONE): $(CARD_DONE)
	$(_start)
	$(_R) R/card.r abx.table \
		ifn.card=$(CARD_TABLE) \
		ifn.aro=$(CARD_ARO_INDEX) \
		ofn.drug=$(CARD_DRUG_TABLE) \
		ofn.mech=$(CARD_MECH_TABLE) \
		ofn.amr=$(CARD_AMR_TABLE) \
		ofn.model=$(CARD_MODEL_TABLE)
	$(_end_touch)
card_abx: $(CARD_ABX_DONE)

make_card: card_main card_abx

#####################################################################################################
# summary over multiple subjects
#####################################################################################################

CARD_COLLECT_DONE?=$(CARD_COLLECT_DIR)/.done_collect
$(CARD_COLLECT_DONE):
	$(call _start,$(CARD_COLLECT_DIR))
	$(_R) R/card_collect.r card.collect \
		template.ifn=$(CARD_TABLE) \
		template.id="S2_003" \
		ids=$(COLLECT_IDS) \
		ofn=$(CARD_COLLECT_GENE_TABLE)
	$(_end_touch)
card_collect: $(CARD_COLLECT_DONE)

CARD_GENES_DONE?=$(CARD_COLLECT_DIR)/.done_genes
$(CARD_GENES_DONE): $(CARD_COLLECT_DONE)
	$(call _start,$(CARD_FASTA_DIR))
	$(_R) R/card_collect.r card.genes \
		ifn=$(CARD_COLLECT_GENE_TABLE) \
		template.ifn=$(PRODIGAL_NT) \
		template.id="S2_003" \
		ids=$(COLLECT_IDS) \
		ofn=$(CARD_COLLECT_ARO_TABLE) \
		odir=$(CARD_FASTA_DIR)
	$(_end_touch)
card_genes: $(CARD_GENES_DONE)

CDHIT_DONE?=$(CDHIT_DIR)/.done_cdhit
$(CDHIT_DONE): $(CARD_GENES_DONE)
	$(call _start,$(CDHIT_DIR))
	$(_R) R/card_collect.r run.cdhit \
		ifn=$(CARD_COLLECT_ARO_TABLE) \
		cdhit.bin=$(CDHIT_BIN) \
		identity=$(CDHIT_IDENTITY) \
		odir=$(CDHIT_DIR)
	$(_end_touch)
card_cdhit: $(CDHIT_DONE)

CDHIT_PARSE_DONE?=$(CDHIT_DIR)/.done_cdhit_parse_$(CDHIT_ARO)
$(CDHIT_PARSE_DONE):
	$(call _start)
	perl $(_md)/pl/parse_CARD.pl \
		$(CDHIT_ARO_CLUSTER_FILE) \
		$(CDHIT_ARO) \
		$(CDHIT_ARO_TABLE)
	$(_end_touch)
cdhit_parse: $(CDHIT_PARSE_DONE)

CDHIT_PARSE_ALL_DONE?=$(CDHIT_DIR)/.done_cdhit_parse_all
$(CDHIT_PARSE_ALL_DONE): $(CDHIT_DONE)
	$(_start)
	$(_Rcall) $(CURDIR) $(_md)/R/cdhit.r run.aro \
		ifn=$(CARD_COLLECT_ARO_TABLE) \
		module=$(m) \
		target=cdhit_parse \
		is.dry=$(DRY)
	$(_end_touch)
cdhit_parse_all: $(CDHIT_PARSE_ALL_DONE)

CDHIT_MERGE_DONE?=$(CDHIT_DIR)/.done_merge
$(CDHIT_MERGE_DONE): $(CDHIT_DONE)
	$(_start)
	$(_Rcall) $(CURDIR) $(_md)/R/cdhit.r merge.aro \
		ifn=$(CARD_COLLECT_ARO_TABLE) \
		template.fn=$(CDHIT_ARO_TABLE) \
		template.field=$(CDHIT_ARO) \
		ofn=$(CDHIT_UNITED_ARO_TABLE)
	$(_end_touch)
cdhit_merge: $(CDHIT_MERGE_DONE)

#####################################################################################################
# plots
#####################################################################################################

plot_abx_summary:
	$(_R) R/card_plot.r abx.summary \
		ids=$(SUMMARY_IDS) \
		fns=$(ABX_TABLE_FNS) \
		fdir=$(CARD_FDIR)/abx_summary

plot_network:
	$(_R) R/card_plot_network.r plot.network \
		ifn=$(CDHIT_UNITED_ARO_TABLE) \
		ifn.aro=$(CARD_ARO_INDEX) \
		highlight.aros=$(ARO_HIGHLIGHT) \
		fdir=$(CARD_FDIR)/network

plot_card: plot_abx_summary plot_network
