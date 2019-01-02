ifeq ($(RARIFY_FOLD),0)
INPUT_CMD=cat $(ASSEMBLY_INPUT_FILES)
else
INPUT_CMD=cat $(RARIFY_READS)
endif

ASSEMBLY_WORK_DIR?=$(ASSEMBLY_DIR)/work
$(FULL_CONTIG_FILE): $(RARIFY_DONE)
	$(call _start,$(ASSEMBLY_DIR))
	@rm -rf $(ASSEMBLY_WORK_DIR)
	$(call _time,$(ASSEMBLY_DIR)) \
		$(MEGAHIT) $(MEGA_HIT_PARAMS) \
			-m $(MEGAHIT_MEMORY_CAP) \
			-o $(ASSEMBLY_WORK_DIR) \
			--min-contig-len $(MEGAHIT_MIN_CONTIG_LENGTH) \
			--k-min $(ASSEMBLY_MIN_KMER) \
			--k-max $(ASSEMBLY_MAX_KMER) \
			--k-step $(ASSEMBLY_KMER_STEP) \
			--merge-level $(MEGAHIT_MERGE_L),$(MEGAHIT_MERGE_S) \
			-t $(NTHREADS) \
			--input-cmd "$(INPUT_CMD)"
	cp $(ASSEMBLY_WORK_DIR)/final.contigs.fa $@
	$(_end)
$(FULL_CONTIG_TABLE): $(FULL_CONTIG_FILE)
	cat $(FULL_CONTIG_FILE) | $(_md)/pl/fasta_summary.pl > $@
basic_assembly: $(FULL_CONTIG_TABLE)

#nice -n 15 /home/dethlefs/bin/megahit --tmp-dir /tmp/dethlefs_Dec2017/megahit_tmp/ --verbose -m 0.80  --mem-flag 2 -t 65 --k-min 27 --k-max 147 --merge-level #13,0.99 --min-contig-len 300 -o OutputDirectoryName --out-prefix PrefixForOutputFilenames -1 FirstSample_R1.fq,SecondSample_R1.fq,etc -2 FirstSample_R2.fq,SecondSample_R2.fq,etc
