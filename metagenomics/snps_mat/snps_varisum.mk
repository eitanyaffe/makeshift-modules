SFILES=$(addprefix $(_md)/cpp/,snps_varisum.cpp Params.cpp Params.h util.cpp util.h)
$(eval $(call bin_rule2,snps_varisum,$(SFILES)))
VARISUM_BIN=$(_md)/bin.$(shell hostname)/snps_varisum
snps_init: $(VARISUM_BIN)

# TBD snps
# 1. change snps_varisum so that ref
# 1. test snps_varisum on small dataset
# 2. work into snps_basic.
#    - lib sets are simple.
#    - classification is a bit more complex.

# TBD coverage
# 1. add 1-nt coverage data structure, with simple I/O streaming. We would like to load this into memory in an R session
# 2. output entire coverage for separately for each library
