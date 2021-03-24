include $(MAKESHIFT_ROOT)/makeshift-core/makeshift.mk

# build separate binary per server
_binary_suffix=$(shell hostname)

#####################################################################################################
# parameters
#####################################################################################################

# input lib
LIB_ID=full_S1

LIB_INPUT_STYLE=files
LIB_INPUT_R1=/relman03/work/users/eitany/tempo/subjects/AAB/libs/$(LIB_ID)/final/R1.fastq
LIB_INPUT_R2=/relman03/work/users/eitany/tempo/subjects/AAB/libs/$(LIB_ID)/final/R2.fastq

# lib prep method for removing adapters
TRIMMOMATIC_ADAPTER_SFN=TruSeq3-PE-2.fa

# output directory
OUTPUT_DIR=$(CURDIR)/output

# distrib parameters
QSUB_LIB_DIR=$(CURDIR)/temp_files/libs/$(LIB_ID)
MAX_JOBS_FN=$(CURDIR)/max_jobs
DTYPE=par

#####################################################################################################
# modules
#####################################################################################################

# contig binning
$(call _module_root,metagenomics/libs)

$(call _active_module,$(m))

#####################################################################################################
# rules
#####################################################################################################

p_lib:
	@$(MAKE) m=libs trimmomatic dups deconseq lib_final LIB_INPUT_STYLE=files
