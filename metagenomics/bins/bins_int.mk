#####################################################################################################
# register module
#####################################################################################################

units:=bins_fragments.mk bins_metabat.mk bins_checkm.mk bins_plot.mk
$(call _register_module,bins,$(units),)

#####################################################################################################
# input
#####################################################################################################

# assembly fasta
BINS_IN_CONTIG_FASTA?=$(ASSEMBLY_CONTIG_FILE)
BINS_IN_CONTIG_TABLE?=$(ASSEMBLY_CONTIG_TABLE)

#####################################################################################################
# (i) create fragments
#####################################################################################################

# breakdown: breakdown if over max size
# complete: define fragments to be contigs
BINS_FRAGMENT_SIZE_STYLE?=breakdown

# for breakdown style
BINS_FRAGMENT_BREAKDOWN_SIZE?=10000

ifeq ($(BINS_FRAGMENT_SIZE_STYLE),breakdown)
BINS_LABEL=$(BINS_FRAGMENT_SIZE_STYLE)_$(BINS_FRAGMENT_BREAKDOWN_SIZE)
else
BINS_LABEL=$(BINS_FRAGMENT_SIZE_STYLE)
endif

# output directory
BINS_DIR?=$(ASSEMBLY_DIR)/bins/$(BINS_LABEL)

# output figure directory
BINS_FDIR?=$(BASE_FDIR)/bins

BINS_FRAGMENT_DIR?=$(BINS_DIR)/fragments

# fragment/contig/start/end
BINS_FRAGMENT_TABLE?=$(BINS_FRAGMENT_DIR)/fragments.table

# fragment fasta
BINS_FRAGMENT_FASTA?=$(BINS_FRAGMENT_DIR)/fragments.fa

# metabat contig table, with fragments
BINS_METABAT_CONTIG_TABLE?=$(BINS_FRAGMENT_DIR)/fragments_contig.table

#####################################################################################################
# (ii) metabat module usage
#####################################################################################################

# we cluster fragments
METABAT_IN_CONTIGS?=$(BINS_FRAGMENT_FASTA)
METABAT_IN_CONTIG_TABLE?=$(BINS_METABAT_CONTIG_TABLE)

METABAT_MERGE_IDS=$(BINS_LIB_IDS)

METABAT_IN_R1=$(call reval,PAIRED_R1,LIB_ID=$(METABAT_ID))
METABAT_IN_R2=$(call reval,PAIRED_R2,LIB_ID=$(METABAT_ID))

METABAT_MIN_BIN_SIZE=5000
METABAT_MIN_CONTIG_SIZE=1500
METABAT_DIR=$(BINS_DIR)/metaBAT/$(METABAT_VER)

# metabat output: fragment->bin
BINS_FRAGMENT_BIN?=$(METABAT_TABLE)

# metabat output: bin summary
BINS_FRAGMENT_BIN_SUMMARY?=$(METABAT_BIN_TABLE)

#####################################################################################################
# (iii) group consecutive fragments into segments
#####################################################################################################

# partition contigs according to bins

BINS_OUT_VER?=v1
BINS_OUTPUT_DIR?=$(BINS_DIR)/out_$(BINS_OUT_VER)

# uniting conseq fragments of same bin into a segment table
BINS_SEGMENT_TABLE?=$(BINS_OUTPUT_DIR)/segment_table.base

# final contig table, binned
BINS_CONTIG_TABLE?=$(BINS_OUTPUT_DIR)/contigs.table

# final contig table, with only associated contigs (omitting bin=0)
BINS_CONTIG_TABLE_ASSOCIATED?=$(BINS_OUTPUT_DIR)/contigs_associated.table

# final contig fasta
BINS_CONTIG_FASTA?=$(BINS_OUTPUT_DIR)/contigs.fa

# basic summary of bins
BINS_SUMMARY_BASIC?=$(BINS_OUTPUT_DIR)/summary.basic

#####################################################################################################
# (iv) inspect using checkm
#####################################################################################################

BINS_CHECKM_DIR?=$(BINS_OUTPUT_DIR)/checkm

# select larger bins to assay with check
BINS_SELECT_BINSIZE?=100000
BINS_CHECKM_BIN_SELECT?=$(BINS_CHECKM_DIR)/bins.select

# dir with fasta
BINS_CHECKM_FASTA_DIR?=$(BINS_CHECKM_DIR)/fasta

# checkm result
BINS_CHECKM_RESULT?=$(BINS_CHECKM_DIR)/bins.result

#####################################################################################################
# (v) classify bins
#####################################################################################################

# classify host bins
BINS_MIN_GENOME_COMPLETE?=50
BINS_MAX_GENOME_CONTAM?=10

# classify element bins
BINS_MAX_ELEMENT_COMPLETE?=5

# final bin table
BINS_TABLE?=$(BINS_OUTPUT_DIR)/bins_summary.table
