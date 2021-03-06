# compute variance over selected catalog genes
CUBE_UNITED_LIB_DONE?=$(UNITED_LIB_DIR)/.done_$(UNITED_LIB_ID)
$(CUBE_UNITED_LIB_DONE):
	$(call _start,$(UNITED_LIB_DIR))
	$(_Rcall) $(CURDIR) $(_md)/R/unite_libs.r unite.libs \
		ifn.hmp=$(HMP_LIB_TABLE) \
		field.hmp.sample=$(HMP_LIB_TABLE_FIELD) \
		field.hmp.subject=$(HMP_SUBJECT_FIELD) \
		ifn.ebi=$(EBI_LIB_TABLE) \
		field.ebi.sample=$(EBI_LIB_TABLE_FIELD) \
		field.ebi.subject=$(EBI_SUBJECT_FIELD) \
		ofn=$(UNITED_LIB_TABLE)
	$(_end_touch)
cube_unite: $(CUBE_UNITED_LIB_DONE)

# compute matrix
CUBE_MATRIX_DONE?=$(CUBE_MATRIX_DIR)/.done_matrix
$(CUBE_MATRIX_DONE):
	$(call _start,$(CUBE_MATRIX_DIR))
	$(_Rcall) $(CURDIR) $(_md)/R/cube_matrix.r cube.matrix \
		ifn.table=$(LIB_TABLE) \
		lib.id.field=$(LIB_TABLE_FIELD) \
		max.libs=$(MAX_LIBS) \
		cube.dir=$(CUBE_ASSEMBLY_DIR) \
		min.portion=$(CUBE_MATRIX_MIN_IDENTITY) \
		min.xcov=$(CUBE_MATRIX_MIN_XCOVERAGE) \
		ofn.identity=$(CUBE_MATRIX_IDENTITY_BASE) \
		ofn.xcov=$(CUBE_MATRIX_XCOV_BASE)
	$(_end_touch)
cube_matrix: $(CUBE_MATRIX_DONE)

# limit matrix
CUBE_SELECT_DONE?=$(CUBE_MATRIX_DIR)/.done_select
$(CUBE_SELECT_DONE): $(CUBE_MATRIX_DONE)
	$(_start)
	$(_Rcall) $(CURDIR) $(_md)/R/cube_matrix.r matrix.select \
		ifn.lib=$(UNITED_LIB_TABLE) \
		ifn.identity=$(CUBE_MATRIX_IDENTITY_BASE) \
		ifn.xcov=$(CUBE_MATRIX_XCOV_BASE) \
		ofn.identity=$(CUBE_MATRIX_IDENTITY) \
		ofn.xcov=$(CUBE_MATRIX_XCOV)
	$(_end_touch)
cube_select: $(CUBE_SELECT_DONE)

# compute variance over selected catalog genes
CUBE_ITEM_DONE?=$(CUBE_MATRIX_DIR)/.done_summary
$(CUBE_ITEM_DONE): $(CUBE_SELECT_DONE)
	$(_start)
	$(_Rcall) $(CURDIR) $(_md)/R/cube_matrix.r item.table \
		ifn.xcov=$(CUBE_MATRIX_XCOV) \
		ifn.identity=$(CUBE_MATRIX_IDENTITY) \
		ofn=$(CUBE_ITEM_TABLE)
	$(_end_touch)
cube_item_table: $(CUBE_ITEM_DONE)

