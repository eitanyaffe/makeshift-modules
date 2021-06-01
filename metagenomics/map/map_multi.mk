S_MAP_INPUT_TABLE?=$(MAP_SET_DIR)/.done_input_table
$(S_MAP_INPUT_TABLE):
	$(call _start,$(MAP_SET_DIR))
	$(_R) $(MAP_LIBS_INPUT_SCRIPT) generate.map.table \
		assembly.id=$(ASSEMBLY_ID) \
		ifn=$(LIBS_INPUT_TABLE) \
		idir.var=LIBS_BASE_DIR \
		idir=$(LIBS_BASE_DIR) \
		ofn=$(MAP_LIBS_TABLE)
	$(_end_touch)
s_map_input_table: $(S_MAP_INPUT_TABLE)

S_MAP_SET_DONE?=$(MAP_SET_DIR)/.done_map_set
$(S_MAP_SET_DONE): $(S_MAP_INPUT_TABLE) $(S_MAP_INDEX_DONE)
	$(_start)
	$(MAKE) m=par par_tasks_complex \
		PAR_MODULE=map \
		PAR_NAME=map_task \
		PAR_WORK_DIR=$(MAP_SET_DIR) \
		PAR_TARGET=s_map \
		PAR_TASK_ITEM_TABLE=$(MAP_LIBS_TABLE) \
		PAR_TASK_ITEM_VAR=MAP_LIB_ID \
		PAR_TASK_ODIR_VAR=MAP_INFO_DIR \
		PAR_PREEMTIBLE=0 \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_map_set: $(S_MAP_SET_DONE)

# map libs of all assemblies
S_MAP_ALL_DONE?=$(MAP_MULTI_DIR)/.done_map_all
$(S_MAP_ALL_DONE):
	$(call _start,$(MAP_MULTI_DIR))
	$(MAKE) m=par par_tasks_complex \
		PAR_MODULE=map \
		PAR_NAME=map_assembly \
		PAR_WORK_DIR=$(MAP_MULTI_DIR) \
		PAR_TARGET=s_map_set \
		PAR_TASK_ITEM_TABLE=$(MAP_ASSEMBLY_TABLE) \
		PAR_TASK_ITEM_VAR=ASSEMBLY_ID \
		PAR_TASK_ODIR_VAR=MAP_SET_DIR \
		PAR_PREEMTIBLE=0 \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_map_all: $(S_MAP_ALL_DONE)
