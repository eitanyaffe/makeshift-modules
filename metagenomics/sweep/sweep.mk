#########################################################################################################
# compute contig-bin summary counts
#########################################################################################################

# base table
SWP_CG_DONE?=$(SWP_LIB_DIR)/.done_cg
$(SWP_CG_DONE):
	$(call _start,$(SWP_LIB_DIR))
	perl $(_md)/pl/element_bin_observed.pl \
		$(SWP_BINS_TABLE) \
		$(SWP_CONTIG2BIN) \
		$(SWP_CONTIG_MATRIX) \
		$(SWP_EB)
	$(_end_touch)
swp_eb: $(SWP_CG_DONE)

SWP_LIBS_DONE?=$(SWP_DIR)/.done_libs
$(SWP_LIBS_DONE):
	$(call _start,$(SWP_DIR))
	@$(MAKE) swp_eb LIB_ID=$(SWP_LIB_A)
	@$(MAKE) swp_eb LIB_ID=$(SWP_LIB_B)
	$(_end_touch)
swp_eb_libs: $(SWP_LIBS_DONE)

#####################################################################################################
# merge libs
#####################################################################################################

SWP_MERGE_DONE?=$(SWP_CMP_DIR)/.done_merge
$(SWP_MERGE_DONE): $(SWP_LIBS_DONE)
	$(call _start,$(SWP_CMP_DIR))
	$(_R) R/sweep.r merge.libs \
		ifn.a=$(SWP_EB_A) \
		ifn.b=$(SWP_EB_B) \
		ifn.contigs=$(SWP_CONTIGS_IN) \
		ifn.bins=$(SWP_BINS_TABLE) \
		ofn=$(SWP_CMP_TABLE)
	$(_end_touch)
swp_merge: $(SWP_MERGE_DONE)

#####################################################################################################
# coverage ratio
#####################################################################################################

SWP_RATIO_DONE?=$(SWP_CMP_DIR)/.done_ratio
$(SWP_RATIO_DONE): $(SWP_MERGE_DONE)
	$(call _start,$(SWP_CMP_DIR))
	$(_R) R/sweep.r get.ratio \
		ifn=$(SWP_CMP_TABLE) \
		ofn=$(SWP_BIN_RATIO)
	$(_end_touch)
swp_ratio: $(SWP_RATIO_DONE)

#####################################################################################################
# classify elements that changed
#####################################################################################################

SWP_CLASS_DONE?=$(SWP_CMP_DIR)/.done_class_v4
$(SWP_CLASS_DONE): $(SWP_RATIO_DONE)
	$(call _start,$(SWP_CMP_DIR))
	$(_R) R/sweep.r select.change \
		ifn.cmp=$(SWP_CMP_TABLE) \
		ifn.ratio=$(SWP_BIN_RATIO) \
		min.log.fold=$(SWP_MIN_LOG_FOLD_CHANGE) \
		min.ratio=$(SWP_MIN_RATIO) \
		min.count=$(SWP_MIN_CONTACTS) \
		ofn=$(SWP_TABLE_CLASS)
	$(_end_touch)
swp_class: $(SWP_CLASS_DONE)

#####################################################################################################
# classify elements that changed
#####################################################################################################

SWP_GENES_DONE?=$(SWP_CMP_DIR)/.done_genes_v1
$(SWP_GENES_DONE): $(SWP_CLASS_DONE)
	$(call _start,$(SWP_CMP_DIR))
	$(_R) R/sweep.r get.genes \
		ifn.elements=$(SWP_CMP_TABLE) \
		ifn.gene2contig=$(SWP_GENES_IN) \
		ifn.contig2bin=$(SWP_CONTIG2BIN) \
		ifn.uniref=$(SWP_UNIREF_IN) \
		ofn=$(SWP_GENES)
#		ifn.elements=$(SWP_TABLE_CLASS) \
	$(_end_touch)
swp_genes: $(SWP_GENES_DONE)

swp_all: swp_genes

#####################################################################################################
# plots
#####################################################################################################

swp_plot_scatters:
	$(call _start,$(SWP_CMP_DIR))
	$(_R) R/plot_sweep.r plot.scatters \
		ifn.eb=$(SWP_CMP_TABLE) \
		ifn.bins=$(SWP_SELECTED_BINS) \
		ifn.ratio=$(SWP_BIN_RATIO) \
		ifn.class=$(SWP_TABLE_CLASS) \
		id.a=$(SWP_LIB_A) \
		id.b=$(SWP_LIB_B) \
		fdir=$(SWP_FDIR)/scatter

swp_plot_host_summary:
	$(call _start,$(SWP_CMP_DIR))
	$(_R) R/plot_sweep.r plot.host.summary \
		ifn=$(SWP_SELECTED_BINS) \
		id.a=$(SWP_LIB_A) \
		id.b=$(SWP_LIB_B) \
		fdir=$(SWP_FDIR)/host_summary

swp_plot: swp_plot_scatters swp_plot_host_summary
