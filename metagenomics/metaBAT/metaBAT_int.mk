#####################################################################################################
# register module
#####################################################################################################

units:=metaBAT_bam.mk metaBAT_main.mk metaBAT_post.mk metaBAT_checkm.mk \
metaBAT_tsne.mk metaBAT_plot.mk
$(call _register_module,metaBAT,$(units),)

#####################################################################################################
# path to tools used
#####################################################################################################

CHECKM?=checkm

#####################################################################################################
# general parameters
#####################################################################################################

METABAT_VER?=v1
METABAT_DIR?=$(ASSEMBLY_DIR)/metaBAT/$(METABAT_VER)

# input assembly fasta
METABAT_CONTIG_FASTA?=$(CONTIG_FASTA)

# input contig table
METABAT_CONTIG_TABLE?=$(CONTIG_TABLE)

# figures
METABAT_FDIR?=$(BASE_FDIR)/metaBAT/$(METABAT_VER)_$(METABAT_SUB_VER)

# we copy the fasta here
METABAT_CONTIGS?=$(METABAT_DIR)/contigs.fa

METABAT_ID?=sg

# input library bam file, by default use the result of the map module
METABAT_IN_BAM?=$(call reval,MAP_BAM_FILE,LIB_ID=$(METABAT_ID))

#####################################################################################################
# copy multiple bam files
#####################################################################################################

METABAT_LIB_DIR?=$(METABAT_DIR)/libs/$(METABAT_ID)
METABAT_LIB_BAM?=$(METABAT_LIB_DIR)/lib.bam

# process multiple libs
METABAT_IDS?=$(LIB_IDS)
#METABAT_IDS?=full_S1 full_S2 full_S3

#####################################################################################################
# run over bam files creates for a bunch of libs
#####################################################################################################

# by default use all libs
METABAT_MERGE_IDS?=$(METABAT_IDS)
METABAT_BAMS?=$(addsuffix /lib.bam,$(addprefix /work/libs/,$(METABAT_MERGE_IDS)))

#####################################################################################################
# metabat docker setup
#####################################################################################################

METABAT_DCKR_PROFILE=$(METABAT_DIR)/dr_profile

METABAT_OMP_NUM_THREADS?=10

METABAT_IMAGE=metabat/metabat:latest
METABAT_PARAMS=-v /etc/passwd:/etc/passwd -v /etc/shadow:/etc/shadow -v /etc/group:/etc/group
METABAT_DOCKER?=sudo dr run -r $(METABAT_DIR) -p dr_profile -i $(METABAT_IMAGE) nice -n 10

#####################################################################################################
# metabat main
#####################################################################################################

# METABAT_SUB_VER=strict METABAT_OPTIONS=--noAdd METABAT_MAX_EDGES=500 METABAT_MAX_P=91 METABAT_MIN_S=80
# METABAT_SUB_VER=post_filter METABAT_FILTER=T

# contig depth table
METABAT_DEPTH_TABLE?=$(METABAT_DIR)/depth.txt

METABAT_SUB_VER?=post_filter
METABAT_WORK_DIR?=$(METABAT_DIR)/output/$(METABAT_SUB_VER)

# metaBAT min bin size
METABAT_MIN_BIN_SIZE?=2500
METABAT_MIN_CONTIG_SIZE?=2500
METABAT_THREADS?=80

METABAT_MAX_EDGES?=200
METABAT_MAX_P?=95
METABAT_MIN_S?=60

# metabat flags
# --noAdd: Turning off additional binning for lost or small contigs.
#METABAT_OPTIONS?=--noAdd

# for reproducibility
METABAT_SEED?=1

#####################################################################################################
# process metaBAT results
#####################################################################################################

# raw table of contig-bin table
METABAT_TABLE_RAW?=$(METABAT_WORK_DIR)/contig_raw.table

# raw bin summary table
METABAT_BIN_TABLE_RAW?=$(METABAT_WORK_DIR)/bin_raw.table

#####################################################################################################
# compute inter and intra cluster scores
#####################################################################################################

# contig vectors
METABAT_CONTIG_VECTORS?=$(METABAT_WORK_DIR)/contig_vectors

# centroid vectors
METABAT_CENTROID_VECTORS?=$(METABAT_WORK_DIR)/centroid_vectors

#####################################################################################################
# filter out low quality contigs and bins
# NOTE: by default we do not refine bins post metaBAT (METABAT_FILTER=F)
#####################################################################################################

# compute modified z-score per bin using the mean and sd computed on percentiles 10%-90%
# if there are at least 10 contigs in the bin, or all contigs otherwise.
METABAT_CONTIG_SCORE?=$(METABAT_WORK_DIR)/contig_score

# flag that controls post-metaBAT filtering
METABAT_FILTER?=T

# min contig-bin pearson
METABAT_MIN_SCORE?=0.95

# min contig-bin zscore
METABAT_MIN_ZSCORE?=-3

# max fraction of discarded bin
METABAT_MAX_DISCARD_FRACTION?=0.2

METABAT_CONTIG_SELECTED?=$(METABAT_WORK_DIR)/contig_selected
METABAT_BIN_SELECTED?=$(METABAT_WORK_DIR)/bin_selected

#####################################################################################################
# basic contig-bin and bin tables
#####################################################################################################

# final table of contigs/bins
METABAT_TABLE?=$(METABAT_WORK_DIR)/contig_final.table

# bin summary table
METABAT_BIN_TABLE?=$(METABAT_WORK_DIR)/bin_final.table

#####################################################################################################
# inspect bins using checkm
#####################################################################################################

METABAT_CHECKM_THREADS?=80

METABAT_CHECKM_DIR?=$(METABAT_WORK_DIR)/checkm

# select larger bins to assay with check
METABAT_SELECT_BINSIZE?=100000
METABAT_CHECKM_BIN_SELECT?=$(METABAT_CHECKM_DIR)/bins.select

# dir with fasta
METABAT_CHECKM_FASTA_DIR?=$(METABAT_CHECKM_DIR)/fasta

# checkm result
METABAT_CHECKM_RESULT?=$(METABAT_CHECKM_DIR)/bins.result

#####################################################################################################
# classify bins
#####################################################################################################

# classify host bins
METABAT_MIN_GENOME_COMPLETE?=50
METABAT_MAX_GENOME_CONTAM?=10

# classify element bins
METABAT_MAX_ELEMENT_COMPLETE?=5

# final bin table
METABAT_BIN_CLASS?=$(METABAT_WORK_DIR)/bin_classified.table

# t-Sne for contigs
METABAT_TSNE_PERLEXITY?=30
METABAT_TSNE_NTHREADS?=80

# normalize each contig vector to sum to 1
METABAT_TSNE_NORM?=T

# normalize each contig vector to sum to 1
METABAT_TSNE_MIN_CONTIG_LENGTH?=1000

# iterations
METABAT_TSNE_ITERATIONS?=2000

METABAT_TSNE_TAG?=P$(METABAT_TSNE_PERLEXITY)_N$(METABAT_TSNE_NORM)_I$(METABAT_TSNE_ITERATIONS)

METABAT_TSNE_DIR?=$(METABAT_WORK_DIR)/tsne/$(METABAT_TSNE_TAG)
METABAT_TSNE?=$(METABAT_TSNE_DIR)/contig.tsne

METABAT_TSNE_PLOT_TRANSPARENT_PERCENT?=90

METABAT_TSNE_PLOT_NBINS?=400
