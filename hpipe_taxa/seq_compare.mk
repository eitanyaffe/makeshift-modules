###########################################################
# retrieve genomes
###########################################################

# anchor/ref table
SC_TABLE_DONE?=$(SC_DIR)/.done_table
$(SC_TABLE_DONE):
	$(call _start,$(SC_DIR))
	$(_R) R/sc.r genome.table \
		ifn.species=$(SET_TAXA_REPS) \
		ifn.taxa=$(SET_TAXA_TABLE) \
		ifn.gene.table=$(GENEBANK_TABLE) \
		only.complete.threshold=$(SC_COMPLETE_GENOME_THRESHOLD) \
		max.refs.per.taxa=$(SC_MAX_REF_GENOMES_PER_TAXA) \
		ofn=$(SC_TABLE)
	$(_end_touch)
sc_table: $(SC_TABLE_DONE)

# copy anchor genomes
SC_ANCHOR_GENOMES_DONE?=$(SC_DIR)/.done_anchor_genomes
$(SC_ANCHOR_GENOMES_DONE):
	$(call _start,$(SC_ANCHOR_DIR))
	perl $(_md)/pl/get_anchor_seq.pl \
		$(FULL_CONTIG_FILE) \
		$(CA_ANCHOR_CONTIGS) \
		F \
		$(SC_ANCHOR_DIR)
	$(_end_touch)
sc_anchor_genomes: $(SC_ANCHOR_GENOMES_DONE)

# download ref genomes
SC_REF_GENOMES_DONE?=$(SC_DIR)/.done_ref_genomes
$(SC_REF_GENOMES_DONE): $(SC_TABLE_DONE)
	$(call _start,$(SC_REF_DIR))
	perl $(_md)/pl/download_genomes.pl \
		$(SC_TABLE) \
		$(GENEBANK_TABLE) \
		$(SC_REF_DIR) \
		$(SC_REF_FAILED)
	$(_end_touch)
sc_ref_genomes: $(SC_REF_GENOMES_DONE)

sc_genomes: $(SC_REF_GENOMES_DONE) $(SC_ANCHOR_GENOMES_DONE)

SC_FASTA_SUMMARY_DONE?=$(SC_DIR)/.done_fasta_summary
$(SC_FASTA_SUMMARY_DONE): $(SC_REF_GENOMES_DONE) $(SC_ANCHOR_GENOMES_DONE)
	$(_start)
	perl ./md/taxa/pl/sc_fasta_summary.pl \
		$(SC_TABLE) \
		$(SC_REF_DIR) \
		$(SC_ANCHOR_DIR) \
		$(_md)/pl/fasta_summary.pl
	$(_end_touch)
sc_genome_summary: $(SC_FASTA_SUMMARY_DONE)

###########################################################
# prepare for mapping
###########################################################

# split input into seq fragments
SC_FRAGMENT_DONE?=$(SC_DIR)/.done_fragment
$(SC_FRAGMENT_DONE): $(SC_FASTA_SUMMARY_DONE)
	$(_start)
	$(_R) R/sc_map.r distrib.fragment \
		script=$(_md)/pl/sc_fragment.pl \
		table.ifn=$(SC_TABLE) \
		ref.dir=$(SC_REF_DIR) \
		anchor.dir=$(SC_ANCHOR_DIR) \
		read.length=$(SC_FRAGMENT_LENGTH) \
		step=$(SC_GENOME_STEP) \
		reads.per.file=$(SC_SEQ_PER_FILE) \
		fragment.dir=$(SC_FRAGMENT_DIR) \
		batch.max.jobs=$(SC_FRAGMENT_MAX_JOBS) \
		total.max.jobs.fn=$(MAX_JOBS_FN) \
		dtype=$(DTYPE) \
		jobname=sc_fragment \
		qsub.dir=$(SC_FRAGMENT_QSUB)
	$(_end_touch)
sc_fragment: $(SC_FRAGMENT_DONE)

# NOTE: this takes 2.8Tb of space
SC_FRAGMENT_READS_DONE?=$(SC_DIR)/.done_fragment_reads
$(SC_FRAGMENT_READS_DONE):
	$(_start)
	perl $(_md)/pl/sc_fragment.pl \
		dir \
		$(SC_READ_INPUT_DIR) \
		$(SC_READ_INPUT_EXT) \
		fastq \
		$(SC_FRAGMENT_LENGTH) \
		$(SC_READ_STEP) \
		$(SC_SEQ_PER_FILE) \
		$(SC_READ_INPUT_MAX_COUNT) \
		$(SC_READ_FRAGMENT_DIR)
	$(_end_touch)
sc_fragment_reads: $(SC_FRAGMENT_READS_DONE)

# bwa index files
SC_BWA_INDEX_DONE?=$(SC_DIR)/.done_bwa_index
$(SC_BWA_INDEX_DONE): $(SC_REF_GENOMES_DONE) $(SC_ANCHOR_GENOMES_DONE)
	$(_start)
	$(_R) R/sc_map.r distrib.bwa.index \
		table.ifn=$(SC_TABLE) \
		ref.dir=$(SC_REF_DIR) \
		anchor.dir=$(SC_ANCHOR_DIR) \
		bwa.binary=$(BWA_BIN) \
		batch.max.jobs=$(SC_BWA_INDEX_MAX_JOBS) \
		total.max.jobs.fn=$(MAX_JOBS_FN) \
		dtype=$(DTYPE) \
		jobname=sc_bwa_index \
		qsub.dir=$(SC_BWA_INDEX_QSUB)
	$(_end_touch)
sc_bwa_index: $(SC_BWA_INDEX_DONE)

###########################################################
# mapping/parsing/summary
###########################################################

SFILES=$(addprefix $(_md)/cpp/,sc_profile.cpp Params.cpp Params.h util.cpp util.h)
$(eval $(call bin_rule2,sc_profile,$(SFILES)))
SC_PROFILE_BINARY=$(_md)/bin.$(_binary_suffix)/sc_profile

init_sc: $(SC_PROFILE_BINARY)

# mapping ref to anchor
SC_REF2ANCHOR_DONE?=$(SC_DIR)/.done_ref2anchor
$(SC_REF2ANCHOR_DONE): $(SC_FRAGMENT_DONE) $(SC_BWA_INDEX_DONE)
	$(_start)
	$(_R) R/sc_map.r distrib.ref2anchor \
		script=$(_md)/pl/map_seq.pl \
		table.ifn=$(SC_TABLE) \
		ref.dir=$(SC_REF_DIR) \
		anchor.dir=$(SC_ANCHOR_DIR) \
		bwa.binary=$(BWA_BIN) \
		parse.bwa=$(_md)/pl/parse_bwa_sam.pl \
		profile.binary=$(SC_PROFILE_BINARY) \
		read.length=$(SC_FRAGMENT_LENGTH) \
		nthreads=$(SC_NTHREADS) \
		batch.max.jobs=$(SC_MAX_JOBS) \
		total.max.jobs.fn=$(MAX_JOBS_FN) \
		dtype=$(DTYPE) \
		jobname=sc_map_ref2anchor \
		qsub.dir=$(SC_REF2ANCHOR_QSUB) \
		fragment.dir=$(SC_FRAGMENT_DIR) \
		odir=$(SC_REF2ANCHOR_DIR)
	$(_end_touch)
sc_ref2anchor: $(SC_REF2ANCHOR_DONE)

# mapping anchor to ref
SC_ANCHOR2REF_DONE?=$(SC_DIR)/.done_anchor2ref
$(SC_ANCHOR2REF_DONE): $(SC_FRAGMENT_DONE) $(SC_BWA_INDEX_DONE)
	$(_start)
	$(_R) R/sc_map.r distrib.anchor2ref \
		script=$(_md)/pl/map_seq.pl \
		table.ifn=$(SC_TABLE) \
		ref.dir=$(SC_REF_DIR) \
		anchor.dir=$(SC_ANCHOR_DIR) \
		bwa.binary=$(BWA_BIN) \
		parse.bwa=$(_md)/pl/parse_bwa_sam.pl \
		profile.binary=$(SC_PROFILE_BINARY) \
		read.length=$(SC_FRAGMENT_LENGTH) \
		nthreads=$(SC_NTHREADS) \
		batch.max.jobs=$(SC_MAX_JOBS) \
		total.max.jobs.fn=$(MAX_JOBS_FN) \
		dtype=$(DTYPE) \
		jobname=sc_map_anchor2ref \
		qsub.dir=$(SC_ANCHOR2REF_QSUB) \
		fragment.dir=$(SC_FRAGMENT_DIR) \
		odir=$(SC_ANCHOR2REF_DIR)
	$(_end_touch)
sc_anchor2ref: $(SC_ANCHOR2REF_DONE)

# mapping short reads to ref
SC_READ2REF_DONE?=$(SC_DIR)/.done_read2ref
$(SC_READ2REF_DONE): $(SC_FRAGMENT_READS_DONE) $(SC_BWA_INDEX_DONE)
	$(_start)
	$(_R) R/sc_map.r distrib.read2ref \
		script=$(_md)/pl/map_seq.pl \
		table.ifn=$(SC_TABLE) \
		ref.dir=$(SC_REF_DIR) \
		bwa.binary=$(BWA_BIN) \
		parse.bwa=$(_md)/pl/parse_bwa_sam.pl \
		profile.binary=$(SC_PROFILE_BINARY) \
		read.length=$(SC_FRAGMENT_LENGTH) \
		nthreads=$(SC_NTHREADS_READS) \
		batch.max.jobs=$(SC_MAX_JOBS_READS) \
		total.max.jobs.fn=$(MAX_JOBS_FN) \
		dtype=$(DTYPE) \
		jobname=sc_map_read2ref \
		qsub.dir=$(SC_READ2REF_QSUB) \
		idir=$(SC_READ_FRAGMENT_DIR) \
		odir=$(SC_READ2REF_DIR)
	$(_end_touch)
sc_read2ref: $(SC_READ2REF_DONE)

###########################################################
# global summary
###########################################################

SC_SUMMARY_DONE?=$(SC_DIR)/.done_summary
$(SC_SUMMARY_DONE): $(SC_ANCHOR2REF_DONE) $(SC_REF2ANCHOR_DONE)
	$(_start)
	$(_R) R/seq_summary.r seq.summary \
		order.ifn=$(ANCHOR_CLUSTER_TABLE) \
		table.ifn=$(SC_TABLE) \
		anchor2ref.dir=$(SC_ANCHOR2REF_DIR) \
		ref2anchor.dir=$(SC_REF2ANCHOR_DIR) \
		gene.table.ifn=$(GENEBANK_TABLE) \
		length=$(SC_FRAGMENT_LENGTH) \
		ofn=$(SC_SUMMARY) \
		ofn.unique=$(SC_SUMMARY_UNIQUE)
	$(_end_touch)
sc_summary: $(SC_SUMMARY_DONE)

###########################################################
# mean gene identity over genomes for best hit
###########################################################

SC_GENES_DONE?=$(SC_DIR)/.done_genes
$(SC_GENES_DONE): $(SC_ANCHOR2REF_DONE) $(SC_REF2ANCHOR_DONE)
	$(call _start,$(SC_GENES_DIR))
	$(_start)
	perl $(_md)/pl/sc_genes.pl \
		$(SC_SUMMARY_UNIQUE) \
		$(CONTIG_TABLE) \
		$(GENE_TABLE) \
		$(CA_ANCHOR_GENES) \
		$(SC_FRAGMENT_LENGTH) \
		$(SC_ANCHOR2REF_DIR) \
		$(SC_GENE_TABLE)
	$(_end_touch)
sc_genes: $(SC_GENES_DONE)

# compute cores
SC_CORES_DONE?=$(ELEMENT_DIR)/.done_core_select
$(SC_CORES_DONE): $(SC_GENES_DONE)
	$(call _start,$(ELEMENT_DIR))
	$(_R) R/compute_cores.r compute.cores \
		ifn.ref=$(SC_GENE_TABLE) \
		ifn.genes=$(GENE_TABLE) \
		ifn.ga=$(CA_ANCHOR_GENES) \
		ifn.checkm=$(CHECKM_QA) \
		identity.threshold=$(SC_IDENTITY_THRESHOLD) \
		min.core.percent=$(SC_MIN_CORE_PERCENTAGE) \
		min.complete=$(CHECKM_MIN_COMPLETE) \
		max.contam=$(CHECKM_MAX_CONTAM) \
		ofn.core.base.table=$(SC_CORE_BASE_TABLE) \
		ofn.core.table=$(SC_CORE_TABLE) \
		ofn.core.genes=$(SC_CORE_GENES)
	$(_end_touch)
sc_cores: $(SC_CORES_DONE)

# compute elements
SC_ELEMENTS_DONE?=$(ELEMENT_DIR)/.done_elements
$(SC_ELEMENTS_DONE): $(SC_CORES_DONE)
	$(_start)
	$(_R) R/compute_elements.r compute.elements \
		ifn.genes=$(GENE_TABLE) \
		ifn.ga=$(CA_ANCHOR_GENES) \
		ifn.core.table=$(SC_CORE_TABLE) \
		ifn.core.genes=$(SC_CORE_GENES) \
		ofn.element.table=$(SC_ELEMENT_TABLE) \
		ofn.ge=$(SC_GENE_ELEMENT) \
		ofn.ge.shared=$(SC_GENE_ELEMENT_SHARED) \
		ofn.ea=$(SC_ELEMENT_ANCHOR)
	$(_end_touch)
sc_elements: $(SC_ELEMENTS_DONE)

# generate element gene table
SC_ELEMENT_GENES_DONE?=$(ELEMENT_DIR)/.done_element_genes
$(SC_ELEMENT_GENES_DONE): $(SC_ELEMENTS_DONE)
	$(_start)
	$(_R) R/element_genes.r element.genes \
		ifn.uniref=$(UNIREF_GENE_TAX_TABLE) \
		ifn.elements=$(SC_ELEMENT_TABLE) \
		ifn.ge=$(SC_GENE_ELEMENT) \
		ofn=$(SC_ELEMENT_GENE_TABLE)
	$(_end_touch)
sc_element_genes: $(SC_ELEMENT_GENES_DONE)

###########################################################

make_taxa: \
$(TAXA_REP_PATH_DONE) $(TAXA_RESOLVE_DONE) $(TAXA_GENOMES_DONE) $(TAXA_REP_LEGEND_DONE) \
$(SC_SUMMARY_DONE) $(SC_ELEMENTS_GENES_DONE)


