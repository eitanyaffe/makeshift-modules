SFILES=$(addprefix $(_md)/cpp/,\
cov.h cov.cpp cov_construct.cpp cov_break_single.cpp cov_break_multi.cpp cov_bin.cpp \
Coverage.h Coverage.cpp \
Dissolve.cpp Dissolve.h \
BinMatrix.h BinMatrix.cpp \
Params.cpp Params.h util.cpp util.h)

#$(eval $(call bin_rule_debug,cov,$(SFILES)))
#$(eval $(call bin_rule2,cov,$(SFILES),-Wno-deprecated -lpthread))
$(eval $(call bin_rule_boost,cov,$(SFILES),-lpthread))

cov_init: $(COV_BIN)
