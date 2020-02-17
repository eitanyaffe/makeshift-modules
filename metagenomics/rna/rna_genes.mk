#############################################################################################
# single lib
#############################################################################################

RNA_LIB_GENES_DONE?=$(RNA_LIB_DIR)/.done
$(RNA_LIB_GENES_DONE):
	$(call _start,$(RNA_LIB_DIR))
	$(_md)/pl/gene_read_summary.pl \
		$(RNA_INPUT_GENE_TABLE) \
		$(RNA_FILTER_DIR) \
		$(RNA_REMOVE_CLIP) \
		$(RNA_MIN_SCORE) \
		$(RNA_MAX_EDIT_DISTANCE) \
		$(RNA_MIN_MATCH_LENGTH) \
		$(RNA_LIB_TABLE) \
		$(RNA_LIB_STATS)
	$(_end_touch)
rna_genes_lib: $(RNA_LIB_GENES_DONE)

#############################################################################################
# all libs
#############################################################################################

RNA_GENES_DONE?=$(RNA_DIR)/.done_genes
$(RNA_GENES_DONE):
	$(call _start,$(RNA_DIR))
	@$(foreach ID,$(RNA_IDS),$(MAKE) LIB_ID=$(ID) rna_genes_lib; $(ASSERT);)
	$(_end_touch)
rna_genes_base: $(RNA_GENES_DONE)

#############################################################################################
# gene matrix
#############################################################################################

# RPK gene trajectory
RNA_GENE_MATRIX_DONE?=$(RNA_DIR)/.done_gene_matrix
$(RNA_GENE_MATRIX_DONE): $(RNA_GENES_DONE)
	$(_start)
	$(_R) $(_md)/R/rna_gene_matrix.r gene.matrix \
		ifn=$(RNA_INPUT_GENE_TABLE) \
		idir=$(RNA_DIR) \
		ids=$(RNA_IDS) \
		ofn=$(RNA_GENE_MATRIX)
	$(_end_touch)
rna_genes: $(RNA_GENE_MATRIX_DONE)

#############################################################################################
# bin summary
#############################################################################################

# host bin summary
RNA_BINS_DONE?=$(RNA_BIN_DIR)/.done
$(RNA_BINS_DONE): $(RNA_GENE_MATRIX_DONE)
	$(call _start,$(RNA_BIN_DIR))
	$(_R) $(_md)/R/rna_bins.r bin.summary \
		ifn.bins=$(RNA_BINS_TABLE) \
		ifn.genes=$(RNA_INPUT_GENE_TABLE) \
		ifn.gene2bin=$(RNA_GENE2BIN) \
		ifn.mat=$(RNA_GENE_MATRIX) \
		ofn.genes=$(RNA_BINNED_GENES) \
		odir=$(RNA_BIN_DIR)
	$(_end_touch)
rna_bins: $(RNA_BINS_DONE)
