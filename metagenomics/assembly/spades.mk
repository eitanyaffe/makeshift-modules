# to get spades to work files must be imported
SPADES_YAML_DONE?=$(SPADES_DIR)/.done_spades_yaml
$(SPADES_YAML_DONE):
	$(call _start,$(SPADES_DIR))
	perl $(_md)/pl/generate_spades_yaml.pl \
		$(SPADE_YAML) \
		$(ASSEMBLY_INPUT_NAME_PATTERN) \
		$(ASSEMBLY_INPUT_DIRS)
	$(_end_touch)
spades_yaml: $(SPADES_YAML_DONE)

SPADES_DONE?=$(SPADES_DIR)/.done_spades
$(SPADES_DONE): $(SPADES_YAML_DONE)
	$(_start)
	$(call _time,$(SPADES_DIR),spades) \
	$(SPADES_BIN) --meta --only-assembler \
		-t $(SPADE_THREADS) \
		-m $(SPADE_MEM) \
		-o $(SPADES_DIR) \
		--dataset $(SPADE_YAML)
	$(_end_touch)
spades: $(SPADES_DONE)
