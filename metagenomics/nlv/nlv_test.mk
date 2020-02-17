NLV_TEST_LIB1=L1
NLV_TEST_LIB2=L2

NLV_DS1=$(call reval,NLV_DS,LIB_ID=$(NLV_TEST_LIB1))
NLV_DS2=$(call reval,NLV_DS,LIB_ID=$(NLV_TEST_LIB2))

nlv_test:
	@$(MAKE) $(test) \
		MAP_ROOT=$(BASE_OUTPUT_DIR)/nlv_test/$(NLV_TEST_LIB) \
		NLV_INPUT_CONTIG_FASTA=$(_md)/test/contigs.fa \
		NLV_INPUT_CONTIG_TABLE=$(_md)/test/contigs.tab \
		PAIRED_R1=$(_md)/test/R1_$(NLV_TEST_LIB).fastq \
		PAIRED_R2=$(_md)/test/R2_$(NLV_TEST_LIB).fastq \
		NLV_MAX_EDIT_DISTANCE=10 \
		NLV_DISCARD_CLIPPED=F \
		LIB_ID=$(NLV_TEST_LIB)

###########################################################################

nlv_test_construct:
	@$(MAKE) nlv_test test=nlv_lib_map
	@$(MAKE) nlv_test test=nlv_lib_construct

nlv_test_construct_all:
	@$(MAKE) nlv_test_construct NLV_TEST_LIB=$(NLV_TEST_LIB1)
	@$(MAKE) nlv_test_construct NLV_TEST_LIB=$(NLV_TEST_LIB2)

###########################################################################

nlv_test_diverge:
	$(NLV_BIN) diverge \
		-nlv1 $(NLV_DS1) \
		-nlv2 $(NLV_DS2) \
		-ofn $(NLV_DIR)/diverge

###########################################################################

nlv_test_query:
	$(NLV_BIN) query \
		-nlv $(NLV_DS1) \
		-table $(_md)/test/query.tab \
		-ofn $(NLV_DIR)/query1
	$(NLV_BIN) query \
		-nlv $(NLV_DS2) \
		-table $(_md)/test/query.tab \
		-ofn $(NLV_DIR)/query2

###########################################################################

nlv_test_compare:
	$(NLV_BIN) compare -nlv_table $(_md)/test/libs.tab -ofn $(NLV_LIB_DIR)/compare.tab
nlv_test_compare_all:
	@$(MAKE) nlv_test test=nlv_compare

###########################################################################

nlv_test_coverage:
	$(NLV_BIN) coverage \
		-ifn_nlv $(NLV_DS1) \
		-ifn_segments $(_md)/test/segments.tab \
		-summary_field item \
		-ofn $(NLV_DIR)/coverage
nlv_test_coverage_wrap:
	@$(MAKE) nlv_test test=nlv_test_coverage NLV_TEST_LIB=$(NLV_TEST_LIB1)
