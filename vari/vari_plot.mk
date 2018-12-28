
plot_vari:
	$(_R) $(_md)/R/plot_vari.r plot.single \
		icags=$(CAG_SELECTED) \
		igenes=$(GENE_SELECTED) \
		idir=$(CAG_EXPLODE_DIR) \
		lib.id=$(LIB_ID) \
		fdir=$(BASE_FDIR)/detailed/$(LIB_ID)

plot_all:
	$(_R) $(_md)/R/plot_vari.r plot.all \
		ilibs=$(LIB_TABLE) \
		icags=$(CAG_SELECTED) \
		igenes=$(GENE_SELECTED) \
		base.dir=$(BASEMAP_DIR) \
		fdir=$(BASE_FDIR)/summary
