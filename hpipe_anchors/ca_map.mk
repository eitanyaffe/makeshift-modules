# fends
CA_MAP_FENDS?=$(CA_MAP_DIR)/fends
CA_MAP_BINNED?=$(CA_MAP_DIR)/fends.binned

CA_MAP_BINNED_FINAL?=$(CA_MAP_DIR)/fends.final

# observed
CA_MAP_OBSERVED?=$(CA_MAP_DIR)/count.o

# expected
CA_MAP_CONTIG_EXPECTED?=$(CA_MAP_DIR)/contig.e
CA_MAP_CONTIG_CELL_EXPECTED?=$(CA_MAP_DIR)/contig_cell.e

# relative enr
CA_MAP_EN?=$(CA_MAP_DIR)/enrich


########################################################################################################################
# prepare fends table
########################################################################################################################

$(CA_MAP_FENDS):
	$(call _start,$(CA_MAP_DIR))
	$(_md)/pl/ca_fends.pl \
		$(CA_MAP_IN_FENDS) \
		$(CONTIG_TABLE) \
		$(ANCHOR_TABLE) \
		$@
	$(_end)
assign: $(CA_MAP_FENDS)

$(CA_MAP_BINNED): $(CA_MAP_FENDS)
	$(_start)
	$(_md)/pl/bin_fields.pl \
		$(CA_MAP_FENDS) \
		$(CA_MAP_BINNED) \
		contig anchor
	$(_end)
ca_binned: $(CA_MAP_BINNED)

$(CA_MAP_BINNED_FINAL): $(CA_MAP_BINNED)
	$(_start)
	$(_md)/pl/ca_fix_bins.pl $(CA_MAP_BINNED) $(CA_MAP_BINNED_FINAL)
	$(_end)
ca_fends: $(CA_MAP_BINNED_FINAL)

########################################################################################################################
# observed
########################################################################################################################

$(CA_MAP_OBSERVED): $(CA_MAP_BINNED)
	$(_start)
	$(_md)/pl/ca_observed.pl $(CA_MAP_BINNED) $(CA_MAP_IN_MAT) $(CA_CONTIG_NBINS) $@
	$(_end)
ca_obs: $(CA_MAP_OBSERVED)

########################################################################################################################
# noise model
########################################################################################################################

CA_QSUB_DIR?=$(QSUB_ANCHOR_DIR)/ca_map

TMP_CA_INTER_DIR?=$(CA_QSUB_DIR)/ca_inter_tmp
LOG_CA_INTER_DIR?=$(CA_QSUB_DIR)/ca_inter_log

# expected counts
CA_INTER_EXP_DONE?=$(CA_MAP_DIR)/.done_inter_expected
$(CA_INTER_EXP_DONE): $(CA_MAP_BINNED_FINAL)
	$(_start)
	rm -rf $(TMP_CA_INTER_DIR) $(LOG_CA_INTER_DIR)
	$(_R) R/model_predict.r compute.expected.counts \
		   binary=$(MDL_BINARY) \
		   tmp.dir=$(TMP_CA_INTER_DIR) \
		   log.dir=$(LOG_CA_INTER_DIR) \
		   wd=$(_md) \
	           model.prefix=$(CA_MAP_IN_MODEL_PREFIX) \
	           fends.ifn=$(CA_MAP_BINNED_FINAL) \
	  	   model.ifn=$(CA_MAP_IN_MFN) \
		   scope=anchored model=std \
	           ofields.x=contig_bin ofields.y=anchor_bin omit.x.zero=T omit.y.zero=T \
	  	   num.splits=$(CA_MAP_NUM_SPLIT) max.jobs.fn=$(MAX_JOBS_FN) req.mem=2000 dtype=$(DTYPE) \
		   Rcall="$(_Rcall)" \
	    	   ofn=$(CA_MAP_CONTIG_EXPECTED)
	$(_end_touch)
ca_exp: $(CA_INTER_EXP_DONE)

########################################################################################################################
# noise model
########################################################################################################################

CA_QSUB_CELL_DIR?=$(QSUB_ANCHOR_DIR)/ca_map_cell

TMP_CA_INTER_CELL_DIR?=$(CA_QSUB_CELL_DIR)/ca_inter_tmp
LOG_CA_INTER_CELL_DIR?=$(CA_QSUB_CELL_DIR)/ca_inter_log

# expected counts
CA_INTER_EXP_CELL_DONE?=$(CA_MAP_DIR)/.done_inter_expected_cell
$(CA_INTER_EXP_CELL_DONE): $(CA_MAP_BINNED_FINAL)
	$(_start)
	rm -rf $(TMP_CA_INTER_CELL_DIR) $(LOG_CA_INTER_CELL_DIR)
	$(_R) R/model_predict.r compute.expected.counts \
		   binary=$(MDL_BINARY) \
		   tmp.dir=$(TMP_CA_INTER_CELL_DIR) \
		   log.dir=$(LOG_CA_INTER_CELL_DIR) \
		   wd=$(_md) \
	           model.prefix=$(CA_MAP_IN_MODEL_PREFIX) \
	           model.prefix.cell=$(CA_MAP_IN_MODEL_CELL_PREFIX) \
	           fends.ifn=$(CA_MAP_BINNED_FINAL) \
	  	   model.ifn=$(CA_MAP_IN_CELL_MFN) \
		   scope=anchored model=cellular \
	           ofields.x=contig_bin ofields.y=anchor_bin omit.x.zero=T omit.y.zero=T \
	  	   num.splits=$(CA_MAP_NUM_SPLIT) max.jobs.fn=$(MAX_JOBS_FN) req.mem=2000 dtype=$(DTYPE) \
		   Rcall="$(_Rcall)" \
	    	   ofn=$(CA_MAP_CONTIG_CELL_EXPECTED)
	$(_end_touch)
ca_exp_cell: $(CA_INTER_EXP_CELL_DONE)

########################################################################################################################
# gene / contig / anchor map
########################################################################################################################

$(CA_MATRIX): $(CA_MAP_OBSERVED) $(CA_INTER_EXP_DONE) $(CA_INTER_EXP_CELL_DONE)
	$(_start)
	$(_md)/pl/ca_unite.pl \
		$(CA_MAP_OBSERVED) \
		$(CA_MAP_CONTIG_EXPECTED) \
		$(CA_MAP_CONTIG_CELL_EXPECTED) \
		$(CA_MAP_BINNED).contig \
		$(CA_MAP_BINNED).anchor \
		$@
	$(_end)
ca_map: $(CA_MATRIX)

########################################################################################################################
# inter anchor matrix
########################################################################################################################

$(CA_INTER_ANCHOR_MATRIX): $(CA_MAP_OBSERVED) $(CA_INTER_EXP_DONE)
	$(_start)
	$(_md)/pl/ca_inter_anchor_matrix.pl \
		$(CA_MAP_OBSERVED) \
		$(CA_MAP_CONTIG_EXPECTED) \
		$(CA_MAP_BINNED).contig \
		$(CA_MAP_BINNED).anchor \
		$(ANCHOR_TABLE) \
		$(CA_MIN_ANCHOR_CONTIGS) \
		$(CA_CONTIG_COVERAGE) \
		$@
	$(_end)
ca_inter_matrix: $(CA_INTER_ANCHOR_MATRIX)

########################################################################################################################
# genome population
########################################################################################################################

$(CA_ANCHOR_CONTIGS): $(CA_MATRIX)
	$(_start)
	$(_R) R/ca_analysis.r anchor.contigs \
		ifn=$(CA_MATRIX) \
		min.contacts=$(CA_MIN_CONTACTS) \
		min.enrichment=$(CA_MIN_ENRICHMENT) \
		min.anchor.contigs=$(CA_MIN_ANCHOR_CONTIGS) \
		min.contig.coverage=$(CA_CONTIG_COVERAGE) \
		fdr=$(CA_ASSIGN_FDR) \
		ofn=$@
	$(_end)
ca_contigs: $(CA_ANCHOR_CONTIGS)

$(CA_ANCHOR_GENES): $(CA_ANCHOR_CONTIGS)
	$(_start)
	perl $(_md)/pl/anchor_genes.pl \
		$(CA_ANCHOR_CONTIGS) \
		$(GENE_TABLE) \
		$@
	$(_end)

make_ca: $(CA_INTER_ANCHOR_MATRIX) $(CA_ANCHOR_GENES)

# only contigs, no genes
make_ca_basic: $(CA_INTER_ANCHOR_MATRIX) $(CA_ANCHOR_CONTIGS)

########################################################################################################################
# plots
########################################################################################################################

plot_ca:
	$(_start)
	$(_R) R/ca_analysis.r plot.ca \
		ifn=$(CA_MATRIX) \
		fdir=$(CA_MAP_FDIR)/distribution \
		min.contacts=$(CA_MIN_CONTACTS) \
		min.enrichment=$(CA_MIN_ENRICHMENT) \
		min.anchor.contigs=$(CA_MIN_ANCHOR_CONTIGS) \
		min.contig.coverage=$(CA_CONTIG_COVERAGE) \
		fdr=$(CA_ASSIGN_FDR)
	$(_end)

# rotated anchor scatters
plot_ca_summary:
	$(_start)
	$(_R) R/ca_summary.r plot.ca.summary \
		ifn=$(CA_MATRIX) \
		ifn.ca=$(CA_ANCHOR_CONTIGS) \
		ifn.order=$(ANCHOR_CLUSTER_TABLE) \
		ifn.coverage=$(COVERAGE_TABLE) \
		min.contacts=$(CA_MIN_CONTACTS) \
		min.enrichment=$(CA_MIN_ENRICHMENT) \
		min.anchor.contigs=$(CA_MIN_ANCHOR_CONTIGS) \
		min.contig.coverage=$(CA_CONTIG_COVERAGE) \
		fdr=$(CA_ASSIGN_FDR) \
		fdir=$(CA_MAP_FDIR)/rotated_anchor_maps
	$(_end)

# coverage vs. cell-score
plot_cell_summary:
	$(_start)
	$(_R) R/plot_cell_summary.r plot.cell.summary \
		ifn.ca=$(CA_ANCHOR_CONTIGS) \
		ifn.order=$(ANCHOR_CLUSTER_TABLE) \
		ifn.coverage=$(COVERAGE_TABLE) \
		fdir=$(CA_MAP_FDIR)/cell_maps
	$(_end)

# contig coverage vs. sum of host coverages
plot_coverage_summary:
	$(_start)
	$(_R) R/plot_coverage_summary.r plot.coverage.summary \
		ifn.ca=$(CA_ANCHOR_CONTIGS) \
		ifn.cov=$(COVERAGE_TABLE) \
		fdir=$(CA_MAP_FDIR)/abundance_analysis
	$(_end)

plot_detailed_inter_scatters:
	$(_start)
	$(_R) R/detailed_inter_plots.r detailed.inter.scatter.plots \
		ifn=$(CA_MATRIX) \
		ifn.ca=$(CA_ANCHOR_CONTIGS) \
		ifn.order=$(ANCHOR_CLUSTER_TABLE) \
		ifn.coverage=$(COVERAGE_TABLE) \
		min.contacts=$(CA_MIN_CONTACTS) \
		min.enrichment=$(CA_MIN_ENRICHMENT) \
		min.anchor.contigs=$(CA_MIN_ANCHOR_CONTIGS) \
		min.contig.coverage=$(CA_CONTIG_COVERAGE) \
		fdr=$(CA_ASSIGN_FDR) \
		fdir=$(CA_MAP_FDIR)/detailed_inter_anchor_scatter
	$(_end)

plot_inter_anchor:
	$(_R) R/ca_analysis.r plot.inter.anchor.matrix \
		ifn=$(CA_INTER_ANCHOR_MATRIX) \
		ifn.order=$(ANCHOR_CLUSTER_TABLE) \
		min.contacts=$(CA_MIN_CONTACTS) \
		min.enrichment=$(CA_MIN_ENRICHMENT) \
		fdir=$(ANCHOR_FIGURE_DIR)/inter_anchor

# plot anchor coverage
plot_cc_coverage: $(CA_ANCHOR_CONTIGS)
	$(_R) R/ca_analysis.r plot.cc.coverage \
		ifn=$(CA_ANCHOR_CONTIGS) \
		ifn.coverage=$(COVERAGE_TABLE) \
		fdir=$(CA_MAP_FDIR)/coverage

plot_abundance_distribution:
	$(_R) $(_md)/R/plot_abundance.r plot.abundance \
		ifn.coverage=$(COVERAGE_TABLE) \
		ifn.seeds=$(INITIAL_ANCHOR_TABLE) \
		ifn.ca=$(CA_ANCHOR_CONTIGS) \
		ifn.gc=$(CONTIG_GC_TABLE) \
		fdir=$(CA_MAP_FDIR)/assembly_abundance

plot_anchor_abundance_boxplots:
	$(_R) $(_md)/R/plot_anchor_abundance_boxplots.r plot.anchor.abundance.boxplots \
		ifn=$(ANCHOR_TABLE) \
		ifn.coverage=$(COVERAGE_TABLE) \
		fdir=$(CA_MAP_FDIR)/anchor_abundance_boxplots

plot_anchor_union_abundance:
	$(_R) $(_md)/R/plot_anchor_abundance.r plot.anchor.abundance \
		ifn.order=$(ANCHOR_CLUSTER_TABLE) \
		ifn.coverage=$(COVERAGE_TABLE) \
		ifn.ca=$(CA_ANCHOR_CONTIGS) \
		fdir=$(CA_MAP_FDIR)/anchor_union_abundance

plot_shared:
	$(_R) $(_md)/R/plot_shared.r plot.shared \
		ifn=$(CA_ANCHOR_CONTIGS) \
		ifn.genes=$(GENE_TABLE) \
		ifn.contigs=$(CONTIG_TABLE) \
		fdir=$(CA_MAP_FDIR)/shared

ca_stats:
	$(_R) $(_md)/R/anchor_stats.r anchor.stats \
		ifn=$(CA_ANCHOR_CONTIGS) \
		ifn.contigs=$(CONTIG_TABLE) \
		odir=$(CA_MAP_FDIR)

# abundance analysis
plot_prevalence_analysis:
	$(_R) $(_md)/R/plot_shared_analysis.r plot.shared.analysis \
		ifn.order=$(ANCHOR_CLUSTER_TABLE) \
		ifn.ca=$(CA_ANCHOR_CONTIGS) \
		ifn.contigs=$(CONTIG_TABLE) \
		ifn.coverage=$(COVERAGE_TABLE) \
		ifn.kcube=$(KCUBE_CONTIG_TABLE) \
		fdir=$(CA_MAP_FDIR)/prevalence_analysis

assembly_stats:
	$(_R) $(_md)/R/assembly_stats.r assembly.stats \
		ifn=$(FULL_CONTIG_TABLE) \
		ofn=$(CA_MAP_FDIR)/assembly_stats.txt

make_ca_plots: ca_stats plot_ca plot_ca_summary plot_cell_summary plot_inter_anchor plot_cc_coverage plot_abundance_distribution plot_anchor_abundance_boxplots plot_anchor_union_abundance plot_shared assembly_stats

# for now separate because it depends on various tables which might be missing
plot_anchor_pview:
	$(_Rcall) $(PVIEW_DIR) batch/anchors.r plot.anchors \
		ifn.lookup=$(EXPORT_TABLE) \
		ifn.order=$(ANCHOR_CLUSTER_TABLE) \
		fdir=$(CA_MAP_FDIR)/anchor_pview

