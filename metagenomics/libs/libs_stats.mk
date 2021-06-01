# collect stats
STATS_DONE?=$(MULTI_STATS_DIR)/.done
$(STATS_DONE):
	$(call _start,$(MULTI_STATS_DIR))
	$(_R) $(_md)/R/stats.r merge.stats \
		ifn=$(LIBS_TABLE) \
		ldir=$(LIBS_BASE_DIR) \
		ofn.reads.count=$(STATS_READS_COUNTS) \
		ofn.reads.yield=$(STATS_READS_YIELD) \
		ofn.bps.count=$(STATS_BPS_COUNTS) \
		ofn.bps.yield=$(STATS_BPS_YIELD)
	$(_end_touch)
lib_stats: $(STATS_DONE)

STATS_DUP_DONE?=$(MULTI_STATS_DIR)/.done_dup
$(STATS_DUP_DONE):
	$(call _start,$(MULTI_STATS_DIR))
	$(_R) $(_md)/R/stats.r merge.dup.stats \
		ifn=$(LIBS_TABLE) \
		ldir=$(LIBS_BASE_DIR) \
		ofn=$(STATS_DUPS)
	$(_end_touch)
lib_dup_stats: $(STATS_DUP_DONE)

# select stats
LIBS_SELECT_DONE?=$(LIBS_SELECT_DIR)/.done_select
$(LIBS_SELECT_DONE):
	$(call _start,$(LIBS_SELECT_DIR))
	$(_R) $(_md)/R/libs_select.r libs.select \
		ifn.input=$(LIBS_INPUT_TABLE) \
		ifn.input.field=$(LIBS_INPUT_TABLE_LIB_FIELD) \
		ifn.libs=$(LIBS_TABLE) \
		ifn.reads.count=$(STATS_READS_COUNTS) \
		ifn.reads.yield=$(STATS_READS_YIELD) \
		ifn.bps.count=$(STATS_BPS_COUNTS) \
		ifn.bps.yield=$(STATS_BPS_YIELD) \
		min.read.count.m=$(LIBS_SELECT_MIN_READ_COUNT) \
		min.trimmo.bp.yield=$(LIBS_SELECT_MIN_TRIMMO_BP_YIELD) \
		min.dup.read.yield=$(LIBS_SELECT_MIN_DUPLICATE_READ_YIELD) \
		min.deconseq.read.yield=$(LIBS_SELECT_MIN_HUMAN_READ_YIELD) \
		ofn.selected=$(LIBS_SELECT_TABLE) \
		ofn.missing=$(LIBS_MISSING_TABLE)
#	$(_end_touch)
s_libs_select: $(LIBS_SELECT_DONE)
