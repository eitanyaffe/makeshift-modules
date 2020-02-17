

# TBD:
# 1. verify gene coverage works.
# 2. implement gene summary (pl) -- rewrite gene_snp_calling.pl
# 3. verify using R/snps_genes.r
# 4. proceed migrating code out of evolve module.
#    Output per set (e.g. post): divergence and polymorphisms per bin
# 5. classify: gained/lost/replaced/persistent

#########################################################################################################
# create gene segments
#########################################################################################################

# gene segments, with margin from contig side
SNPS_GENE_SEGMENTS_DONE?=$(SNPS_SET_DIR)/.done_gene_segments
$(SNPS_GENE_SEGMENTS_DONE):
	$(_start)
	$(_R) R/snps_gene_segments.r gene.segments \
		ifn.genes=$(SNPS_INPUT_GENE_TABLE) \
		ifn.contigs=$(SNPS_INPUT_CONTIG_TABLE) \
		edge.margin=$(SNPS_EDGE_MARGIN) \
		ofn=$(SNPS_GENE_SEGMENTS)
	$(_end_touch)
snps_gene_segments: $(SNPS_GENE_SEGMENTS_DONE)

#########################################################################################################
# gene coverage summary
#########################################################################################################

# gene median coverage
SNPS_GENE_BASE_COV_DONE?=$(SNPS_DIR)/.done_gene_base_coverage
$(SNPS_GENE_BASE_COV_DONE): $(SNPS_GENE_SEGMENTS_DONE)
	$(_start)
	perl $(_md)/pl/gene_coverage.pl \
		$(SNPS_GENE_SEGMENTS) \
		$(SNPS_COVER_BASE_DIR) \
		$(SNPS_GENE_BASE_COVERAGE)
	$(_end_touch)
snps_gene_base_cov: $(SNPS_GENE_BASE_COV_DONE)

# gene median coverage
SNPS_GENE_COV_DONE?=$(SNPS_SET_DIR)/.done_gene_coverage
$(SNPS_GENE_COV_DONE): $(SNPS_GENE_SEGMENTS_DONE)
	$(_start)
	perl $(_md)/pl/gene_coverage.pl \
		$(SNPS_GENE_SEGMENTS) \
		$(SNPS_COVER_SET_DIR) \
		$(SNPS_GENE_COVERAGE)
	$(_end_touch)
snps_gene_cov: $(SNPS_GENE_COV_DONE)

#########################################################################################################
# gene snp summary
#########################################################################################################

# gene snp summary
SNPS_GENE_SNPS_DONE?=$(SNPS_SET_DIR)/.done_gene_snps
$(SNPS_GENE_SNPS_DONE): $(SNPS_CLASSIFY_DONE) $(SNPS_GENE_BASE_COV_DONE) $(SNPS_GENE_COV_DONE) $(SNPS_GENE_SEGMENTS_DONE)
	$(_start)
	perl $(_md)/pl/gene_snps.pl \
		$(SNPS_GENE_SEGMENTS) \
		$(SNPS_GENE_BASE_COVERAGE) \
		$(SNPS_GENE_COVERAGE) \
		$(SNPS_CLASSIFIED_TABLE) \
		$(SNPS_GENE_SUMARY) \
		$(SNPS_GENE_DETAILS)
	$(_end_touch)
snps_genes: $(SNPS_GENE_SNPS_DONE)

#########################################################################################################
# deprecated code
#########################################################################################################

SNPS_GENES_DONE?=$(SNPS_SET_DIR)/.done_genes
$(SNPS_GENES_DONE):
	$(call _start,$(SNPS_SET_DIR))
	$(_R) R/snps_genes.r snp.table.genes \
		ifn.genes=$(SNPS_INPUT_GENE_TABLE) \
		ifn.contigs=$(SNPS_INPUT_CONTIG_TABLE) \
		ifn.snps.base=$(SNPS_BASE_TABLE) \
		ifn.snps.set=$(SNPS_SET_TABLE) \
		idir=$(SNPS_VARI_BASE_DIR) \
		lib.ids=$(SNPS_SET_IDS) \
		edge.margin=$(SNPS_EDGE_MARGIN) \
		min.count=$(SNPS_MIN_COUNT) \
		live.threshold=$(SNPS_LIVE_THRESHOLD) \
		fixed.threshold=$(SNPS_FIX_THRESHOLD) \
		ofn.summary=$(SNPS_GENE_TABLE) \
		ofn.details=$(SNPS_GENE_TABLE_DETAILED)
	$(_end_touch)
snps_genes_old: $(SNPS_GENES_DONE)
