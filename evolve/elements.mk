#########################################################################################################
# genes
#########################################################################################################

EVO_GENES_DONE?=$(EVO_POLY_DIR)/.done_genes
$(EVO_GENES_DONE):
	$(call _start,$(EVO_POLY_DIR))
	$(_R) R/evo_genes.r snp.table.genes \
		ifn.ga=$(EVO_IN_GA) \
		ifn.genes=$(GENE_TABLE) \
		ifn.contigs=$(CONTIG_TABLE) \
		idir=$(EVO_POLY_INPUT_DIR) \
		idir.ref=$(EVO_POLY_REF_INPUT_DIR) \
		edge.margin=$(EVO_EDGE_MARGIN) \
		min.count=$(EVO_MIN_COUNT) \
		min.live.freq=$(EVO_MIN_LIVE_FREQ) \
		max.live.freq=$(EVO_MAX_LIVE_FREQ) \
		fixed.freq=$(EVO_FIXED_FREQ) \
		ofn.table=$(EVO_GENE_TABLE) \
		ofn.subs=$(EVO_GENE_SUB_TABLE) \
		ofn.poly=$(EVO_GENE_POLY_TABLE)
	$(_end_touch)
evo_genes: $(EVO_GENES_DONE)

#########################################################################################################
# summary over elements/cores
#########################################################################################################

EVO_ELEMENTS_DONE?=$(EVO_POLY_ELEMENT_DIR)/.done_aggregate_cores_elements
$(EVO_ELEMENTS_DONE): $(EVO_GENES_DONE)
	$(call _start,$(EVO_POLY_ELEMENT_DIR))
	$(_R) R/evo_elements.r snp.table.elements \
		ifn=$(EVO_GENE_TABLE) \
		ifn.element.table=$(EVO_IN_SC_ELEMENT_TABLE) \
		ifn.core.table=$(EVO_IN_SC_CORE_TABLE) \
		ifn.gene2element=$(EVO_IN_SC_GENE_ELEMENT) \
		ifn.gene2core=$(EVO_IN_SC_CORE_GENES) \
		detection.cov=$(EVO_ELEMENT_DETECTION_COV) \
		read.length=$(EVO_READ_LENGTH) \
		ofn.elements=$(EVO_ELEMENT_TABLE_BASE) \
		ofn.cores=$(EVO_CORE_TABLE)
	$(_end_touch)
evo_elements: $(EVO_ELEMENTS_DONE)

#########################################################################################################
# generate core poly per gene table
#########################################################################################################

# bin genes according to the number of snps in them
EVO_CORE_PTABLE_DONE?=$(EVO_POLY_ELEMENT_DIR)/.done_core_poly_table
$(EVO_CORE_PTABLE_DONE): $(EVO_ELEMENTS_DONE)
	$(_start)
	$(_R) R/evo_core_poly.r evo.core.poly \
		ifn=$(EVO_GENE_TABLE) \
		ifn.core.table=$(EVO_IN_SC_CORE_TABLE) \
		ifn.gene2core=$(EVO_IN_SC_CORE_GENES) \
		ofn.poly=$(EVO_CORE_POLY_DISTRIB) \
		ofn.fixed=$(EVO_CORE_FIX_DISTRIB)
	$(_end_touch)
evo_core_distrib: $(EVO_CORE_PTABLE_DONE)

#########################################################################################################
# select non-chimeric elements using current
#########################################################################################################

EVO_ELEMENT_SELECT_DONE?=$(EVO_BASE_POLY_DIR)/.done_select_t$(EVO_MAX_COVERAGE_SCORE)
$(EVO_ELEMENT_SELECT_DONE): $(EVO_ELEMENTS_DONE)
	$(_start)
	$(_R) R/classify.r select.elements \
		ifn=$(EVO_ELEMENT_TABLE_BASE_CURRENT) \
		max.score=$(EVO_MAX_COVERAGE_SCORE) \
		ofn=$(EVO_ELEMENT_TABLE_SELECTED)
	$(_end_touch)
evo_select: $(EVO_ELEMENT_SELECT_DONE)

# filter elements
EVO_ELEMENTS_FILTER_DONE?=$(EVO_POLY_ELEMENT_DIR)/.done_elements_filter_t$(EVO_MAX_COVERAGE_SCORE)
$(EVO_ELEMENTS_FILTER_DONE): $(EVO_ELEMENT_SELECT_DONE)
	$(_start)
	$(_R) R/classify.r filter.elements \
		ifn=$(EVO_ELEMENT_TABLE_BASE) \
		ifn.select=$(EVO_ELEMENT_TABLE_SELECTED) \
		ofn=$(EVO_ELEMENT_TABLE)
	$(_end_touch)
evo_filter: $(EVO_ELEMENTS_FILTER_DONE)

# generate host-host matrix
EVO_HOST_MATRIX_DONE?=$(EVO_CLASSIFY_DIR)/.done_host_matrix_t$(EVO_MAX_COVERAGE_SCORE)
$(EVO_HOST_MATRIX_DONE): $(EVO_ELEMENTS_FILTER_DONE)
	$(_start)
	$(_R) R/host_matrix.r host.matrix \
		cores.ifn=$(EVO_IN_SC_CORE_TABLE) \
		elements.ifn=$(EVO_ELEMENT_TABLE) \
		ea.ifn=$(EVO_IN_SC_ELEMENT_ANCHOR) \
		ofn=$(EVO_ELEMENT_HOST_MATRIX)
	$(_end_touch)
evo_host_matrix: $(EVO_HOST_MATRIX_DONE)

#########################################################################################################
# classify
#########################################################################################################

# classify live snps
EVO_CLASS_LIVE_DONE?=$(EVO_CLASSIFY_DIR)/.done_class_live
$(EVO_CLASS_LIVE_DONE): $(EVO_ELEMENTS_FILTER_DONE)
	$(call _start,$(EVO_CLASSIFY_DIR))
	$(_R) R/classify.r classify.live \
		ifn.cores=$(EVO_CORE_TABLE) \
		ifn.elements=$(EVO_ELEMENT_TABLE) \
		ifn.taxa=$(SET_TAX_LEGEND) \
		min.cov=$(EVO_MIN_COV) \
		min.detect=$(EVO_DETECT_FRACTION) \
		snp.density.threshold=$(EVO_POLY_DENSITY_THRESHOLD) \
		ofn.cores=$(EVO_CORE_LIVE_CLASS) \
		ofn.elements=$(EVO_ELEMENT_LIVE_CLASS)
	$(_end_touch)
evo_class_live: $(EVO_CLASS_LIVE_DONE)

# classify fate
EVO_CLASS_FATE_DONE?=$(EVO_CLASSIFY_DIR)/.done_class_fate
$(EVO_CLASS_FATE_DONE): $(EVO_ELEMENTS_DONE)
	$(call _start,$(EVO_CLASSIFY_DIR))
	$(_R) R/classify.r classify.fate \
		ifn.cores=$(EVO_CORE_TABLE) \
		ifn.elements=$(EVO_ELEMENT_TABLE) \
		ifn.taxa=$(SET_TAX_LEGEND) \
		min.cov=$(EVO_MIN_COV) \
		min.detect=$(EVO_DETECT_FRACTION) \
		snp.density.threshold=$(EVO_FIX_DENSITY_THRESHOLD) \
		ofn.cores=$(EVO_CORE_FATE_CLASS) \
		ofn.elements=$(EVO_ELEMENT_FATE_CLASS)
	$(_end_touch)
evo_class_fate: $(EVO_CLASS_FATE_DONE)

# combine element and host fates
EVO_ELEMENT_HOST_DONE?=$(EVO_CLASSIFY_DIR)/.done_element_host_fate
$(EVO_ELEMENT_HOST_DONE): $(EVO_CLASS_FATE_DONE)
	$(_start)
	$(_R) R/classify.r element.host.combined.fate \
		ifn.cores=$(EVO_CORE_FATE_CLASS) \
		ifn.elements=$(EVO_ELEMENT_FATE_CLASS) \
		ifn.element2core=$(EVO_IN_SC_ELEMENT_ANCHOR) \
		ofn=$(EVO_ELEMENT_HOST_FATE)
	$(_end_touch)
evo_element_host_fate: $(EVO_ELEMENT_HOST_DONE)

#########################################################################################################
# explode classified genes
#########################################################################################################

EVO_EXPLODE_FATE_DONE?=$(EVO_CLASSIFY_DIR)/.done_fate_explode
$(EVO_EXPLODE_FATE_DONE): $(EVO_CLASS_FATE_DONE)
	$(_start)
	$(_R) R/evo_explode.r explode.fate \
		ifn.elements=$(EVO_ELEMENT_FATE_CLASS) \
		ifn.gene2element=$(EVO_IN_SC_GENE_ELEMENT) \
		ofn.prefix=$(EVO_ELEMENT_FATE_PREFIX)
	$(_end_touch)
evo_fate_explode: $(EVO_EXPLODE_FATE_DONE)

EVO_EXPLODE_LIVE_DONE?=$(EVO_CLASSIFY_DIR)/.done_live_explode
$(EVO_EXPLODE_LIVE_DONE): $(EVO_CLASS_LIVE_DONE)
	$(_start)
	$(_R) R/evo_explode.r explode.live \
		ifn.elements=$(EVO_ELEMENT_LIVE_CLASS) \
		ifn.gene2element=$(EVO_IN_SC_GENE_ELEMENT) \
		ofn.prefix=$(EVO_ELEMENT_LIVE_PREFIX)
	$(_end_touch)
evo_live_explode: $(EVO_EXPLODE_LIVE_DONE)

evo_explode: evo_live_explode evo_fate_explode

#########################################################################################################
# fate summary
#########################################################################################################

# gene detection summary
EVO_HOST_DETECT_DONE?=$(EVO_CLASSIFY_DIR)/.done_host_detection
$(EVO_HOST_DETECT_DONE): $(EVO_CLASS_FATE_DONE)
	$(_start)
	$(_R) R/fate_summary.r host.detect.summary \
		ifn.genes=$(EVO_GENE_TABLE) \
		ifn.cores=$(EVO_CORE_FATE_CLASS) \
		ifn.ga=$(EVO_IN_GA) \
		ofn=$(EVO_CORE_DETECT_SUMMARY)
	$(_end_touch)
evo_host_detect: $(EVO_HOST_DETECT_DONE)

# fate summary
EVO_HOST_FATE_DONE?=$(EVO_CLASSIFY_DIR)/.done_host_fate_table
$(EVO_HOST_FATE_DONE): $(EVO_CLASS_FATE_DONE)
	$(_start)
	$(_R) R/fate_summary.r host.fate.summary \
		ifn.cores=$(EVO_CORE_FATE_CLASS) \
		ifn.elements=$(EVO_ELEMENT_FATE_CLASS) \
		ifn.gene2element=$(EVO_IN_SC_GENE_ELEMENT) \
		ifn.element2core=$(EVO_IN_SC_ELEMENT_ANCHOR) \
		years=$(EVO_FATE_YEARS) \
		ofn.summary=$(EVO_CORE_FATE_SUMMARY) \
		ofn.details=$(EVO_CORE_FATE_DETAILED)
	$(_end_touch)
evo_host_fate: $(EVO_HOST_FATE_DONE)

# gene table
EVO_GENE_FATE_DONE?=$(EVO_CLASSIFY_DIR)/.done_gene_fate_table
$(EVO_GENE_FATE_DONE): $(EVO_HOST_FATE_DONE)
	$(_start)
	$(_R) R/evo_gene_table.r make.gene.table \
		ifn.anchors=$(ANCHOR_CLUSTER_TABLE) \
		ifn.elements=$(EVO_CORE_FATE_DETAILED) \
		ifn.gene2element=$(EVO_IN_SC_GENE_ELEMENT) \
		ifn.uniref=$(UNIREF_GENE_TAX_TABLE) \
		ofn.all=$(EVO_CORE_GENE_FATE) \
		ofn.select=$(EVO_CORE_GENE_SELECT)
	$(_end_touch)
evo_gene_fate: $(EVO_GENE_FATE_DONE)

#########################################################################################################
# main
#########################################################################################################

make_evo_poly_inst_basic: evo_class_live evo_class_fate evo_host_detect evo_host_fate

make_evo_poly_inst: make_evo_poly_inst_basic evo_gene_fate evo_host_detect evo_explode evo_element_host_fate evo_core_distrib evo_host_matrix


make_evolve:
	@$(MAKE) class_loop class=evo_poly t=make_evo_poly_inst
