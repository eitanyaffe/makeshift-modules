# copy source files
INPUT_DONE?=$(NTCMP_DIR)/.done_input
$(INPUT_DONE):
	$(call _assert,NTCMP_FASTA_DIR1 NTCMP_FASTA_PATTERN1 NTCMP_FASTA_DIR2 NTCMP_FASTA_PATTERN2)
	$(call _start,$(NTCMP_DIR))
	cat $(NTCMP_FASTA_FILES1) > $(NTCMP_FASTA1)
	cat $(NTCMP_FASTA_FILES2) > $(NTCMP_FASTA2)
	$(_end_touch)
input: $(INPUT_DONE)

# contig tables
FASTA_SUMMARY_SCRIPT?=$(_md)/pl/fasta_summary.pl
CTABLES_DONE?=$(NTCMP_DIR)/.done_tables
$(CTABLES_DONE): $(INPUT_DONE)
	$(call _assert,NTCMP_FASTA_DIR1 NTCMP_FASTA_PATTERN1 NTCMP_FASTA_DIR2 NTCMP_FASTA_PATTERN2)
	$(call _start,$(NTCMP_DIR))
	cat $(NTCMP_FASTA1) | $(FASTA_SUMMARY_SCRIPT) > $(NTCMP_CONTIG_TABLE1)
	cat $(NTCMP_FASTA2) | $(FASTA_SUMMARY_SCRIPT) > $(NTCMP_CONTIG_TABLE2)
	$(_end_touch)
ctables: $(CTABLES_DONE)

# split contigs
SPLIT_DONE?=$(NTCMP_DIR)/.done_split
$(SPLIT_DONE): $(CTABLES_DONE)
	$(_start)
	mkdir -p $(NTCMP_SPLIT_DIR1) $(NTCMP_SPLIT_DIR2)
	$(_md)/pl/split_contigs.pl \
		$(NTCMP_CONTIG_TABLE1) \
		$(NTCMP_FASTA1) \
		$(NTCMP_CHUNKS) \
		$(NTCMP_SPLIT_DIR1)
	$(_md)/pl/split_contigs.pl \
		$(NTCMP_CONTIG_TABLE2) \
		$(NTCMP_FASTA2) \
		$(NTCMP_CHUNKS) \
		$(NTCMP_SPLIT_DIR2)
	$(_end_touch)
split: $(SPLIT_DONE)

# run mummer
PARSE_SHOWCOORD?=$(_md)/pl/show_coords_parse.pl
MUMMER_PARSE?=$(_md)/pl/mum_parse_two.pl
MUMMER_DONE?=$(NTCMP_DIR)/.done_mummer
$(MUMMER_DONE): $(SPLIT_DONE)
	$(call _start,$(NTCMP_RESULT_DIR))
	$(_R) $(_md)/R/distrib_ntcmp.r distrib.ntcmp \
		mummer=$(MUMMER) \
		mummer.parse=$(MUMMER_PARSE) \
		split.dir1=$(NTCMP_SPLIT_DIR1) \
		split.dir2=$(NTCMP_SPLIT_DIR2) \
		odir=$(NTCMP_RESULT_DIR) \
		qsub.dir=$(NTCMP_QSUB_DIR) \
		batch.max.jobs=$(MAX_JOBS) \
		total.max.jobs.fn=$(MAX_JOBS_FN) \
		dtype=$(DTYPE) \
		show.coords=$(SHOWCOORD) \
		parse.show.coords.script=$(PARSE_SHOWCOORD) \
		jobname=ntcmp
	$(_end_touch)
mummer: $(MUMMER_DONE)

SFILES=$(addprefix $(_md)/cpp/,palign.cpp util.cpp util.h)
$(eval $(call bin_rule2,palign,$(SFILES)))
PALIGN_BIN=$(_md)/bin.$(shell hostname)/palign
init_ntcmp: $(PALIGN_BIN)

DBG?=F

# project results onto genomes
UNIQUE_DONE?=$(NTCMP_DIR)/.done_unique
$(UNIQUE_DONE): $(MUMMER_DONE)
	$(_start)
	mkdir -p $(NTCMP_UNIQUE_DIR1) $(NTCMP_UNIQUE_DIR2)
	$(PALIGN_BIN) \
		-itable1 $(NTCMP_CONTIG_TABLE1) \
		-itable2 $(NTCMP_CONTIG_TABLE2) \
		-idir $(NTCMP_RESULT_DIR) \
		-odir1 $(NTCMP_UNIQUE_DIR1) \
		-odir2 $(NTCMP_UNIQUE_DIR2) \
		-debug $(DBG)
	$(_end_touch)
ntcmp: $(UNIQUE_DONE)

# binning
BIN_DONE?=$(NTCMP_DIR)/.done_bin
$(BIN_DONE): $(UNIQUE_DONE)
	$(_start)
	$(_R) $(_md)/R/ntcmp.r ntcmp.bin \
		ifn.table=$(NTCMP_CONTIG_TABLE1) \
		idir=$(NTCMP_UNIQUE_DIR1) \
		odir=$(NTCMP_BIN_DIR1) \
		bin.sizes=$(NTCMP_BIN_SIZES) \
		min.contig.length=$(NTCMP_MIN_BIN_CONTIG_LENGTH)
	$(_R) $(_md)/R/ntcmp.r ntcmp.bin \
		ifn.table=$(NTCMP_CONTIG_TABLE2) \
		idir=$(NTCMP_UNIQUE_DIR2) \
		odir=$(NTCMP_BIN_DIR2) \
		bin.sizes=$(NTCMP_BIN_SIZES) \
		min.contig.length=$(NTCMP_MIN_BIN_CONTIG_LENGTH)
	$(_end_touch)
ntcmp_bin: $(BIN_DONE)

# summary
SUMMARY_DONE?=$(NTCMP_DIR)/.done_summary
$(SUMMARY_DONE): $(UNIQUE_DONE)
	$(_start)
	$(_R) $(_md)/R/ntcmp.r ntcmp.summary \
		ifn.table=$(NTCMP_CONTIG_TABLE1) \
		idir=$(NTCMP_UNIQUE_DIR1) \
		ofn=$(NTCMP_SUMMARY1)
	$(_R) $(_md)/R/ntcmp.r ntcmp.summary \
		ifn.table=$(NTCMP_CONTIG_TABLE2) \
		idir=$(NTCMP_UNIQUE_DIR2) \
		ofn=$(NTCMP_SUMMARY2)
	$(_end_touch)
ntcmp_summary: $(SUMMARY_DONE)

ntcmp_all: $(BIN_DONE) $(SUMMARY_DONE)
