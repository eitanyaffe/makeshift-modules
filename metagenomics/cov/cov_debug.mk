#####################################################################################################
# single contig
#####################################################################################################


#COV_CONTIG?=k147_27064:s1
#COV_CONTIG_LABEL?=27064

#COV_CONTIG?=k147_18786:s1
#COV_CONTIG_LABEL?=18786

#COV_CONTIG?=k147_59747:s1
#COV_CONTIG_LABEL?=59747

# all is lost!
#COV_CONTIG?=k147_181456:s1
#COV_CONTIG_LABEL?=181456

COV_CONTIG?=k147_228360:s1
COV_CONTIG_LABEL?=228360

COV_CONTIG_DIR?=$(COV_ANALYSIS_DIR)/contig/$(COV_CONTIG_LABEL)
COV_CONTIG_PREFIX?=$(COV_CONTIG_DIR)/out

COV_DUMP_DONE?=$(COV_CONTIG_DIR)/.done_dump
$(COV_DUMP_DONE): $(COV_TABLE_DONE)
	$(call _start,$(COV_CONTIG_DIR))
	$(COV_BIN) refine_single \
		-ifn $(COV_LIB_TABLE) \
		-contig $(COV_CONTIG) \
		-outlier_fraction $(COV_OUTLIER_FRACTION) \
		-p_value $(COV_PVALUE) \
		-pseudo_count $(COV_PSEUDO_COUNT) \
		-max_lib_count $(COV_MAX_LIB_COUNT) \
		-weight_style $(COV_WEIGHT_STYLE) \
		-ofn_prefix $(COV_CONTIG_PREFIX)
	$(_end_touch)
cov_contig: $(COV_DUMP_DONE)
