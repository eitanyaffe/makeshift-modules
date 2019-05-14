
MIDAS_INPUT_DONE?=$(MIDAS_DIR)/.done_input
$(MIDAS_INPUT_DONE):
	$(call _start,$(MIDAS_DIR))
	cat $(MIDAS_INPUT_FILES) > $(MIDAS_UNITED_INPUT)
	$(_end_touch)
midas_input: $(MIDAS_INPUT_DONE)

MIDAS_SPECIES_DONE?=$(MIDAS_DIR)/.done_species
$(MIDAS_SPECIES_DONE): $(MIDAS_INPUT_DONE)
	$(_start)
	$(MIDAS_DOCKER) \
	run_midas.py species $(MIDAS_PARAMS)
	$(_end_touch)
midas_species: $(MIDAS_SPECIES_DONE)

MIDAS_GENES_DONE?=$(MIDAS_DIR)/.done_genes
$(MIDAS_GENES_DONE): $(MIDAS_SPECIES_DONE)
	$(_start)
	$(MIDAS_DOCKER) \
	run_midas.py genes $(MIDAS_PARAMS) --species_cov 0.1
	$(_end_touch)
midas_genes: $(MIDAS_GENES_DONE)

MIDAS_SNPS_DONE?=$(MIDAS_DIR)/.done_snps
$(MIDAS_SNPS_DONE): $(MIDAS_SPECIES_DONE)
	$(_start)
	$(MIDAS_DOCKER) \
	run_midas.py snps $(MIDAS_PARAMS)
	$(_end_touch)
midas_snps: $(MIDAS_SNPS_DONE)

MIDAS_SEQ_DONE?=$(MIDAS_DIR)/.done_seq
$(MIDAS_SEQ_DONE): $(MIDAS_SPECIES_DONE)
	$(call _start,$(MIDAS_SEQ_DIR))
	$(_R) R/midas.r get.seq \
		script=$(_md)/pl/fasta_summary.pl \
		midas.dir=$(MIDAS_DIR) \
		db.dir=$(MIDAS_DB) \
		odir=$(MIDAS_SEQ_DIR)
	$(_end_touch)
midas_seq: $(MIDAS_SEQ_DONE)

MIDAS_GUNZIP_DONE?=$(MIDAS_DIR)/.done_gunzip
$(MIDAS_GUNZIP_DONE): $(MIDAS_GENES_DONE) $(MIDAS_SNPS_DONE)
	$(call _start)
	$(_R) R/midas.r gunzip midas.dir=$(MIDAS_DIR) dummy=1
	$(_end_touch)
midas_gunzip: $(MIDAS_GUNZIP_DONE)

############################################################
# merge
############################################################

__COMMA:=,
__EMPTY:=
__SPACE:= $(__EMPTY) $(__EMPTY)
MIDAS_MERGE_INPUT_PARAM=$(subst $(__SPACE),$(__COMMA),$(MIDAS_MERGE_INPUT_DIRS))

MIDAS_SPECIES_MERGE_DONE?=$(MIDAS_MERGE_DIR)/.done
$(MIDAS_SPECIES_MERGE_DONE):
	$(call _start,$(MIDAS_MERGE_DIR))
	$(MIDAS_MERGE_DOCKER) \
	merge_midas.py species \
		/output \
		-t list \
		-i $(MIDAS_MERGE_INPUT_PARAM) \
		-d /data
	$(_end_touch)
midas_species_merge: $(MIDAS_SPECIES_MERGE_DONE)

############################################################
# all
############################################################

midas_all: midas_genes midas_snps midas_seq midas_gunzip
