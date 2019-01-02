$(FULL_CONTIG_TABLE):
	$(call _start,$(ASSEMBLY_DIR))
	cat $(FULL_CONTIG_FILE) | $(_md)/pl/fasta_summary.pl > $@
	$(_end)
