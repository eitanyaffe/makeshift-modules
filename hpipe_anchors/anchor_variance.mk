
# split snp data according to anchors
ANCHOR_VARIANCE_DONE?=$(ANCHOR_VARIANCE_DIR)/.done_anchors
$(ANCHOR_VARIANCE_DONE):
	$(call _start,$(ANCHOR_VARIANCE_DIR))
	$(_md)/pl/anchor_snps.pl \
		$(ANCHOR_SNP_INPUT_TABLE1) \
		$(CA_ANCHOR_CONTIGS) \
		$(ANCHOR_SNP_TABLE1)
	$(_md)/pl/anchor_snps.pl \
		$(ANCHOR_SNP_INPUT_TABLE2) \
		$(CA_ANCHOR_CONTIGS) \
		$(ANCHOR_SNP_TABLE2)
	$(_end_touch)
anchor_variance: $(ANCHOR_VARIANCE_DONE)

ANCHOR_VAR_MERGE_DONE?=$(ANCHOR_VARIANCE_DIR)/.done_var_merge
$(ANCHOR_VAR_MERGE_DONE):
	$(call _start,$(ANCHOR_VAR_COMPARE_DIR))
	perl $(_md)/pl/anchor_snp_merge.pl \
		$(ANCHOR_SNP_TABLE1) \
		$(ANCHOR_SNP_TABLE2) \
		$(ANCHOR_VAR_COMPARE_DIR)
	$(_end_touch)
anchor_var_merge: $(ANCHOR_VAR_MERGE_DONE)

ALLLELE_CHANGE_DONE?=$(ANCHOR_VARIANCE_DIR)/.done_allele_change
$(ALLLELE_CHANGE_DONE):
	$(_start)
	$(_R) $(_md)/R/anchor_allele.r compute.allele.matrix \
		ifn.anchors=$(ANCHOR_CLUSTER_TABLE) \
		ifn.ca=$(CA_ANCHOR_CONTIGS) \
		ifn.contigs=$(CONTIG_TABLE) \
		idir=$(ANCHOR_VAR_COMPARE_DIR) \
		ofn=$(ANCHOR_VAR_ALLELE_CHANGES)
	$(_end_touch)
anchor_allelle_change: $(ALLLELE_CHANGE_DONE)

plot_anchor_alleles:
	$(_R) $(_md)/R/anchor_allele.r plot.allele \
		ifn.anchors=$(ANCHOR_CLUSTER_TABLE) \
		idir=$(ANCHOR_VAR_COMPARE_DIR) \
		fdir=$(CA_MAP_FDIR)/anchor_alleles

# make m=map t=contig_varisum_bins DATASET=$(VARIANCE_DATASET1) MAP_SPLIT_TRIM=F
# make m=map t=contig_varisum_bins DATASET=$(VARIANCE_DATASET2) MAP_SPLIT_TRIM=F

# poly rate distribs over anchors
plot_anchor_poly:
	$(_R) $(_md)/R/anchor_poly.r plot.poly \
		ifn.anchors=$(ANCHOR_CLUSTER_TABLE) \
		ifn.ca=$(CA_ANCHOR_CONTIGS) \
		assembly.dir=$(ASSEMBLY_DIR) \
		dataset=$(VARIANCE_DATASET1) \
		fdir=$(CA_MAP_FDIR)/anchor_variance

plot_anchor_changes:
	$(_R) $(_md)/R/anchor_snps.r plot.changes \
		ifn.anchors=$(ANCHOR_CLUSTER_TABLE) \
		ifn.ca=$(CA_ANCHOR_CONTIGS) \
		ifn.contigs=$(CONTIG_TABLE) \
		ifn.snps=$(VAR_SNP_COMPARE) \
		fdir=$(CA_MAP_FDIR)/anchor_snp_changes

# anchor snp density
plot_anchor_snp:
	$(_R) $(_md)/R/anchor_variance.r plot.snp.density \
		ifn.anchors=$(ANCHOR_CLUSTER_TABLE) \
		ifn.ca=$(CA_ANCHOR_CONTIGS) \
		assembly.dir=$(ASSEMBLY_DIR) \
		dataset1=$(VARIANCE_DATASET1) \
		dataset2=$(VARIANCE_DATASET2) \
		fdir=$(CA_MAP_FDIR)/anchor_variance

plot_snp_summary:
	$(_R) $(_md)/R/anchor_variance.r plot.snp.summary \
		ifn.anchors=$(ANCHOR_CLUSTER_TABLE) \
		ifn.ca=$(CA_ANCHOR_CONTIGS) \
		assembly.dir=$(ASSEMBLY_DIR) \
		dataset1=$(VARIANCE_DATASET1) \
		dataset2=$(VARIANCE_DATASET2) \
		fdir=$(CA_MAP_FDIR)/anchor_snp_summary
