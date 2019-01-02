CELLULAR_MDL_DONE=$(FINAL_CELLULAR_MDL_DIR)/.done_mdl_cell
$(CELLULAR_MDL_DONE):
	$(call _start,$(FINAL_CELLULAR_MDL_DIR))
	$(_R) R/cellular.r create.mdl.file \
		ifn=$(FINAL_CELLULAR_BASE_MDL_MFN) \
		anchor.ifn=$(ANCHOR_TABLE) \
		ofn=$(FINAL_CELLULAR_MDL_MFN)
	$(_end_touch)
cell_mdl: $(CELLULAR_MDL_DONE)

MDL_CELL_DONE?=$(MDL_DIR)/.done_cell
$(MDL_CELL_DONE): $(CELLULAR_MDL_DONE) $(MDL_NM)
	$(_start)
	$(_R) R/model_cell.r learn.model \
		spurious.model.prefix=$(MDL_SPURIOUS_PREFIX) \
		model.prefix=$(MDL_PREFIX) \
		model.fn=$(MDL_MFN)
	$(_end_touch)
model_cell: $(MDL_CELL_DONE)
