rna_lib:
	@$(MAKE) m=map map_basic map_filter map_clean

RNA_LIB_DONE?=$(RNA_DIR)/.done_libs
$(RNA_LIB_DONE):
	$(call _start,$(RNA_DIR))
	@$(foreach ID,$(RNA_IDS),$(MAKE) LIB_ID=$(ID) rna_lib; $(ASSERT);)
	$(_end_touch)
rna_libs: $(RNA_LIB_DONE)

rna_map_clean:
	@$(foreach ID,$(RNA_IDS),$(MAKE) LIB_ID=$(ID) m=map map_clean; $(ASSERT);)
