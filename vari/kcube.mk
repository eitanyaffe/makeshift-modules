KCUBE=/home/eitany/work/kcube/kcube

KCUBE_CREATE_DONE?=$(CUBE_DIR)/.done_create
$(KCUBE_CREATE_DONE):
	$(call _start,$(CUBE_DIR))
	$(MAKECUBE_BIN) create \
		-ksize $(CUBE_KSIZE) \
		-read_dir $(CUBE_READ_INPUT_DIR) \
		-read_pattern $(CUBE_READ_INPUT_PATTERN) \
		-data $(CUBE_FILE)
	$(_end_touch)
create_cube: $(KCUBE_CREATE_DONE)
