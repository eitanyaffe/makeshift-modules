METABAT_DONE?=$(METABAT_WORK_DIR)/.done
$(METABAT_DONE):
	$(_start)
	$(METABAT_DOCKER) \
	metabat2 --cvExt -v \
		-i /work/assembly.fasta \
		-a /work/depth.txt \
		-o /work/output/bin
	$(_end_touch)
metabat_base: $(METABAT_DONE)

METABAT_CHECKM_DONE?=$(METABAT_WORK_DIR)/.done_checkm
$(METABAT_CHECKM_DONE): $(METABAT_DONE)
	$(_start)
	$(CHECKM) lineage_wf -t 40 \
		-f $(METABAT_WORK_DIR)/CheckM.txt \
		-x fa $(METABAT_WORK_DIR)/output \
		$(METABAT_WORK_DIR)/SCG
	$(_end_touch)
metabat: $(METABAT_CHECKM_DONE)

#####################################################################################################
# single coverage table
#####################################################################################################

METABAT_SINGLE_INPUT_DONE?=$(METABAT_SINGLE_DIR)/.done_single_input
$(METABAT_SINGLE_INPUT_DONE):
	$(call _start,$(METABAT_SINGLE_DIR))
	$(_R) R/metaBAT.r get.single.depth \
		ifn=$(METABAT_SINGLE_COVERAGE_IN) \
		ofn=$(METABAT_SINGLE_DEPTH)
	cp $(METABAT_CONTIG_IN) $(METABAT_SINGLE_DIR)/assembly.fasta
	$(_end_touch)
metabat_single_input: $(METABAT_SINGLE_INPUT_DONE)

METABAT_SINGLE_DONE?=$(METABAT_SINGLE_DIR)/.done_single
$(METABAT_SINGLE_DONE): $(METABAT_SINGLE_INPUT_DONE)
	$(_start)
	@$(MAKE) metabat METABAT_WORK_DIR=$(METABAT_SINGLE_DIR)
	$(_end)
metabat_single: $(METABAT_SINGLE_DONE)

#####################################################################################################
# multi coverage table
#####################################################################################################

METABAT_MULTI_INPUT_DONE?=$(METABAT_MULTI_DIR)/.done_multi_input
$(METABAT_MULTI_INPUT_DONE):
	$(call _start,$(METABAT_MULTI_DIR))
	$(_R) R/metaBAT.r get.multi.depth \
		ifn.coverage=$(METABAT_MULTI_COVERAGE_IN) \
		ifn.contigs=$(METABAT_CONTIG_TABLE_IN) \
		ofn=$(METABAT_MULTI_DEPTH)
	cp $(METABAT_CONTIG_IN) $(METABAT_MULTI_DIR)/assembly.fasta
	$(_end_touch)
metabat_multi_input: $(METABAT_MULTI_INPUT_DONE)
