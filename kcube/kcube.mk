SFILES=$(addprefix $(_md)/cpp/,kcube.cpp KCube_class.cpp KCube_class.h util.h util.cpp Params.cpp Params.h kmer_utils.cpp kmer_utils.h)
$(eval $(call bin_rule2,kcube,$(SFILES)))
KCUBE=$(_md)/bin.$(shell hostname)/kcube

init: $(KCUBE)

# compute variance over selected catalog genes
CUBE_DONE?=$(CUBE_DIR)/.done_cube
$(CUBE_DONE):
	$(call _start,$(CUBE_DIR))
	$(KCUBE) create \
		-ksize $(CUBE_KSIZE) \
		-data $(CUBE_FILE) \
		-input_command $(INPUT_COMMAND) \
		-max_reads $(CUBE_MAX_READS)
	$(_end_touch)
cube: $(CUBE_DONE)

# print cube stats
stats:
	$(KCUBE) stats \
		-data $(CUBE_FILE)

# compute variance over selected catalog genes
CUBE_SUMMARY_DONE?=$(CUBE_PROJECT_DIR)/.done_cube_summary
$(CUBE_SUMMARY_DONE):
	$(call _start,$(CUBE_PROJECT_DIR))
	$(KCUBE) summary \
		-data $(CUBE_FILE) \
		-assembly $(CUBE_ASSEMBLY_FILE) \
		-min_count $(CUBE_MIN_COUNT) \
		-min_segment $(CUBE_MIN_SEGMENT) \
		-allow_sub $(ALLOW_SINGLE_SUB) \
		-ofn $(CUBE_SUMMARY_FILE)
	$(_end_touch)
cube_summary: $(CUBE_SUMMARY_DONE)

# compute variance over selected catalog genes
CUBE_BIN_DONE?=$(CUBE_PROJECT_DIR)/.done_bin
$(CUBE_BIN_DONE):
	$(call _start,$(CUBE_BIN_DIR))
	$(KCUBE) bin \
		-data $(CUBE_FILE) \
		-assembly $(CUBE_ASSEMBLY_FILE) \
		-binsizes $(CUBE_BINSIZES) \
		-min_count $(CUBE_MIN_COUNT) \
		-min_segment $(CUBE_MIN_SEGMENT) \
		-allow_sub $(ALLOW_SINGLE_SUB) \
		-odir $(CUBE_BIN_DIR)
	$(_end_touch)
cube_bin: $(CUBE_BIN_DONE)

# compute variance over selected catalog genes
CUBE_DETAILS_DONE?=$(CUBE_DETAIL_DIR)/.done_details
$(CUBE_DETAILS_DONE):
	$(call _start,$(CUBE_DETAIL_DIR))
	$(KCUBE) details \
		-data $(CUBE_FILE) \
		-assembly $(CUBE_ASSEMBLY_FILE) \
		-odir $(CUBE_DETAIL_DIR)
	$(_end_touch)
cube_details: $(CUBE_DETAILS_DONE)

# loop over libs
loop_libs:
	$(_Rcall) $(CURDIR) $(_md)/R/multi_libs.r multi.libs \
		ifn.table=$(LIB_TABLE) \
		lib.id.field=$(LIB_TABLE_FIELD) \
		max.libs=$(MAX_LIBS) \
		params=$(MF) \
		target=$(t)
