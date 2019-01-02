
SFILES=$(addprefix $(_md)/cpp/,varisum.cpp Params.cpp Params.h util.cpp util.h)
$(eval $(call bin_rule2,varisum,$(SFILES)))
VARISUM_BIN=$(_md)/bin.$(_binary_suffix)/varisum

init_varisum: $(VARISUM_BIN)

VAR_DONE?=$(MAP_DIR)/.done_var
$(VAR_DONE):
	$(_start)
	$(VARISUM_BIN) \
		-idir $(PARSE_DIR) \
		-contigs $(CONTIG_TABLE) \
		-margin $(VAR_MARGIN) \
		-ofn_nt $(VAR_TABLE_NT) \
		-ofn_link $(VAR_TABLE_LINK)
	$(_end_touch)
varisum_single: $(VAR_DONE)

VAR_CONTIG_DONE?=$(MAP_DIR)/.done_var_contigs
$(VAR_CONTIG_DONE): $(VAR_DONE)
	$(_start)
	$(_md)/pl/var_summary.pl \
		$(CONTIG_TABLE) \
		$(VAR_TABLE_NT) \
		$(VAR_TABLE_LINK) \
		$(VAR_SUMMARY_PERCENTAGE_CUTOFF) \
		$(VAR_SUMMARY_COUNT_CUTOFF) \
		$(VAR_SUMMARY)
	$(_end_touch)
contig_varisum: $(VAR_CONTIG_DONE)

VAR_POLY_RATE_DONE?=$(MAP_DIR)/.done_poly_rate
$(VAR_POLY_RATE_DONE): $(VAR_DONE)
	$(_start)
	$(_md)/pl/poly_rate.pl \
		$(CONTIG_TABLE) \
		$(VAR_TABLE_NT) \
		$(VAR_SNP_RATE_MAX_PERCENTAGE) \
		$(VAR_POLY_RATE_TABLE)
	$(_end_touch)
poly_rate: $(VAR_POLY_RATE_DONE)

SNP_TABLE_DONE?=$(MAP_DIR)/.done_snp_table
$(SNP_TABLE_DONE): $(VAR_DONE)
	$(_start)
	$(_md)/pl/snp_table.pl \
		$(VAR_TABLE_NT) \
		$(VAR_SNP_TABLE)
	$(_end_touch)
snp_table: $(SNP_TABLE_DONE)

# make DATASET=pre_lib_sg_simple MAP_SPLIT_TRIM=F t=snp_simple m=map
# make DATASET=post_lib_sg_simple MAP_SPLIT_TRIM=F t=snp_simple m=map
SNP_SIMPLE_DONE?=$(MAP_DIR)/.done_snp_simple
$(SNP_SIMPLE_DONE): $(VAR_DONE)
	$(_start)
	$(_md)/pl/snp_simple.pl \
		$(VAR_SNP_TABLE) \
		$(VAR_SNP_SIMPLE)
	$(_end_touch)
snp_simple: $(SNP_SIMPLE_DONE)

VAR_CONTIG_BIN_DONE?=$(MAP_DIR)/.done_var_contigs_bins
$(VAR_CONTIG_BIN_DONE): $(VAR_DONE)
	$(_start)
	$(_md)/pl/var_summary_bins.pl \
		$(CONTIG_TABLE) \
		$(VAR_TABLE_NT) \
		$(VAR_TABLE_LINK) \
		$(VAR_SUMMARY_PERCENTAGE_CUTOFF) \
		$(VAR_SUMMARY_COUNT_CUTOFF) \
		$(VAR_SUMMARY_BINS)
	$(_end_touch)

contig_varisum_bins: $(VAR_CONTIG_BIN_DONE)

####################################################################
# compare 2 datasets
####################################################################

SNP_COMPARE_DONE?=$(MAP_DIR)/.done_snp_compare
$(SNP_COMPARE_DONE):
	$(_start)
	$(_md)/pl/snp_compare.pl \
		$(VAR_SNP_SIMPLE1) \
		$(VAR_SNP_SIMPLE2) \
		$(VAR_SNP_COMPARE)
	$(_end_touch)
snp_compare: $(SNP_COMPARE_DONE)

####################################################################
# multiple datasets
####################################################################

VAR_CONTIG_MULTI_DONE?=$(MAP_DIR)/.done_var_contigs_multi
$(VAR_CONTIG_MULTI_DONE):
	$(_start)
	$(_R) R/varisum.r multi.summary \
		ifn=$(CONTIG_TABLE) \
		assembly.dir=$(ASSEMBLY_DIR) \
		ids=$(TDATASETS) \
		map.tag=$(MAP_TAG) \
		ofn=$(VAR_SUMMARY_MULTI)
	$(_end_touch)
varisum: $(VAR_CONTIG_MULTI_DONE)

