###########################################################################
# contig-anchor table
###########################################################################

UNT_UNION_DONE?=$(UNT_PARAM_DIR)/.done_unions
$(UNT_UNION_DONE):
	$(call _start,$(UNT_PARAM_DIR))
	$(_R) R/unt.r unt.unions \
		ifn.matrix=$(CA_MATRIX) \
		ifn.params=$(UNT_PARAM_TABLE) \
		min.contacts=$(CA_MIN_CONTACTS) \
		min.enrichment=$(CA_MIN_ENRICHMENT) \
		min.anchor.contigs=$(CA_MIN_ANCHOR_CONTIGS) \
		min.contig.coverage=$(CA_CONTIG_COVERAGE) \
		fdr=$(CA_ASSIGN_FDR) \
		odir=$(UNT_PARAM_DIR)
	$(_end_touch)
unt_unions: $(UNT_UNION_DONE)

###########################################################################
# checkm for single
###########################################################################

unt_checkm:
	@$(MAKE) m=checkm make_checkm \
		CA_MAP_DIR=$(UNT_CHECKM_DIR) \
		CA_ANCHOR_CONTIGS=$(UNT_ANCHOR_CONTIGS)

###########################################################################
# over all parameters
###########################################################################

unt_target:
	$(_Rcall) $(CURDIR) $(_md)/R/unt.r make \
		ifn=$(UNT_PARAM_TABLE) \
		target=$(UNT_TARGET) \
		dry=$(UNT_DRY)

unt_checkm_all:
	@$(MAKE) unt_target UNT_TARGET=unt_checkm

###########################################################################
# compute summaries
###########################################################################

UNT_CHECKM_SUMMARY_DONE?=$(UNT_PARAM_DIR)/.done_checkm_summary
$(UNT_CHECKM_SUMMARY_DONE):
	$(_start)
	$(_R) R/unt.r checkm.summary \
		ifn=$(UNT_PARAM_TABLE) \
		idir.base=$(UNT_PARAM_DIR) \
		ofn=$(UNT_CHECKM_TABLE)
	$(_end_touch)
unt_checkm_summary: $(UNT_CHECKM_SUMMARY_DONE)

UNT_GENOME_SUMMARY_DONE?=$(UNT_PARAM_DIR)/.done_genome_summary
$(UNT_GENOME_SUMMARY_DONE):
	$(_start)
	$(_R) R/unt.r genome.summary \
		ifn=$(UNT_PARAM_TABLE) \
		ifn.contigs=$(CONTIG_TABLE) \
		idir.base=$(UNT_PARAM_DIR) \
		ofn=$(UNT_GENOME_TABLE)
	$(_end_touch)
unt_genome_summary: $(UNT_GENOME_SUMMARY_DONE)

###########################################################################
# plotting
###########################################################################

unt_plot_checkm:
	$(_R) R/plot_unt.r plot.checkm \
		ifn=$(UNT_CHECKM_TABLE) \
		fdir=$(UNT_FDIR)/checkm

unt_plot_genome:
	$(_R) R/plot_unt.r plot.genome \
		ifn=$(UNT_GENOME_TABLE) \
		fdir=$(UNT_FDIR)/genome

###########################################################################
###########################################################################

make_unt: unt_unions unt_checkm_all unt_genome_summary unt_checkm_summary

plot_unt: unt_plot_checkm unt_plot_genome

