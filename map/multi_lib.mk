map_libs:
	$(_Rcall) $(CURDIR) $(_md)/R/multi_libs.r map.libs \
		ifn.table=$(LIB_TABLE) \
		label=$(POP_LABEL)

vari_libs:
	$(_Rcall) $(CURDIR) $(_md)/R/multi_libs.r map.libs \
		ifn.table=$(LIB_TABLE) \
		label=$(POP_LABEL)
