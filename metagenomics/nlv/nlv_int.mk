units=nlv_compile.mk nlv_basic.mk nlv_sites.mk nlv_bins.mk nlv_traject.mk \
nlv_plots.mk nlv_strainfinder.mk nlv_genes.mk
$(call _register_module,nlv,$(units),)

#####################################################################################################
# basic input/output
#####################################################################################################

# contig table
NLV_INPUT_CONTIG_TABLE?=$(CONTIG_TABLE)

# contig fasta
NLV_INPUT_CONTIG_FASTA?=$(CONTIG_FASTA)

# bin table
NLV_INPUT_BIN_TABLE?=$(BINS_TABLE)
NLV_INPUT_CONTIG2BIN?=$(C2B_TABLE)

# gene table
NLV_INPUT_GENE_TABLE?=$(GENE_TABLE)
NLV_INPUT_GENE_UNIREF?=$(UNIREF_GENE_TAX_TABLE)

# sample table:
# HMD: (lib/Meas_Type/Samp_Date/Event_Key)
# Brooks: (sample/infant/location)
NLV_LIB_INPUT_TYPE?=HMD
NLV_LIB_INPUT_TABLE?=$(SUBJECT_SAMPLE_DEFS)

# output dir
NLV_VER?=v9
NLV_DIR?=$(ASSEMBLY_DIR)/nlv_$(NLV_VER)

# figure dir
NLV_FDIR?=$(BASE_FDIR)/nlv_$(NLV_VER)/N$(NLV_SET_COUNT)_$(NLV_TRJ_TYPE)

#####################################################################################################
# binary
#####################################################################################################

NLV_BIN=$(_md)/bin.$(shell hostname)/nlv

#####################################################################################################
# construct NLV per library
#####################################################################################################

# tedt construct parameters
# NLV_VER=test_ctr NLV_MIN_SCORE=30 NLV_MIN_MATCH_LENGTH=50 NLV_MAX_EDIT_DISTANCE=3 NLV_DISCARD_CLIPPED=T

# map fastq results are here
NLV_MAPDIR?=$(PARSE_DIR)

NLV_MIN_SCORE?=60
NLV_MIN_MATCH_LENGTH?=100
NLV_MAX_EDIT_DISTANCE?=3
NLV_DISCARD_CLIPPED?=T

NLV_LIB_DIR?=$(NLV_DIR)/libs/$(LIB_ID)

# NLV data-structure
NLV_DS?=$(NLV_LIB_DIR)/lib.nlv

# go over multiple libs
NLV_IDS?=i1 i2 i3

#####################################################################################################
# nlv restrict to hosts
#####################################################################################################

# select host bins
NLV_BIN_FIELD?=class
NLV_BIN_VALUE?=host

# host contigs
NLV_RESTRICT_C2B?=$(NLV_DIR)/c2b_restricted

# nlv restricted to host contigs
NLV_RESTRICT_DS?=$(NLV_LIB_DIR)/hosts.nlv
#NLV_RESTRICT_DS?=$(NLV_SET_DIR)/hosts.nlv

#####################################################################################################
# combine libs into lib set
#####################################################################################################

# NLV_SET_COUNT=7

# number of libs in set
NLV_SET_COUNT?=1

NLV_SET_BASEDIR?=$(NLV_DIR)/sets_N$(NLV_SET_COUNT)

# lib set definitions
NLV_SET_DEFS?=$(NLV_SET_BASEDIR)/table

# avoid combining samples with different keys in the same set
NLV_RESPECT_KEYS?=T

# set label and ids
NLV_SET?=s1
NLV_SET_IDS?=M3189 M3190 M3191
NLV_SET_DIR?=$(NLV_SET_BASEDIR)/sets/$(NLV_SET)

# combine libs: nlv
NLV_SET_DS?=$(NLV_SET_DIR)/set.nlv

# table with all cov files
NLV_LIB_TABLE?=$(NLV_SET_BASEDIR)/nlv.table

# export sets
NLV_EXPORT_SETS?=$(shell tail -n +2 $(NLV_LIB_TABLE) | awk 'BEGIN { OFS = ""; ORS = " " } { print "NLV_DS_", $$1, "=", $$2 }')
NLV_EXPORT_ID?=N$(NLV_SET_COUNT)

#####################################################################################################
# extract segregating sites across all sets
#####################################################################################################

# at least two variations must have this number of supporting reads
NLV_SITES_MIN_VAR_COUNT?=10

# minimal unique samples variation appeared in
NLV_SITES_MIN_SAMPLES?=1

# minimal total coverage of site
NLV_SITES_MIN_TOTAL_COUNT?=20

# p-value threshold
NLV_SITES_P_VALUE?=0.01

# contig/coord/major-var/minor-var/other-vars
NLV_SITES?=$(NLV_SET_BASEDIR)/sites

#####################################################################################################
# divergence between two lib sets
#####################################################################################################

NLV_SET1?=s1
NLV_SET2?=s2

NLV_SET_DS1?=$(call reval,NLV_SET_DS,NLV_SET=$(NLV_SET1))
NLV_SET_DS2?=$(call reval,NLV_SET_DS,NLV_SET=$(NLV_SET2))

# perform Yate's correct
NLV_DIVERGE_YATES_CORRECT?=T

# single merged snp table
NLV_DIVERGE_BASE_DIR?=$(NLV_SET_BASEDIR)/diverge
NLV_DIVERGE_DIR?=$(NLV_DIVERGE_BASE_DIR)/$(NLV_SET1)_$(NLV_SET2)
NLV_DIVERGE_TABLE?=$(NLV_DIVERGE_DIR)/div.tab

#####################################################################################################
# segregating sites in a single lib set
#####################################################################################################

NLV_SEGREGATE_MIN_COVERAGE?=10
NLV_SEGREGATE_MAX_FREQUENCY?=0.8

NLV_SEGREGATE_BASE_DIR?=$(NLV_SET_BASEDIR)/segregate
NLV_SEGREGATE_DIR?=$(NLV_SEGREGATE_BASE_DIR)/$(NLV_SET)
NLV_SEGREGATE_TABLE?=$(NLV_SEGREGATE_DIR)/seg.tab

#####################################################################################################
# bins
#####################################################################################################

# keep margin from contig sides
NLV_BIN_MARGIN?=300

NLV_BIN_DIR?=$(NLV_SET_BASEDIR)/bins

# generate bin segments
NLV_BIN_SEGMENTS?=$(NLV_BIN_DIR)/bin.segments

# show effective size per bin
NLV_BIN_BASE?=$(NLV_BIN_DIR)/bin.summary

# before filtering
NLV_BIN_DIVERGE_SITES_BASE?=$(NLV_DIVERGE_DIR)/bin_base.sites

NLV_BIN_COVERAGE_DIR?=$(NLV_BIN_DIR)/coverage/$(NLV_SET)

# bin x-coverage, per libset
NLV_BIN_COVERAGE_DIR?=$(NLV_BIN_DIR)/coverage/$(NLV_SET)
NLV_BIN_COVERAGE?=$(NLV_BIN_COVERAGE_DIR)/bin.xcov
NLV_BIN_COVERAGE1?=$(call reval,NLV_BIN_COVERAGE,NLV_SET=$(NLV_SET1))
NLV_BIN_COVERAGE2?=$(call reval,NLV_BIN_COVERAGE,NLV_SET=$(NLV_SET2))

# Chi-Square P-value threshold to classify site as diverged between two samples
NLV_DIVERGE_P_VALUE?=0.05

# major alleles must be above frequency to qualify for a divergent site
NLV_DIVERGE_MAJOR_MIN_FREQUENCY?=0.8

# total coverage must be within percentile range of bin coverage disribution
# for segregating and divergent sites
NLV_COV_MIN_P=p0
NLV_COV_MAX_P=p100

# bin divergence table and sites
NLV_BIN_DIVERGE_TABLE?=$(NLV_DIVERGE_DIR)/bin.tab
NLV_BIN_DIVERGE_SITES?=$(NLV_DIVERGE_DIR)/bin.sites

# before filtering
NLV_BIN_SEGREGATE_SITES_BASE?=$(NLV_SEGREGATE_DIR)/bin_segregate_base.sites

# bin segregating table
NLV_BIN_SEGREGATE_TABLE?=$(NLV_SEGREGATE_DIR)/bin_segregate.tab
NLV_BIN_SEGREGATE_SITES?=$(NLV_SEGREGATE_DIR)/bin_segregate.sites

#####################################################################################################
# collect data across all lib sets
#####################################################################################################

# bin/libset attributes: coverage and segregating sites
NLV_BIN_SET_SUMMARY?=$(NLV_BIN_DIR)/libset.summary

# bin/libset pair attributes: divergence
NLV_BIN_SET_PAIR_SUMMARY?=$(NLV_BIN_DIR)/libset_pair.summary

# unique diverging and segregating sites in any libset
NLV_DIVERGE_SITES?=$(NLV_BIN_DIR)/diverge.sites
NLV_SEGREGATE_SITES?=$(NLV_BIN_DIR)/segregate.sites

# seg and div
NLV_COMBINED_SITES?=$(NLV_BIN_DIR)/combined.sites

# summary by bins
NLV_COMBINED_SITES_BINS?=$(NLV_BIN_DIR)/combined.sites.bins

#####################################################################################################
# distance matrix
#####################################################################################################

NLV_DISTANCE_MATRIX?=$(NLV_BIN_DIR)/distance.mat

#####################################################################################################
# nlv snp trajectories
#####################################################################################################

# all: all dyamics sites
# div: focus on divergence
# combined: divergent and segragating sites
NLV_TRJ_TYPE?=combo

ifeq ($(NLV_TRJ_TYPE),all)
NLV_TRJ_INPUT_BASE?=$(NLV_SITES)
NLV_TRJ_FIELD?=major
else ifeq ($(NLV_TRJ_TYPE),div)
NLV_TRJ_INPUT_BASE?=$(NLV_DIVERGE_SITES)
NLV_TRJ_FIELD?=var
else ifeq ($(NLV_TRJ_TYPE),combo)
NLV_TRJ_INPUT_BASE?=$(NLV_COMBINED_SITES)
NLV_TRJ_FIELD?=var
endif

# use sites of N7
NLV_TRJ_SET_COUNT?=7
NLV_TRJ_INPUT=$(call reval,NLV_TRJ_INPUT_BASE,NLV_SET_COUNT=$(NLV_TRJ_SET_COUNT))

NLV_TRJ_BASE_DIR?=$(NLV_BIN_DIR)/trajectory/$(NLV_TRJ_TYPE)_N$(NLV_TRJ_SET_COUNT)
NLV_TRJ_DIR?=$(NLV_TRJ_BASE_DIR)/$(NLV_SET)

# query per set
NLV_TRJ_SITES?=$(NLV_TRJ_DIR)/sites

# single trajectory matrix
NLV_TRJ_MAT_COUNT?=$(NLV_TRJ_BASE_DIR)/div_mat_count
NLV_TRJ_MAT_TOTAL?=$(NLV_TRJ_BASE_DIR)/div_mat_total

NLV_TRJ_MAT_COUNT_BINS?=$(NLV_TRJ_BASE_DIR)/div_mat_count.bins
NLV_TRJ_MAT_TOTAL_BINS?=$(NLV_TRJ_BASE_DIR)/div_mat_total.bins

# track frequencies of N7 divergent sites
NLV_FREQ_SET_COUNT?=7
NLV_FREQ_DIVERGE_INPUT=$(call reval,NLV_DIVERGE_SITES,NLV_SET_COUNT=$(NLV_FREQ_SET_COUNT))
NLV_FREQ_SEGREGATE_INPUT=$(call reval,NLV_SEGREGATE_SITES,NLV_SET_COUNT=$(NLV_FREQ_SET_COUNT))

#####################################################################################################
# nlv genes
#####################################################################################################

NLV_GENES_SITES?=$(NLV_TRJ_INPUT)

NLV_GENES_DIR?=$(NLV_BIN_DIR)/genes
NLV_GENES_TABLE?=$(NLV_GENES_DIR)/uniref.txt

#####################################################################################################
# strain finder
#####################################################################################################

NLV_STRAIN_FINDER_DIR?=/home/eitany/work/git_root/StrainFinder
NLV_STRAIN_FINDER_PYTHON?=$(NLV_STRAIN_FINDER_DIR)/venv/bin/python
NLV_STRAIN_FINDER_COMMAND?=$(NLV_STRAIN_FINDER_PYTHON) $(NLV_STRAIN_FINDER_DIR)/StrainFinder.py

STRAIN_VER?=v2
STRAIN_DIR?=$(NLV_BIN_DIR)/strains/$(STRAIN_VER)
STRAIN_SET_BASE_DIR?=$(STRAIN_DIR)/sets
STRAIN_SET_DIR?=$(STRAIN_SET_BASE_DIR)/$(NLV_SET)

# basic nlv query result
STRAIN_SET_NTS?=$(STRAIN_SET_DIR)/nts

# ACGT table
STRAIN_SET_TAB?=$(STRAIN_SET_DIR)/nts.tab

# base
STRAIN_A_TAB?=$(STRAIN_DIR)/A.tab
STRAIN_C_TAB?=$(STRAIN_DIR)/C.tab
STRAIN_G_TAB?=$(STRAIN_DIR)/G.tab
STRAIN_T_TAB?=$(STRAIN_DIR)/T.tab

# with bins
STRAIN_A_BINNED?=$(STRAIN_DIR)/A.binned
STRAIN_C_BINNED?=$(STRAIN_DIR)/C.binned
STRAIN_G_BINNED?=$(STRAIN_DIR)/G.binned
STRAIN_T_BINNED?=$(STRAIN_DIR)/T.binned

# host bins and number of sites per bin
STRAIN_BIN_TABLE?=$(STRAIN_DIR)/bin.table

# max SNPs per bin
STRAIN_BIN_MAX_SNPS?=4000

# limit to bins with not too many SNPs
STRAIN_BIN_TABLE_LIMITED?=$(STRAIN_DIR)/bin_limited.table

STRAIN_BIN?=1604
STRAIN_BIN_BASE_DIR?=$(STRAIN_DIR)/bins
STRAIN_BIN_DIR?=$(STRAIN_BIN_BASE_DIR)/$(STRAIN_BIN)

# n_sites, n_samples
STRAIN_DIMS?=$(STRAIN_BIN_DIR)/params

# cPickle [n_samples,n_sites,4]
STRAIN_INPUT?=$(STRAIN_BIN_DIR)/input.cPickle

# StrainFinder parameters
STRAIN_FINDER_N?=5
STRAIN_FINDER_N_MAX?=5

STRAIN_FINDER_TAG?=N$(STRAIN_FINDER_N)
STRAIN_RUN_BASE_DIR?=$(STRAIN_BIN_DIR)/runs
STRAIN_RUN_DIR?=$(STRAIN_RUN_BASE_DIR)/$(STRAIN_FINDER_TAG)

STRAIN_BIN_SELECT_DIR?=$(STRAIN_BIN_DIR)/select_$(STRAIN_FINDER_N_MAX)

# BIC/AIC scores
STRAIN_RESULT_LL_TABLE?=$(STRAIN_BIN_DIR)/ll.tab

# select strain table
#STRAIN_CRITERIA?=BIC
STRAIN_CRITERIA?=AIC
STRAIN_RESULT_TABLE?=$(STRAIN_BIN_SELECT_DIR)/strain_$(STRAIN_CRITERIA).tab

# strain nts
STRAIN_RESULT_NTS?=$(STRAIN_BIN_SELECT_DIR)/strain_$(STRAIN_CRITERIA).nts

# position classification by strain membership
STRAIN_RESULT_CLASS?=$(STRAIN_BIN_SELECT_DIR)/strain_$(STRAIN_CRITERIA).class

# t-SNE result table
NLV_TSNE_SITES=$(STRAIN_DIR)/tsne.sites
NLV_TSNE_BINS=$(STRAIN_DIR)/tsne.bins
