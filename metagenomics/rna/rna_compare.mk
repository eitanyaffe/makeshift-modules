RNA_CMP_DONE?=$(RNA_COMPARE_DIR)/.done
$(RNA_CMP_DONE):
	$(call _start,$(RNA_COMPARE_DIR))
	$(_R) $(_md)/R/rna_compare.r rna.compare \
		ifn.bins=$(RNA_BINS_TABLE) \
		ifn.genes=$(RNA_BINNED_GENES) \
		idir=$(RNA_BIN_DIR) \
		lib.ifn=$(RNA_LIB_MAP_TABLE) \
		libdef.ifn=$(RNA_LIB_DEF_TABLE) \
		set1=$(RNA_SET1) \
		set2=$(RNA_SET2) \
		ofn=$(RNA_COMPARE_TABLE)
	$(_end_touch)
rna_cmp: $(RNA_CMP_DONE)
