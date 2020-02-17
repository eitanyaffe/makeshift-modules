units=nlv_basic.mk nlv_test.mk nlv_bins.mk nlv_traject.mk nlv_plots.mk
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
NLV_INPUT_CONTIG2BIN?=$(BINS_CONTIG_TABLE_ASSOCIATED)

# gene table
NLV_INPUT_GENE_TABLE?=$(GENE_TABLE)

# sample table (lib/Meas_Type/Samp_Date/Event_Key)
NLV_LIB_TABLE?=$(SUBJECT_SAMPLE_DEFS)

# output dir
NLV_VER?=v3
NLV_DIR?=$(ASSEMBLY_DIR)/nlv_$(NLV_VER)

# figure dir
NLV_FDIR?=$(BASE_FDIR)/nlv_$(NLV_VER)

#####################################################################################################
# construct NLV per library
#####################################################################################################

# map fastq results are here
NLV_MAPDIR?=$(PARSE_DIR)

NLV_MIN_SCORE?=30
NLV_MIN_MATCH_LENGTH?=50
NLV_MAX_EDIT_DISTANCE?=3
NLV_DISCARD_CLIPPED?=T

NLV_LIB_DIR?=$(NLV_DIR)/libs/$(LIB_ID)

# NLV data-structure
NLV_DS?=$(NLV_LIB_DIR)/lib.nlv

# go over multiple libs
NLV_IDS?=i1 i2 i3

#####################################################################################################
# combine libs into lib set
#####################################################################################################

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

# table with filenames of nls files
NLV_LIB_TABLE?=$(NLV_SET_DIR)/nlv.table

#####################################################################################################
# divergence between two lib sets
#####################################################################################################

NLV_SET1?=s1
NLV_SET2?=s2

NLV_SET_DS1?=$(call reval,NLV_SET_DS,NLV_SET=$(NLV_SET1))
NLV_SET_DS2?=$(call reval,NLV_SET_DS,NLV_SET=$(NLV_SET2))

# report divergence if the total coverage is above threshold on both sets
NLV_DIVERGE_MIN_COVERAGE?=3

# single merged snp table
NLV_DIVERGE_DIR?=$(NLV_SET_BASEDIR)/diverge/$(NLV_SET1)_$(NLV_SET2)
NLV_DIVERGE_TABLE?=$(NLV_DIVERGE_DIR)/nlv.tab

#####################################################################################################
# segregating sites in a single lib set
#####################################################################################################

NLV_SEGREGATE_MIN_COVERAGE?=3
NLV_SEGREGATE_MAX_FREQUENCY?=0.8
NLV_SEGREGATE_TABLE?=$(NLV_SET_DIR)/segragate.tab

#####################################################################################################
# mask sites using co-abundance data
#####################################################################################################

NLV_MASK_TABLE?=$(COV_SEGMENT_TABLE)
NLV_MASK_FIELD?=is_outlier
NLV_MASK_VALUE?=T

NLV_DIVERGE_TABLE_MASKED?=$(NLV_DIVERGE_DIR)/nlv.tab.masked
NLV_SEGREGATE_TABLE_MASKED?=$(NLV_SET_DIR)/segragate.tab.masked

#####################################################################################################
# bins
#####################################################################################################

# keep margin from contig sides
NLV_BIN_MARGIN?=200

# generate bin segments
NLV_BIN_SEGMENTS?=$(NLV_DIR)/bin.segments

# show effective size per bin
NLV_BIN_BASE?=$(NLV_DIR)/bin.summary

# before filtering
NLV_BIN_DIVERGE_SITES_BASE?=$(NLV_DIVERGE_DIR)/bin_base.sites

# bin x-coverage, per libset
NLV_BIN_COVERAGE?=$(NLV_SET_DIR)/bin.xcov
NLV_BIN_COVERAGE1?=$(call reval,NLV_BIN_COVERAGE,NLV_SET=$(NLV_SET1))
NLV_BIN_COVERAGE2?=$(call reval,NLV_BIN_COVERAGE,NLV_SET=$(NLV_SET2))

# major alleles must be above frequency to qualify for a divergent site
NLV_DIVERGENCE_MAJOR_MIN_FREQUENCY?=0.9

# total coverage must be within percentile range of bin coverage disribution
# for segregating and divergent sites
NLV_COV_MIN_P=p0
NLV_COV_MAX_P=p100

# bin divergence table and sites
NLV_BIN_DIVERGE_TABLE?=$(NLV_DIVERGE_DIR)/bin.tab
NLV_BIN_DIVERGE_SITES?=$(NLV_DIVERGE_DIR)/bin.sites

# before filtering
NLV_BIN_SEGREGATE_SITES_BASE?=$(NLV_SET_DIR)/bin_segregate_base.sites

# bin segregating table
NLV_BIN_SEGREGATE_TABLE?=$(NLV_SET_DIR)/bin_segregate.tab
NLV_BIN_SEGREGATE_SITES?=$(NLV_SET_DIR)/bin_segregate.sites

#####################################################################################################
# collect data across all lib sets
#####################################################################################################

# bin/libset attributes: coverage and segregating sites
NLV_BIN_SET_SUMMARY?=$(NLV_SET_BASEDIR)/libset.summary

# bin/libset pair attributes: divergence
NLV_BIN_SET_PAIR_SUMMARY?=$(NLV_SET_BASEDIR)/libset_pair.summary

# unique diverging and segregating sites in any libset
NLV_DIVERGE_SITES?=$(NLV_SET_BASEDIR)/diverge.sites
NLV_SEGREGATE_SITES?=$(NLV_SET_BASEDIR)/segregate.sites

#####################################################################################################
# nlv trajectories
#####################################################################################################

# per set
NLV_TRJ_DIVERGE?=$(NLV_SET_DIR)/trj_diverge

# single trajectory matrix
NLV_TRJ_DIVERGE_MAT_COUNT?=$(NLV_SET_BASEDIR)/div_mat_count
NLV_TRJ_DIVERGE_MAT_TOTAL?=$(NLV_SET_BASEDIR)/div_mat_total
