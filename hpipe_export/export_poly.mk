compress_poly:
	$(call _start,$(EXPORT_ODIR))
	$(_R) R/compress_poly_files.r compress.poly.files \
		ca.ifn=$(CA_ANCHOR_CONTIGS) \
		src.base.dir=$(EVO_POLY_INPUT_BASE_DIR) \
		tgt.base.dir=$(POLY_EXPORT_DIR) \
		title=$(EVO_POLY_ID)
	$(_end)

