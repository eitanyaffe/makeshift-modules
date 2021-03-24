nlv_init:
	cd $(_md)/cpp && $(MAKE) nlv
	mkdir -p $(dir $(NLV_BIN)) && cp $(_md)/cpp/nlv $(NLV_BIN)
