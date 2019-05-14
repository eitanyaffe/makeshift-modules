MKT_CODON_DONE?=$(MKT_DIR)/.done_codon_table
$(MKT_CODON_DONE):
	$(call _start,$(MKT_DIR))
	perl $(_md)/pl/mkt_parse_codon_table.pl \
		$(MKT_INPUT_CODON_TABLE) \
		$(MKT_CODON_TABLE)
	$(_end_touch)
mkt_codon_table: $(MKT_CODON_DONE)

MKT_SUB_DONE?=$(MKT_DIR)/.done_mkt_sub
$(MKT_SUB_DONE): $(MKT_CODON_DONE)
	$(call _start,$(MKT_DIR))
	perl $(_md)/pl/mkt_sub_table.pl \
		$(MKT_CODON_TABLE) \
		$(MKT_CODON_SUB)
	$(_end_touch)
mkt_sub: $(MKT_SUB_DONE)

#########################################################
# expected ka/ks counts
#########################################################

MKT_BG_DONE?=$(MKT_DIR)/.done_bg
$(MKT_BG_DONE): $(MKT_SUB_DONE)
	$(_start)
	perl $(_md)/pl/mkt_bg.pl \
		$(MKT_CODON_SUB) \
		$(GENE_FASTA_NT) \
		$(MKT_GENE_BG)
	$(_end_touch)
mkt_bg: $(MKT_BG_DONE)

#########################################################
# Dn/Ds
#########################################################

MKT_FIX_DONE?=$(MKT_DIR)/.done_fix
$(MKT_FIX_DONE):
	$(_start)
	perl $(_md)/pl/mkt_gene_summary.pl \
		$(GENE_TABLE) \
		$(GENE_FASTA_NT) \
		$(EVO_FIX_TABLE) \
		$(MKT_CODON_TABLE) \
		$(MKT_GENE_FIX_DETAILS) \
		$(MKT_GENE_FIX_SUMMARY)
	$(_end_touch)
mkt_fix: $(MKT_FIX_DONE)

# core summary
MKT_CORE_FIX_DONE?=$(MKT_DIR)/.done_core_fix
$(MKT_CORE_FIX_DONE): $(MKT_BG_DONE) $(MKT_FIX_DONE)
	$(_start)
	$(_R) R/mkt.r core.summary \
		ifn.core.genes=$(EVO_IN_SC_CORE_GENES) \
		ifn.core.table=$(EVO_IN_SC_CORE_TABLE) \
		ifn.obs=$(MKT_GENE_FIX_SUMMARY) \
		ifn.exp=$(MKT_GENE_BG) \
		ofn.details=$(MKT_CORE_FIX_DETAILS) \
		ofn.summary=$(MKT_CORE_FIX)
	$(_end_touch)
mkt_core_fix: $(MKT_CORE_FIX_DONE)

#########################################################
# Pn/Ps
#########################################################

MKT_POLY_DONE?=$(MKT_DIR)/.done_poly
$(MKT_POLY_DONE):
	$(_start)
	perl $(_md)/pl/mkt_gene_summary.pl \
		$(GENE_TABLE) \
		$(GENE_FASTA_NT) \
		$(EVO_POLY_TABLE) \
		$(MKT_CODON_TABLE) \
		$(MKT_GENE_POLY_DETAILS) \
		$(MKT_GENE_POLY_SUMMARY)
	$(_end_touch)
mkt_poly: $(MKT_POLY_DONE)

MKT_CORE_POLY_DONE?=$(MKT_DIR)/.done_core_poly
$(MKT_CORE_POLY_DONE): $(MKT_BG_DONE) $(MKT_POLY_DONE)
	$(_start)
	$(_R) R/mkt.r core.summary \
		ifn.core.genes=$(EVO_IN_SC_CORE_GENES) \
		ifn.core.table=$(EVO_IN_SC_CORE_TABLE) \
		ifn.obs=$(MKT_GENE_POLY_SUMMARY) \
		ifn.exp=$(MKT_GENE_BG) \
		ofn.details=$(MKT_CORE_POLY_DETAILS) \
		ofn.summary=$(MKT_CORE_POLY)
	$(_end_touch)
mkt_core_poly: $(MKT_CORE_POLY_DONE)

#########################################################
# merge final table
#########################################################

MKT_MERGE_DONE?=$(MKT_DIR)/.done_merge_mkt
$(MKT_MERGE_DONE): $(MKT_CORE_POLY_DONE) $(MKT_CORE_FIX_DONE)
	$(_start)
	$(_R) R/mkt.r core.merge \
		ifn.taxa=$(SET_TAX_LEGEND) \
		ifn.genus.legend=$(SET_TAX_LEGEND_LETTER) \
		ifn.family.legend=$(SET_TAX_LEGEND_COLOR) \
		ifn.class=$(EVO_CORE_FATE_CLASS_10Y) \
		ifn.core.fate=$(EVO_CORE_FATE_SUMMARY_10Y) \
		ifn.core.summary.current=$(EVO_CORE_TABLE_CURRENT) \
		ifn.core.summary.10y=$(EVO_CORE_TABLE_10Y) \
		ifn.poly=$(MKT_CORE_POLY) \
		ifn.fix=$(MKT_CORE_FIX) \
		ofn=$(MKT_TABLE)
	$(_end_touch)
mkt_merge: $(MKT_MERGE_DONE)

MKT_GENE_TABLE_DONE?=$(MKT_DIR)/.done_gene_table
$(MKT_GENE_TABLE_DONE): $(MKT_MERGE_DONE)
	$(_start)
	$(_R) R/mkt.r core.details \
		ifn.table=$(MKT_TABLE) \
		ifn.genes=$(MKT_CORE_FIX_DETAILS) \
		ifn.uniref=$(UNIREF_GENE_TAX_TABLE) \
		ofn=$(MKT_GENE_TABLE)
	$(_end_touch)
mkt_gene_table: $(MKT_GENE_TABLE_DONE)

mkt_all: $(MKT_MERGE_DONE) $(MKT_GENE_TABLE_DONE)

#########################################################
# plots
#########################################################

mkt_plot_basic:
	$(_R) R/mkt_plot.r plot.mkt \
		ifn1=$(AAB_MKT_TABLE) \
		ifn2=$(FP_MKT_TABLE) \
		max.poly.density=$(MKT_MAX_POLY_DENSITY) \
		years=$(EVO_FATE_YEARS) \
		fdir=$(EVO_BASE_FDIR)/mkt

mkt_plot_poly:
	$(_R) R/mkt_plot.r plot.mkt.poly \
		ifn1=$(AAB_MKT_TABLE) \
		ifn2=$(FP_MKT_TABLE) \
		max.poly.density=$(MKT_MAX_POLY_DENSITY) \
		fdir=$(EVO_BASE_FDIR)/poly

mkt_plot_all: mkt_plot_basic mkt_plot_poly
