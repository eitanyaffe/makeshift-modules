###############################################################################################
# create bam using bwa/samtools
###############################################################################################

METABAT_INPUT_DONE?=$(METABAT_DIR)/.done_input
$(METABAT_INPUT_DONE):
	$(call _start,$(METABAT_DIR))
	cp $(METABAT_IN_CONTIGS) $(METABAT_CONTIGS)
	$(_end_touch)
mb_input: $(METABAT_INPUT_DONE)

MB_INDEX_DONE?=$(METABAT_INDEX_DIR)/.done
$(MB_INDEX_DONE):
	$(call _start,$(METABAT_INDEX_DIR))
	$(METABAT_BWA) index \
		-p $(METABAT_INDEX_PREFIX) \
		$(METABAT_IN_CONTIGS)
	$(_end_touch)
mb_index: $(MB_INDEX_DONE)

# trim and unite paired reads to single file
METABAT_INPUT_LIB_DONE?=$(METABAT_LIB_DIR)/.done_input
$(METABAT_INPUT_LIB_DONE):
	$(call _start,$(METABAT_LIB_DIR))
	rm -rf $(METABAT_FASTQ)
	perl $(_md)/pl/trim_fastq.pl $(METABAT_IN_R1) $(METABAT_OFFSET) $(METABAT_LENGTH) $(METABAT_FASTQ)
	perl $(_md)/pl/trim_fastq.pl $(METABAT_IN_R2) $(METABAT_OFFSET) $(METABAT_LENGTH) $(METABAT_FASTQ)
	$(_end_touch)
mb_input_lib: $(METABAT_INPUT_LIB_DONE)

METABAT_BAM_DONE?=$(METABAT_LIB_DIR)/.done
$(METABAT_BAM_DONE): $(METABAT_INPUT_LIB_DONE) $(MB_INDEX_DONE)
	$(_start)
	$(METABAT_BWA) mem \
		-t $(METABAT_IO_THREADS) \
		$(METABAT_INDEX_PREFIX) \
		$(METABAT_FASTQ) \
	| $(METABAT_SAMTOOLS) sort -@$(METABAT_IO_THREADS) -o $(METABAT_LIB_BAM) -
	$(_end_touch)
mb_bam: $(METABAT_BAM_DONE)

###############################################################################################
# run metaBAT using docker
###############################################################################################

METABAT_DCKR_PROFILE_DONE?=$(METABAT_WORK_DIR)/.done_dckr_profile
$(METABAT_DCKR_PROFILE_DONE):
	$(call _start,$(METABAT_WORK_DIR))
	echo "DOCKER_RUN_USER_OPTS=\"-v $(METABAT_DIR):/work\"" > $(METABAT_DCKR_PROFILE)
	$(_end_touch)
mb_dckr: $(METABAT_DCKR_PROFILE_DONE)

# calculate depth
METABAT_DEPTH_DONE?=$(METABAT_WORK_DIR)/.done_depth
$(METABAT_DEPTH_DONE): $(METABAT_INPUT_DONE) $(METABAT_DCKR_PROFILE_DONE)
	$(call _start,$(METABAT_WORK_DIR))
	$(METABAT_DOCKER) \
	jgi_summarize_bam_contig_depths \
		--outputDepth /work/output/$(METABAT_LABEL)/depth.txt \
		$(METABAT_BAMS)
	$(_end_touch)
mb_depth: $(METABAT_DEPTH_DONE)

# run metabat
METABAT_DONE?=$(METABAT_WORK_DIR)/.done_main
$(METABAT_DONE): $(METABAT_DEPTH_DONE) $(METABAT_DCKR_PROFILE_DONE)
	$(_start)
	rm -rf $(METABAT_WORK_DIR)/result
	$(METABAT_DOCKER) \
	metabat2 \
		-i /work/contigs.fa \
		-a /work/output/$(METABAT_LABEL)/depth.txt \
		-o /work/output/$(METABAT_LABEL)/result/bin \
		-s $(METABAT_MIN_BIN_SIZE) \
		-m $(METABAT_MIN_CONTIG_SIZE) \
		-t $(METABAT_THREADS) \
		--seed $(METABAT_SEED)
	$(_end_touch)
mb_main: $(METABAT_DONE)

###############################################################################################
# process results
###############################################################################################

# extract bins from fasta
METABAT_TABLE_DONE?=$(METABAT_WORK_DIR)/.done_table
$(METABAT_TABLE_DONE): $(METABAT_DONE)
	$(_start)
	perl $(_md)/pl/fasta2bins.pl \
		$(METABAT_WORK_DIR)/result \
		$(METABAT_TABLE)
	$(_end_touch)
mb_table: $(METABAT_TABLE_DONE)

METABAT_BIN_TABLE_DONE?=$(METABAT_WORK_DIR)/.done_bin_table
$(METABAT_BIN_TABLE_DONE): $(METABAT_TABLE_DONE)
	$(_start)
	$(_R) $(_md)/R/bin_summary.r bin.summary \
		ifn.cb=$(METABAT_TABLE) \
		ifn.contigs=$(METABAT_IN_CONTIG_TABLE) \
		ofn=$(METABAT_BIN_TABLE)
	$(_end_touch)
mb_bin_table: $(METABAT_BIN_TABLE_DONE)

###############################################################################################
# checkm
###############################################################################################

# checkm input
METABAT_SELECT_DONE?=$(METABAT_WORK_DIR)/.done_checkm_input
$(METABAT_SELECT_DONE): $(METABAT_BIN_TABLE_DONE)
	$(_start)
	$(_R) $(_md)/R/bin_summary.r bin.select \
		ifn=$(METABAT_BIN_TABLE) \
		min.length=$(METABAT_SELECT_BINSIZE) \
		idir=$(METABAT_WORK_DIR)/result \
		odir=$(METABAT_CHECKM_FASTA_DIR)
	$(_end_touch)
mb_checkm_select: $(METABAT_SELECT_DONE)

# run checkm
METABAT_CHECKM_DONE?=$(METABAT_CHECKM_DIR)/.done
$(METABAT_CHECKM_DONE): $(METABAT_SELECT_DONE)
	$(_start)
	rm -rf $(METABAT_CHECKM_DIR)/SCG
	$(CHECKM) lineage_wf -t 40 --tab_table \
		-f $(METABAT_CHECKM_DIR)/CheckM.txt \
		-x fa $(METABAT_CHECKM_FASTA_DIR) \
		$(METABAT_CHECKM_DIR)/SCG
	$(_end_touch)
mb_checkm: $(METABAT_CHECKM_DONE)

METABAT_CHECKM_PARSE_DONE?=$(METABAT_CHECKM_DIR)/.done_parse
$(METABAT_CHECKM_PARSE_DONE): $(METABAT_CHECKM_DONE)
	$(_start)
	$(_R) $(_md)/R/mb_checkm.r checkm.parse \
		ifn.checkm=$(METABAT_CHECKM_DIR)/CheckM.txt \
		ifn.bin.table=$(METABAT_BIN_TABLE) \
		ofn=$(METABAT_BIN_TABLE_CHECKM)
	$(_end_touch)
mb_checkm_parse: $(METABAT_CHECKM_PARSE_DONE)

METABAT_CHECKM_SELECT_DONE?=$(METABAT_CHECKM_DIR)/.done_select
$(METABAT_CHECKM_SELECT_DONE): $(METABAT_CHECKM_PARSE_DONE)
	$(_start)
	$(_R) $(_md)/R/mb_checkm.r checkm.select \
		ifn.bin.table=$(METABAT_BIN_TABLE_CHECKM) \
		ifn.cb=$(METABAT_TABLE) \
		min.genome.complete=$(METABAT_MIN_GENOME_COMPLETE) \
		max.genome.contam=$(METABAT_MAX_GENOME_CONTAM) \
		max.element.complete=$(METABAT_MAX_ELEMENT_COMPLETE) \
		ofn.genome.table=$(METABAT_GENOME_TABLE) \
		ofn.cg=$(METABAT_CG) \
		ofn.element.table=$(METABAT_ELEMENT_TABLE) \
		ofn.ce=$(METABAT_CE)
	$(_end_touch)
mb_select: $(METABAT_CHECKM_SELECT_DONE)

# create set table: (set/type/contig/start/end) with type={anchor/element}
METABAT_SETS_DONE?=$(METABAT_CHECKM_DIR)/.done_sets
$(METABAT_SETS_DONE): $(METABAT_CHECKM_SELECT_DONE)
	$(_start)
	$(_R) $(_md)/R/mb_sets.r create.sets \
		ifn.cg=$(METABAT_CG) \
		ifn.ce=$(METABAT_CE) \
		ifn.contigs=$(METABAT_IN_CONTIG_TABLE) \
		ofn.sets=$(METABAT_SETS) \
		ofn.segments=$(METABAT_SEGMENTS)
	$(_end_touch)
mb_sets: $(METABAT_SETS_DONE)

mb_all: mb_select

###############################################################################################
# for taxa
###############################################################################################

# gene/bin table, requires genes to be already predicted
METABAT_GENES_DONE?=$(METABAT_CHECKM_DIR)/.done_genes
$(METABAT_GENES_DONE): $(METABAT_CHECKM_SELECT_DONE)
	$(_start)
	$(_R) $(_md)/R/mb_checkm.r checkm.select.genes \
		ifn.cg=$(METABAT_CG) \
		ifn.genes=$(GENE_TABLE) \
		ofn=$(METABAT_GG)
	$(_end_touch)
mb_genes: $(METABAT_GENES_DONE)

# dummy anchor-table required for taxa
METABAT_DUMMY_DONE?=$(METABAT_CHECKM_DIR)/.done_dummy_tables
$(METABAT_DUMMY_DONE): $(METABAT_CHECKM_SELECT_DONE)
	$(_start)
	$(_R) $(_md)/R/mb_taxa.r dummy.genome.table \
		ifn=$(METABAT_GENOME_TABLE) \
		ofn=$(METABAT_DUMMY_ATABLE)
	$(_R) $(_md)/R/mb_taxa.r dummy.ca.table \
		ifn=$(METABAT_CG) \
		ofn=$(METABAT_DUMMY_CA)
	$(_end_touch)
mb_dummy: $(METABAT_DUMMY_DONE)

###############################################################################################
# plots
###############################################################################################

mb_checkm_plot:
	$(_R) $(_md)/R/mb_checkm.r plot.checkm \
		ifn=$(METABAT_CHECKM_DIR)/CheckM.txt \
		min.complete=$(CHECKM_MIN_COMPLETE) \
		max.contam=$(CHECKM_MAX_CONTAM) \
		fdir=$(METABAT_FDIR)/checkm

mb_checkm_summary_plot:
	$(_R) $(_md)/R/mb_checkm.r plot.checkm.summary \
		idir=$(METABAT_DIR) \
		ids=$(METABAT_LABELS) \
		min.complete=$(CHECKM_MIN_COMPLETE) \
		max.contam=$(CHECKM_MAX_CONTAM) \
		fdir=$(METABASE_FDIR)/metaBAT/summary
