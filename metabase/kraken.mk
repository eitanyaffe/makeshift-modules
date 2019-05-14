
################################################################################
# build kraken database
################################################################################

KRAKEN_TAXA_DONE?=$(KRAKEN_DB_DIR)/.done_taxa
$(KRAKEN_TAXA_DONE):
	$(_start)
	$(KRAKEN_BUILD_BIN) --download-taxonomy \
		--db $(KRAKEN_DB_DIR)
	$(_end_touch)
kraken_taxa: $(KRAKEN_TAXA_DONE)

KRAKEN_LIB_DONE?=$(KRAKEN_DB_DIR)/.done_lib
$(KRAKEN_LIB_DONE): $(KRAKEN_TAXA_DONE)
	$(_start)
	$(KRAKEN_BUILD_BIN) --download-library bacteria --db $(KRAKEN_DB_DIR)
	$(KRAKEN_BUILD_BIN) --download-library archaea --db $(KRAKEN_DB_DIR)
	$(KRAKEN_BUILD_BIN) --download-library plant --db $(KRAKEN_DB_DIR)
	$(KRAKEN_BUILD_BIN) --download-library fungi --db $(KRAKEN_DB_DIR)
	$(KRAKEN_BUILD_BIN) --download-library protozoa --db $(KRAKEN_DB_DIR)
	$(KRAKEN_BUILD_BIN) --download-library viral --db $(KRAKEN_DB_DIR)
	$(KRAKEN_BUILD_BIN) --download-library plasmid --db $(KRAKEN_DB_DIR)
	$(_end_touch)
kraken_lib: $(KRAKEN_LIB_DONE)

KRAKEN_DB_DONE?=$(KRAKEN_DB_DIR)/.done_db
$(KRAKEN_DB_DONE): $(KRAKEN_LIB_DONE)
	$(_start)
	$(KRAKEN_BUILD_BIN) --build \
		--threads $(KRAKEN_DB_THREADS) \
		--db $(KRAKEN_DB_DIR)
	$(_end_touch)
kraken_db: $(KRAKEN_DB_DONE)

################################################################################
# run kraken
################################################################################

# https://ccb.jhu.edu/software/kraken2/index.shtml?t=manual

KRAKEN_DONE?=$(KRAKEN_DIR)/.done
$(KRAKEN_DONE):
	$(call _start,$(KRAKEN_DIR))
	$(KRAKEN_BIN) \
		$(KRAKEN_MISC) \
		--threads $(KRAKEN_THREADS) \
		--db $(KRAKEN_DB_DIR) \
		--output $(KRAKEN_OUTPUT) \
		--report $(KRAKEN_REPORT) \
		$(KRAKEN_INPUT)
	$(_end_touch)
kraken: $(KRAKEN_DONE)

KRAKEN_MERGE_DONE?=$(KRAKEN_MERGE_DIR)/.done
$(KRAKEN_MERGE_DONE):
	$(call _start,$(KRAKEN_DIR))
	$(_R) $(_md)/R/kraken.r kraken.merge \
		idir=$(METABASE_OUTPUT_DIR) \
		kraken.ver=$(KRAKEN_VER) \
		order.ifn=$(ORDER_TABLE) \
		ids=$(LIB_IDS_SELECTED) \
		odir=$(KRAKEN_MERGE_DIR)
#	$(_end_touch)
kraken_merge: $(KRAKEN_MERGE_DONE)
