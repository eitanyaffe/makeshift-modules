GENES_EXPORT_DONE?=$(GENES_EXPORT_DIR)/.done
$(GENES_EXPORT_DONE):
	$(call _start,$(GENES_EXPORT_DIR))
	$(_R) $(_md)/R/genes_export.r export \
		ifn=$(GENES_ASSEMBLY_TABLE) \
		gene.table.template=$(call reval,GENE_TABLE,ASSEMBLY_ID=ASSEMBLY_ID) \
		gene.nt.template=$(call reval,GENE_FASTA_NT,ASSEMBLY_ID=ASSEMBLY_ID) \
		gene.aa.template=$(call reval,GENE_FASTA_AA,ASSEMBLY_ID=ASSEMBLY_ID) \
		gene.cov.mat=$(call reval,GENES_COVERAGE_GENE_MATRIX,ASSEMBLY_ID=ASSEMBLY_ID) \
		odir=$(GENES_EXPORT_DIR)
	$(_end_touch)
genes_export: $(GENES_EXPORT_DONE)
