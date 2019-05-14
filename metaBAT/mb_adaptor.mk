METABAT_ADAPTOR_DONE?=$(METABAT_ADAPTOR_DIR)/.done
$(METABAT_ADAPTOR_DONE):
	$(call _start,$(METABAT_ADAPTOR_DIR))
	$(_R) $(_md)/R/mb_adaptor.r create.gene.table \
		ifn.cg=$(METABAT_CG) \
		ifn.ce=$(METABAT_CE) \
		ifn.genes=$(GENE_TABLE) \
		ofn.gene.table=$(METABAT_GENE_TABLE) \
		ofn.core.table=$(METABAT_CORE_TABLE) \
		ofn.element.table=$(METABAT_ELEMENT_TABLE) \
		ofn.gene2core=$(METABAT_CORE_GENES) \
		ofn.gene2element=$(METABAT_GENE_ELEMENT)
	$(_end_touch)
mb_adaptor: $(METABAT_ADAPTOR_DONE)
