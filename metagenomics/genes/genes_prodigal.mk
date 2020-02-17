PRODIGAL_DONE?=$(PRODIGAL_DIR)/.done
$(PRODIGAL_DONE):
	$(call _start,$(PRODIGAL_DIR))
	$(PRODIGAL_BIN) -q -f gff \
		-p $(PRODIGAL_SELECT_PROCEDURE) \
		-i $(PRODIGAL_INPUT) \
		-a $(PRODIGAL_AA_BASE) \
		-d $(PRODIGAL_NT_BASE) \
		-g $(PRODIGAL_TRANSLATION_TABLE) \
		-o $(PRODIGAL_OUTPUT_RAW)
	$(_end_touch)
prodigal_base: $(PRODIGAL_DONE)

# clean fasta files
PRODIGAL_CLEAN_DONE?=$(PRODIGAL_DIR)/.done_clean
$(PRODIGAL_CLEAN_DONE): $(PRODIGAL_DONE)
	$(_start)
	cat $(PRODIGAL_AA_BASE) | perl $(_md)/pl/clean_fasta.pl > $(PRODIGAL_AA)
	cat $(PRODIGAL_NT_BASE) | perl $(_md)/pl/clean_fasta.pl > $(PRODIGAL_NT)
	$(_end_touch)
prodigal_clean: $(PRODIGAL_CLEAN_DONE)

# generate gene table
PRODIGAL_TABLE_DONE?=$(PRODIGAL_DIR)/.done_table
$(PRODIGAL_TABLE_DONE): $(PRODIGAL_DONE)
	$(_start)
	cat $(PRODIGAL_OUTPUT_RAW) | perl $(_md)/pl/parse_prodigal.pl > $(PRODIGAL_GENE_TABLE)
	$(_end_touch)
prodigal_table: $(PRODIGAL_TABLE_DONE)

prodigal: $(PRODIGAL_TABLE_DONE) $(PRODIGAL_CLEAN_DONE)
