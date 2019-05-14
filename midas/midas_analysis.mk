MIDAS_MATRIX_DONE?=$(MIDAS_ANALYSIS_DIR)/.done_matrix
$(MIDAS_MATRIX_DONE):
	$(call _start,$(MIDAS_ANALYSIS_DIR))
	$(_R) R/midas_analysis.r midas.matrix \
		idir=$(MIDAS_MERGE_DIR) \
		ids=$(MIDAS_ANALYSIS_IDS) \
		min.abundance=$(MIDAS_MIN_ABUNDANCE) \
		odir=$(MIDAS_ANALYSIS_DIR)
	$(_end_touch)
midas_matrix: $(MIDAS_MATRIX_DONE)

############################################################################
# plots
############################################################################

plot_midas_counts:
	$(_R) R/midas_analysis.r plot.midas.counts \
		ifn=$(MIDAS_MERGE_DIR)/count_reads.txt \
		fdir=$(MIDAS_FDIR)/1_read_counts

plot_midas_matrix:
	$(_R) R/midas_analysis.r plot.midas.matrix \
		ifn=$(MIDAS_ABUNDANCE) \
		ifn.order=$(MIDAS_ORDER_TABLE) \
		fdir=$(MIDAS_FDIR)/2_matrix

plot_midas_species:
	$(_R) R/midas_analysis.r plot.midas.species \
		ifn=$(MIDAS_ABUNDANCE) \
		ifn.order=$(MIDAS_ORDER_TABLE) \
		fdir=$(MIDAS_FDIR)/3_species


plot_midas_samples:
	$(_R) R/midas_analysis.r plot.midas.samples \
		ifn=$(MIDAS_ABUNDANCE) \
		ifn.order=$(MIDAS_ORDER_TABLE) \
		fdir=$(MIDAS_FDIR)/4_samples

midas_tables:
	$(_R) R/midas_tables.r midas.tables \
		ifn=$(MIDAS_MERGE_DIR)/relative_abundance.txt \
		ids=$(LIB_IDS_SELECTED) \
		ifn.order=$(MIDAS_ORDER_TABLE) \
		ifn.species2genome=$(MIDAS_SPECIES_INFO) \
		ifn.genome.taxa=$(MIDAS_GENOME_TAXA) \
		odir=$(MIDAS_FDIR)/5_tables

midas_cov:
	$(_R) R/midas_tables.r midas.coverage \
		idir=$(MIDAS_BASE_DIR) \
		ifn.stats=$(STATS_COUNTS) \
		ids=$(LIB_IDS_SELECTED) \
		odir=$(MIDAS_FDIR)/6_coverage

# works for hpipe
plot_midas_short: plot_midas_counts plot_midas_matrix plot_midas_species

# this one requires control samples
plot_midas: plot_midas_counts plot_midas_matrix plot_midas_samples plot_midas_species midas_tables

# deprecated
plot_midas_pies:
	$(_R) R/midas_analysis.r plot.midas.pies \
		ifn=$(MIDAS_ABUNDANCE) \
		ifn.order=$(MIDAS_ORDER_TABLE) \
		fdir=$(MIDAS_FDIR)/pies

