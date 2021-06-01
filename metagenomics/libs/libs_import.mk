LIBS_IMPORT_DONE?=$(LIBS_MULTI_DIR)/.done_import
$(LIBS_IMPORT_DONE):
	$(call _start,$(LIBS_MULTI_DIR))
	$(_R) $(LIBS_INPUT_SCRIPT) generate.libs.table \
		ifn=$(LIBS_INPUT_TABLE) \
		idir=$(INPUT_DIR) \
		ofn.libs=$(LIBS_TABLE) \
		ofn.assembly=$(ASSEMBLY_TABLE)
	$(_end_touch)
import_libs: $(LIBS_IMPORT_DONE)
