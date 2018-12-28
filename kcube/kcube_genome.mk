#####################################################################################################
# genomes
#####################################################################################################

CUBE_GENOME_DONE?=$(CUBE_GENOME_DIR)/.done
$(CUBE_GENOME_DONE):
	$(call _start,$(CUBE_GENOME_DIR))
	$(_Rcall) $(CURDIR) $(_md)/R/cube_genome.r genome.profile \
		ifn.matrix=$(CUBE_MATRIX_XCOV) \
		ifn.genes=$(CUBE_GENOME_INPUT_TABLE) \
		gene.field=$(CUBE_GENOME_INPUT_GENE_FIELD) \
		genome.field=$(CUBE_GENOME_INPUT_GENOME_FIELD) \
		ofn=$(CUBE_GENOME_PROFILE)
	$(_end_touch)
cube_genome_profile: $(CUBE_GENOME_DONE)

CUBE_GENOME_CORE_DONE?=$(CUBE_GENOME_DIR)/.done_core
$(CUBE_GENOME_CORE_DONE): $(CUBE_GENOME_DONE)
	$(_start)
	$(_Rcall) $(CURDIR) $(_md)/R/cube_genome.r core.score \
		ifn.matrix=$(CUBE_MATRIX_XCOV) \
		ifn.genome.profile=$(CUBE_GENOME_PROFILE) \
		ifn.genes=$(CUBE_GENOME_INPUT_TABLE) \
		gene.field=$(CUBE_GENOME_INPUT_GENE_FIELD) \
		genome.field=$(CUBE_GENOME_INPUT_GENOME_FIELD) \
		ofn=$(CUBE_GENOME_CORE_SCORE)
	$(_end_touch)
cube_genome_core: $(CUBE_GENOME_CORE_DONE)

#####################################################################################################
# contigs
#####################################################################################################

CUBE_CONTIGS_DONE?=$(CUBE_GENOME_DIR)/.done_contigs
$(CUBE_CONTIGS_DONE): $(CUBE_GENOME_DONE)
	$(_start)
	$(_Rcall) $(CURDIR) $(_md)/R/cube_genome.r contig.profile \
		ifn.matrix=$(CUBE_MATRIX_XCOV) \
		ifn.genes=$(CUBE_GENE_INPUT_TABLE) \
		ofn=$(CUBE_CONTIG_PROFILE)
	$(_end_touch)
cube_contig_profile: $(CUBE_CONTIGS_DONE)

CUBE_CONTIGS_SUMMARY_DONE?=$(CUBE_GENOME_DIR)/.done_contigs_summary
$(CUBE_CONTIGS_SUMMARY_DONE): $(CUBE_CONTIGS_DONE)
	$(_start)
	$(_Rcall) $(CURDIR) $(_md)/R/cube_genome.r contig.summary \
		ifn=$(CUBE_CONTIG_PROFILE) \
		ofn=$(CUBE_CONTIG_SUMMARY)
	$(_end_touch)
cube_contig_summary: $(CUBE_CONTIGS_SUMMARY_DONE)
