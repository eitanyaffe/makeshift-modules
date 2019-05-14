###############################################################################################
# create bam using bwa/samtools
###############################################################################################

BIN3C_INPUT_DONE?=$(BIN3C_DIR)/.done_input
$(BIN3C_INPUT_DONE):
	$(call _start,$(BIN3C_DIR))
	cp $(BIN3C_IN_CONTIGS) $(BIN3C_CONTIGS)
	$(_end_touch)
bin3c_input: $(BIN3C_INPUT_DONE)

BIN3C_INDEX_DONE?=$(BIN3C_INDEX_DIR)/.done
$(BIN3C_INDEX_DONE): $(BIN3C_INPUT_DONE)
	$(call _start,$(BIN3C_INDEX_DIR))
	$(BIN3C_BWA) index \
		-p $(BIN3C_INDEX_PREFIX) \
		$(BIN3C_CONTIGS)
	$(_end_touch)
bin3c_index: $(BIN3C_INDEX_DONE)

#bwa
BIN3C_BWA_DONE?=$(BIN3C_LIB_DIR)/.done_bwa
$(BIN3C_BWA_DONE): $(BIN3C_INDEX_DONE)
	$(call _start,$(BIN3C_LIB_DIR))
	$(BIN3C_BWA) mem -5SP \
		-t $(BIN3C_BWA_THREADS) \
		-o $(BIN3C_BWA_OUT) \
		$(BIN3C_INDEX_PREFIX) \
		$(BIN3C_IN_R1) \
		$(BIN3C_IN_R2)
	$(_end_touch)
bin3c_bwa: $(BIN3C_BWA_DONE)

# sam to bam
BIN3C_BAM_DONE?=$(BIN3C_LIB_DIR)/.done_bam
$(BIN3C_BAM_DONE): $(BIN3C_BWA_DONE)
	$(_start)
	$(BIN3C_SAMTOOLS) view -F 0x904 -bS $(BIN3C_BWA_OUT) -@$(BIN3C_SAMTOOLS_THREADS) | \
	$(BIN3C_SAMTOOLS) sort -m 10G -n -@$(BIN3C_SAMTOOLS_THREADS) -o $(BIN3C_BAM) -
	$(_end_touch)
bin3c_bam: $(BIN3C_BAM_DONE)

# bin3c contact map
BIN3C_MAP_DONE?=$(BIN3C_MAP_DIR)/.done
$(BIN3C_MAP_DONE): $(BIN3C_BAM_DONE)
	$(_start)
	rm -rf $(BIN3C_MAP_DIR)
	$(BIN3C_DOCKER) \
	python2 ./bin3C.py mkmap --clobber \
		-e $(CUTTER_TITLE) \
		-v /work/contigs.fa \
		/work/libs/$(BIN3C_ID)/out.bam \
		/work/libs/$(BIN3C_ID)/bin3c_map
	$(_end_touch)
bin3c_map: $(BIN3C_MAP_DONE)

# bin3c cluster
BIN3C_CLUSTER_DONE?=$(BIN3C_CLUSTER_DIR)/.done
$(BIN3C_CLUSTER_DONE): $(BIN3C_MAP_DONE)
	$(_start)
	$(BIN3C_DOCKER) \
	python2 ./bin3C.py cluster --clobber \
		--min-signal $(BIN3C_MIN_SIGNAL) \
		-v /work/libs/$(BIN3C_ID)/bin3c_map/contact_map.p.gz \
		--only-large --min-extent $(BIN3C_MIN_CLUSTER_LENGTH) \
		/work/libs/$(BIN3C_ID)/bin3c_cluster
	$(_end_touch)
bin3c_cluster: $(BIN3C_CLUSTER_DONE)

# run checkm
BIN3C_CHECKM_DONE?=$(BIN3C_CHECKM_DIR)/.done
$(BIN3C_CHECKM_DONE): $(BIN3C_CLUSTER_DONE)
	$(_start)
	$(CHECKM) lineage_wf -t 40 --tab_table \
		-f $(BIN3C_CHECKM_DIR)/CheckM.txt \
		-x fna $(BIN3C_CLUSTER_DIR)/fasta \
		$(BIN3C_CHECKM_DIR)/SCG
	$(_end_touch)
bin3c_checkm: $(BIN3C_CHECKM_DONE)

# generate cc table
BIN3C_TABLE_DONE?=$(BIN3C_LIB_DIR)/.done_table
$(BIN3C_TABLE_DONE): $(BIN3C_CLUSTER_DONE)
	$(_start)
	perl $(_md)/pl/bin3c_table.pl \
		$(BIN3C_CLUSTER_DIR)/fasta \
		fna \
		$(BIN3C_CC_TABLE)
	$(_end_touch)
bin3c_table: $(BIN3C_TABLE_DONE)

bin3c_checkm_plot:
	$(_R) $(_md)/R/bin3C_checkm.r plot.checkm \
		ifn=$(BIN3C_CHECKM_DIR)/CheckM.txt \
		min.complete=$(CHECKM_MIN_COMPLETE) \
		max.contam=$(CHECKM_MAX_CONTAM) \
		fdir=$(BIN3C_FDIR)/checkm

make_bin3c: $(BIN3C_TABLE_DONE) $(BIN3C_CHECKM_DONE)
