NLV_RESTRICT_CONTIGS_DONE?=$(NLV_DIR)/.done_restrict_contigs
$(NLV_RESTRICT_CONTIGS_DONE):
	$(call _start,$(NLV_DIR))
	$(_R) R/nlv_bins.r restrict.contigs \
		ifn.bins=$(NLV_INPUT_BIN_TABLE) \
		ifn.c2b=$(NLV_INPUT_CONTIG2BIN) \
		bin.field=$(NLV_BIN_FIELD) \
		bin.value=$(NLV_BIN_VALUE) \
		ofn=$(NLV_RESTRICT_C2B)
	$(_end_touch)
nlv_restrict_contigs: $(NLV_RESTRICT_CONTIGS_DONE)

#####################################################################################################
# map reads and construct nlv per library
#####################################################################################################

nlv_lib_map:
	@$(MAKE) m=map map_basic map_clean \
		MAP_SEQ_FILE=$(NLV_INPUT_CONTIG_FASTA)

NLV_LIB_CONSTRUCT_DONE?=$(NLV_LIB_DIR)/.done_construct
$(NLV_LIB_CONSTRUCT_DONE):
	$(call _start,$(NLV_LIB_DIR))
	$(NLV_BIN) construct \
		-idir $(NLV_MAPDIR) \
		-contig_table $(NLV_INPUT_CONTIG_TABLE) \
		-discard_clipped $(NLV_DISCARD_CLIPPED) \
		-min_score $(NLV_MIN_SCORE) \
		-min_length $(NLV_MIN_MATCH_LENGTH) \
		-max_edit $(NLV_MAX_EDIT_DISTANCE) \
		-ofn $(NLV_DS)
	$(_end_touch)
nlv_lib_construct: $(NLV_LIB_CONSTRUCT_DONE)

NLV_RESTRICT_DONE?=$(NLV_LIB_DIR)/.done_restrict
$(NLV_RESTRICT_DONE): $(NLV_LIB_CONSTRUCT_DONE) $(NLV_RESTRICT_CONTIGS_DONE)
	$(_start)
	$(NLV_BIN) restrict \
		-ifn_nlv $(NLV_DS) \
		-ifn_contigs $(NLV_RESTRICT_C2B) \
		-ofn $(NLV_RESTRICT_DS)
	$(_end_touch)
nlv_restrict: $(NLV_RESTRICT_DONE)

nlv_lib: nlv_lib_map nlv_restrict

NLV_LIBS_DONE?=$(NLV_DIR)/.done_nlv_libs
$(NLV_LIBS_DONE):
	$(call _start,$(NLV_DIR))
	@$(foreach ID,$(NLV_IDS),$(MAKE) LIB_ID=$(ID) nlv_lib; $(ASSERT);)
	$(_end_touch)
nlv_libs: $(NLV_LIBS_DONE)

#####################################################################################################
# merge NLVs according to lib sets
#####################################################################################################

# split libs into sets
NLV_SETS_DEF_DONE?=$(NLV_SET_BASEDIR)/.done_sets_table
$(NLV_SETS_DEF_DONE):
	$(call _start,$(NLV_SET_BASEDIR))
	$(_R) R/nlv_set_table.r create.table \
		type=$(NLV_LIB_INPUT_TYPE) \
		subject.id=$(SUBJECT_ID) \
		ids=$(NLV_IDS) \
		ifn=$(NLV_LIB_INPUT_TABLE) \
		lib.count=$(NLV_SET_COUNT) \
		respect.keys=$(NLV_RESPECT_KEYS) \
		ofn=$(NLV_SET_DEFS)
	$(_end_touch)
nlv_sets_def: $(NLV_SETS_DEF_DONE)

# merge libs over sets
NLV_MERGE_DONE?=$(NLV_SET_DIR)/.done_merge
$(NLV_MERGE_DONE):
	$(call _start,$(NLV_SET_DIR))
	$(_R) R/nlv_sets.r merge.libs \
		nlv.bin=$(NLV_BIN) \
		ids=$(NLV_SET_IDS) \
		template.ifn=$(NLV_RESTRICT_DS) \
		template.id=$(LIB_ID) \
		ofn=$(NLV_SET_DS)
	$(_end_touch)
nlv_merge_lib: $(NLV_MERGE_DONE)

# do all sets
NLV_SETS_DONE?=$(NLV_SET_BASEDIR)/.done_sets
$(NLV_SETS_DONE): $(NLV_SETS_DEF_DONE) $(NLV_LIBS_DONE)
	$(call _start,$(NLV_SET_BASEDIR))
	$(_Rcall) $(CURDIR) $(_md)/R/nlv_sets.r merge.sets \
		ifn=$(NLV_SET_DEFS) \
		module=$(m) \
		is.dry=$(DRY)
	$(_end_touch)
nlv_merge_libs: $(NLV_SETS_DONE)

NLV_TABLE_DONE?=$(NLV_SET_BASEDIR)/.done_table
$(NLV_TABLE_DONE): $(NLV_SETS_DONE)
	$(_start)
	$(_Rcall) $(CURDIR) $(_md)/R/nlv_table.r make.nlv.table \
		ifn=$(NLV_SET_DEFS) \
		base.dir=$(NLV_SET_BASEDIR) \
		ofn=$(NLV_LIB_TABLE)
	$(_end_touch)
nlv_table: $(NLV_TABLE_DONE)

nlv_basic: nlv_table
