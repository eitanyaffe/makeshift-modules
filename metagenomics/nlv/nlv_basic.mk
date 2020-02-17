#####################################################################################################
# compile nlv binary
#####################################################################################################

SFILES=$(addprefix $(_md)/cpp/,\
nlv.h nlv.cpp nlv_construct.cpp nlv_dump.cpp nlv_merge.cpp nlv_compare.cpp \
nlv_query.cpp nlv_divergence.cpp nlv_coverage.cpp nlv_segregation.cpp nlv_view.cpp \
Variation.h Variation.cpp \
Params.cpp Params.h util.cpp util.h)

$(eval $(call bin_rule2,nlv,$(SFILES)))
NLV_BIN=$(_md)/bin.$(shell hostname)/nlv
nlv_init: $(NLV_BIN)

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

nlv_lib: nlv_lib_map nlv_lib_construct

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
	$(_R) R/nlv_sets.r create.table \
		ifn=$(NLV_LIB_TABLE) \
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
		lib.dir=$(NLV_DIR) \
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

#####################################################################################################
# pairwise compare sets
#####################################################################################################

NLV_DIVERGE_DONE?=$(NLV_DIVERGE_DIR)/.done
$(NLV_DIVERGE_DONE):
	$(call _start,$(NLV_DIVERGE_DIR))
	$(NLV_BIN) diverge \
		-nlv1 $(NLV_SET_DS1) \
		-nlv2 $(NLV_SET_DS2) \
		-min_cov $(NLV_DIVERGE_MIN_COVERAGE) \
		-ofn $(NLV_DIVERGE_TABLE)
	$(_end_touch)
nlv_diverge_base: $(NLV_DIVERGE_DONE)

# mask sites using co-abundance data
NLV_DIVERGE_MASK_DONE?=$(NLV_DIVERGE_DIR)/.done_mask
$(NLV_DIVERGE_MASK_DONE):
	perl $(_md)/pl/mask_sites.pl \
		$(NLV_MASK_TABLE) \
		$(NLV_MASK_FIELD) \
		$(NLV_MASK_VALUE) \
		$(NLV_DIVERGE_TABLE) \
		$(NLV_DIVERGE_TABLE_MASKED)
	$(_end_touch)
nlv_diverge: $(NLV_DIVERGE_MASK_DONE)

NLV_DIVERGE_SETS_DONE?=$(NLV_SET_BASEDIR)/.done_diverge_all
$(NLV_DIVERGE_SETS_DONE): $(NLV_SETS_DONE)
	$(_start)
	$(_Rcall) $(CURDIR) $(_md)/R/nlv_sets.r make.set.pairs \
		ifn=$(NLV_SET_DEFS) \
		module=$(m) \
		target=nlv_diverge \
		is.dry=$(DRY)
	$(_end_touch)
nlv_diverge_sets: $(NLV_DIVERGE_SETS_DONE)

#####################################################################################################
# segregation per set
#####################################################################################################

NLV_SEGREGATE_DONE?=$(NLV_SET_DIR)/.done_segregate
$(NLV_SEGREGATE_DONE):
	$(_start)
	$(NLV_BIN) segregation \
		-nlv $(NLV_SET_DS) \
		-min_cov $(NLV_SEGREGATE_MIN_COVERAGE) \
		-max_freq $(NLV_SEGREGATE_MAX_FREQUENCY) \
		-ofn $(NLV_SEGREGATE_TABLE)
	$(_end_touch)
nlv_segregate_base: $(NLV_SEGREGATE_DONE)

# mask sites using co-abundance data
NLV_SEGREGATE_MASK_DONE?=$(NLV_SET_DIR)/.done_mask
$(NLV_SEGREGATE_MASK_DONE):
	perl $(_md)/pl/mask_sites.pl \
		$(NLV_MASK_TABLE) \
		$(NLV_MASK_FIELD) \
		$(NLV_MASK_VALUE) \
		$(NLV_SEGREGATE_TABLE) \
		$(NLV_SEGREGATE_TABLE_MASKED)
	$(_end_touch)
nlv_segregate: $(NLV_SEGREGATE_MASK_DONE)

NLV_SEGREGATE_SETS_DONE?=$(NLV_SET_BASEDIR)/.done_segregate_all
$(NLV_SEGREGATE_SETS_DONE): $(NLV_SETS_DONE)
	$(_start)
	$(_Rcall) $(CURDIR) $(_md)/R/nlv_sets.r make.sets \
		ifn=$(NLV_SET_DEFS) \
		module=$(m) \
		target=nlv_segregate \
		is.dry=$(DRY)
	$(_end_touch)
nlv_segregate_sets: $(NLV_SEGREGATE_SETS_DONE)

nlv_basic: nlv_diverge_sets nlv_segregate_sets
