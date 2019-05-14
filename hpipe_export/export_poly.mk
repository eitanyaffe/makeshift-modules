compress_poly:
	$(call _start,$(EXPORT_ODIR))
	$(_R) R/compress_poly_files.r compress.poly.files \
		ca.ifn=$(POLY_EXPORT_TABLE) \
		anchor.field=$(POLY_EXPORT_FIELD) \
		src.base.dir=$(EVO_POLY_INPUT_BASE_DIR) \
		tgt.base.dir=$(POLY_EXPORT_DIR) \
		title=$(EVO_POLY_ID)
	$(_end)

