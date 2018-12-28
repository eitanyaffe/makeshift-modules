CUBE_SNP_TABLE_DONE?=$(CUBE_SNP_BASE_DIR)/.done_table
$(CUBE_SNP_TABLE_DONE):
	$(call _start,$(CUBE_SNP_BASE_DIR))
	$(_R) $(_md)/R/cube_snps.r make.snp.table \
		ifn=$(UNITED_LIB_TABLE) \
		input.type=$(CUBE_SNP_INPUT_TYPE) \
		lib.id=$(CUBE_SNP_SINLGE_LIB_ID) \
		base.dir=$(CUBE_BASE_DIR) \
		ksize=$(CUBE_KSIZE) \
		ofn=$(CUBE_SNP_CUBE_TABLE)
	$(_end_touch)
cube_snp_table: $(CUBE_SNP_TABLE_DONE)

CUBE_SNP_DONE?=$(CUBE_SNP_DIR)/.done_snps
$(CUBE_SNP_DONE): $(CUBE_SNP_TABLE_DONE)
	$(call _start,$(CUBE_SNP_DIR))
	$(KCUBE) snps \
		-data_table $(CUBE_SNP_CUBE_TABLE) \
		-assembly $(CUBE_ASSEMBLY_FILE) \
		-min_count $(CUBE_SNP_MIN_COUNT) \
		-min_segment $(CUBE_SNP_MIN_SEGMENT) \
		-odir $(CUBE_SNP_DIR)
	$(_end_touch)
cube_snps_basic: $(CUBE_SNP_DONE)

CUBE_SNP_BIN_DONE?=$(CUBE_SNP_BIN_DIR)/.done_bin
$(CUBE_SNP_BIN_DONE): $(CUBE_SNP_DONE)
	$(call _start,$(CUBE_SNP_BIN_DIR))
	$(_R) $(_md)/R/cube_snps_bin.r snps.bin \
		ifn=$(CUBE_ASSEMBLY_TABLE) \
		field=$(CUBE_ASSEMBLY_TABLE_FIELD) \
		idir=$(CUBE_SNP_DIR) \
		bin.sizes=$(CUBE_SNP_BINS) \
		odir=$(CUBE_SNP_BIN_DIR)
	$(_end_touch)
cube_snps: $(CUBE_SNP_BIN_DONE)

