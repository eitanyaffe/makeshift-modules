##################################################################
# go over all sets and prepare a binned nt table
##################################################################

STRAINS_NTS_DONE?=$(STRAIN_SET_DIR)/.done_nts
$(STRAINS_NTS_DONE):
	$(call _start,$(STRAIN_SET_DIR))
	$(NLV_BIN) query_nts \
		-nlv $(NLV_SET_DS) \
		-table $(NLV_TRJ_INPUT) \
		-ofn $(STRAIN_SET_NTS)
	$(_end_touch)
strain_nts: $(STRAINS_NTS_DONE)

STRAINS_TAB_DONE?=$(STRAIN_SET_DIR)/.done_tab
$(STRAINS_TAB_DONE): $(STRAINS_NTS_DONE)
	$(_start)
	perl $(_md)/pl/nlv_to_nts.pl \
		$(STRAIN_SET_NTS) \
		$(NLV_INPUT_CONTIG_FASTA) \
		$(STRAIN_SET_TAB)
	$(_end_touch)
strain_tab: $(STRAINS_TAB_DONE)

STRAINS_SETS_DONE?=$(STRAIN_DIR)/.done_sets
$(STRAINS_SETS_DONE):
	$(_start)
	$(_Rcall) $(CURDIR) $(_md)/R/nlv_sets.r make.sets \
		ifn=$(NLV_SET_DEFS) \
		module=$(m) \
		target=strain_tab \
		is.dry=$(DRY)
	$(_end_touch)
strain_sets: $(STRAINS_SETS_DONE)

##################################################################
# combine sets and prepare 4 nt tables per bin
##################################################################

STRAINS_COMBINE_DONE?=$(STRAIN_DIR)/.done_combine
$(STRAINS_COMBINE_DONE): $(STRAINS_SETS_DONE)
	$(_start)
	$(_R) R/nlv_collect.r collect.nts \
		ifn.libs=$(NLV_SET_DEFS) \
		ifn.sites=$(NLV_TRJ_INPUT) \
		tag=nts.tab \
		idir=$(STRAIN_SET_BASE_DIR) \
		ofn.A=$(STRAIN_A_TAB) \
		ofn.C=$(STRAIN_C_TAB) \
		ofn.G=$(STRAIN_G_TAB) \
		ofn.T=$(STRAIN_T_TAB)
	$(_end_touch)
strain_combine: $(STRAINS_COMBINE_DONE)

STRAINS_BINNED_DONE?=$(STRAIN_DIR)/.done_binned
$(STRAINS_BINNED_DONE): $(STRAINS_COMBINE_DONE)
	$(_start)
	perl $(_md)/pl/assign_sites_to_bins.pl \
		$(NLV_BIN_SEGMENTS) \
		$(STRAIN_A_TAB) \
		$(STRAIN_A_BINNED)
	perl $(_md)/pl/assign_sites_to_bins.pl \
		$(NLV_BIN_SEGMENTS) \
		$(STRAIN_C_TAB) \
		$(STRAIN_C_BINNED)
	perl $(_md)/pl/assign_sites_to_bins.pl \
		$(NLV_BIN_SEGMENTS) \
		$(STRAIN_G_TAB) \
		$(STRAIN_G_BINNED)
	perl $(_md)/pl/assign_sites_to_bins.pl \
		$(NLV_BIN_SEGMENTS) \
		$(STRAIN_T_TAB) \
		$(STRAIN_T_BINNED)
	$(_end_touch)
strain_binned: $(STRAINS_BINNED_DONE)

STRAINS_BINS_DONE?=$(STRAIN_DIR)/.done_bins
$(STRAINS_BINS_DONE): $(STRAINS_BINNED_DONE)
	$(_start)
	$(_R) R/nlv_strain.r explode.bins \
		ifn.bins=$(NLV_INPUT_BIN_TABLE) \
		ifn.sites=$(NLV_TRJ_INPUT) \
		ifn.A=$(STRAIN_A_BINNED) \
		ifn.A=$(STRAIN_A_BINNED) \
		ifn.C=$(STRAIN_C_BINNED) \
		ifn.G=$(STRAIN_G_BINNED) \
		ifn.T=$(STRAIN_T_BINNED) \
		ofn=$(STRAIN_BIN_TABLE) \
		odir=$(STRAIN_BIN_BASE_DIR)
	$(_end_touch)
strain_bins: $(STRAINS_BINS_DONE)

STRAINS_BINS_LIMIT_DONE?=$(STRAIN_DIR)/.done_bins_limit
$(STRAINS_BINS_LIMIT_DONE): $(STRAINS_BINS_DONE)
	$(_start)
	$(_R) R/nlv_strain.r bins.limit \
		ifn=$(STRAIN_BIN_TABLE) \
		maxSNPs=$(STRAIN_BIN_MAX_SNPS) \
		ofn=$(STRAIN_BIN_TABLE_LIMITED)
	$(_end_touch)
strain_bins_limit: $(STRAINS_BINS_LIMIT_DONE)

# compute t-sne for all bins
STRAINS_TSNE_DONE?=$(STRAIN_DIR)/.done_strain_tsne
$(STRAINS_TSNE_DONE): $(STRAINS_BINS_DONE)
	$(_start)
	$(_R) R/nlv_tsne.r compute.strain.tsne \
		ifn.bins=$(STRAIN_BIN_TABLE) \
		bin.template=$(STRAIN_BIN) \
		idir.template=$(STRAIN_BIN_DIR) \
		ofn.sites=$(NLV_TSNE_SITES) \
		ofn.bins=$(NLV_TSNE_BINS)
#	$(_end_touch)
strain_tsne: $(STRAINS_TSNE_DONE)

##################################################################
# running StrainFinder
##################################################################

# prepare StrainFinder alignment for bin
FINDER_INPUT_DONE?=$(STRAIN_BIN_DIR)/.done_finder_input
$(FINDER_INPUT_DONE):
	$(_start)
	$(NLV_STRAIN_FINDER_PYTHON) $(_md)/py/prep_input.py \
		--ifn $(STRAIN_DIMS) \
		--idir $(STRAIN_BIN_DIR) \
		--ofn $(STRAIN_INPUT)
	$(_end_touch)
finder_input: $(FINDER_INPUT_DONE)

FINDER_RUN_DONE?=$(STRAIN_RUN_DIR)/.done
$(FINDER_RUN_DONE): $(FINDER_INPUT_DONE)
	$(call _start,$(STRAIN_RUN_DIR))
	$(NLV_STRAIN_FINDER_COMMAND) --aln $(STRAIN_INPUT) -N $(STRAIN_FINDER_N) \
		 --n_keep 3 --force_update --merge_out \
		--max_reps 10 --dtol 1 --ntol 3 --converge --exhaustive \
		--em_out $(STRAIN_RUN_DIR)/em.cpickle \
		--otu_out $(STRAIN_RUN_DIR)/otu_table.txt \
		--log $(STRAIN_RUN_DIR)/log.txt
	$(_end_touch)
finder_run_single: $(FINDER_RUN_DONE)

FINDER_RUN_ALL_DONE?=$(STRAIN_DIR)/.done_run_all_$(STRAIN_FINDER_N_MAX)
$(FINDER_RUN_ALL_DONE): $(STRAINS_BINS_LIMIT_DONE)
	$(_start)
	$(_Rcall) $(CURDIR) $(_md)/R/nlv_strain.r run.finder \
		ifn=$(STRAIN_BIN_TABLE) \
		module=$(m) \
		target=finder_run_single \
		max.N=$(STRAIN_FINDER_N_MAX) \
		maxSNPs=$(STRAIN_BIN_MAX_SNPS) \
		is.dry=$(DRY)
	$(_end_touch)
finder_run: $(FINDER_RUN_ALL_DONE)

##################################################################
# select number of strains
##################################################################

# BIC-select the number of strains for each bin
FINDER_LL_DONE?=$(STRAIN_BIN_SELECT_DIR)/.done_get_ll
$(FINDER_LL_DONE):
	$(call _start,$(STRAIN_BIN_SELECT_DIR))
	$(NLV_STRAIN_FINDER_PYTHON) $(_md)/py/get_scores.py \
		--module_dir $(NLV_STRAIN_FINDER_DIR) \
		--idir $(STRAIN_RUN_BASE_DIR) \
		--maxN $(STRAIN_FINDER_N_MAX) \
		--ofn $(STRAIN_RESULT_LL_TABLE)
	$(_end_touch)
finder_ll_single: $(FINDER_LL_DONE)

FINDER_LL_ALL_DONE?=$(STRAIN_DIR)/.done_get_ll_all_$(STRAIN_FINDER_N_MAX)
$(FINDER_LL_ALL_DONE): $(FINDER_RUN_ALL_DONE)
	$(_start)
	$(_Rcall) $(CURDIR) $(_md)/R/nlv_strain.r make.bins \
		ifn=$(STRAIN_BIN_TABLE) \
		module=$(m) \
		target=finder_ll_single \
		maxSNPs=$(STRAIN_BIN_MAX_SNPS) \
		is.dry=$(DRY)
	$(_end_touch)
finder_ll: $(FINDER_LL_ALL_DONE)

FINDER_EXTRACT_DONE?=$(STRAIN_BIN_SELECT_DIR)/.done_extr_$(STRAIN_CRITERIA)
$(FINDER_EXTRACT_DONE):
	$(_start)
	$(_R) R/nlv_strain.r extract.optimal \
		ifn=$(STRAIN_RESULT_LL_TABLE) \
		idir=$(STRAIN_RUN_BASE_DIR) \
		type=$(STRAIN_CRITERIA) \
		ofn=$(STRAIN_RESULT_TABLE)
	$(_end_touch)
finder_extract_single: $(FINDER_EXTRACT_DONE)

# extract selected genotype
FINDER_NTS_DONE?=$(STRAIN_BIN_SELECT_DIR)/.done_extr_$(STRAIN_CRITERIA)_genotype
$(FINDER_NTS_DONE): $(FINDER_EXTRACT_DONE)
	$(_start)
	$(_R) R/nlv_strain.r extract.genotype \
		ifn=$(STRAIN_RESULT_TABLE) \
		idir=$(STRAIN_BIN_DIR) \
		ofn.genotype=$(STRAIN_RESULT_NTS) \
		ofn.class=$(STRAIN_RESULT_CLASS)
	$(_end_touch)
finder_nts_single: $(FINDER_NTS_DONE)

FINDER_EXTRACT_ALL_DONE?=$(STRAIN_DIR)/.done_extr_all_$(STRAIN_FINDER_N_MAX)_$(STRAIN_CRITERIA)_v3
$(FINDER_EXTRACT_ALL_DONE): $(FINDER_LL_ALL_DONE)
	$(_start)
	$(_Rcall) $(CURDIR) $(_md)/R/nlv_strain.r make.bins \
		ifn=$(STRAIN_BIN_TABLE) \
		module=$(m) \
		target=finder_nts_single \
		maxSNPs=$(STRAIN_BIN_MAX_SNPS) \
		is.dry=$(DRY)
	$(_end_touch)
nlv_strains: $(FINDER_EXTRACT_ALL_DONE)
