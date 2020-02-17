include $(MAKESHIFT_ROOT)/makeshift-core/makeshift.mk

# build separate binary per server
_binary_suffix=$(shell hostname)

#####################################################################################################
# parameters
#####################################################################################################

# contig table and fasta
BINS_IN_CONTIG_TABLE=/relman03/work/users/eitany/tempo/subjects/AAB/assembly/megahit/long_contig_table
BINS_IN_CONTIG_FASTA=/relman03/work/users/eitany/tempo/subjects/AAB/assembly/megahit/long_contigs

# input library, function of LIB_ID
PAIRED_R1?=/relman03/work/users/eitany/tempo/subjects/AAB/libs/$(LIB_ID)/final/R1.fastq
PAIRED_R2?=/relman03/work/users/eitany/tempo/subjects/AAB/libs/$(LIB_ID)/final/R2.fastq

# optional overide of bwa index dir, if index already exists
METABAT_INDEX_DIR=/relman03/work/users/eitany/bcc/cipro/assembly/pre_big_megahit/fold_0/map_index/bwa

# lib ids used for binning
BINS_LIB_IDS=full_S1 full_S2 full_S3 full_S4

# all output created under the assembly directory
ASSEMBLY_DIR=$(CURDIR)/output

#####################################################################################################
# modules
#####################################################################################################

# contig binning
$(call _module_root,metagenomics/bins)

# metaBAT, used by bins
$(call _module_root,metaBAT)

$(call _active_module,$(m))

#####################################################################################################
# rules
#####################################################################################################

p_bins:
	@$(MAKE) m=bins make_bins
