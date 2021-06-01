####################################################################################
# index is one per assembly
####################################################################################

S_MAP_INDEX_DONE?=$(MAP_SET_DIR)/.done_index
$(S_MAP_INDEX_DONE):
	$(_start)
	$(MAKE) m=par par \
		PAR_MODULE=map \
		PAR_NAME=map_index \
		PAR_MACHINE=$(MAP_INDEX_MACHINE_TYPE) \
		PAR_DISK_TYPE=pd-ssd \
		PAR_DISK_GB=32 \
		PAR_WORK_DIR=$(MAP_SET_DIR) \
		PAR_ODIR_VAR=MAP_INDEX_DIR \
		PAR_TARGET=map_index \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_map_index: $(S_MAP_INDEX_DONE)

####################################################################################
# multiple libs per assembly
####################################################################################

S_MAP_INPUT_DONE?=$(MAP_INFO_DIR)/.done_input
$(S_MAP_INPUT_DONE):
	$(call _start,$(MAP_INFO_DIR))
	$(MAKE) m=par par \
		PAR_MODULE=map \
		PAR_NAME=map_input \
		PAR_MACHINE=$(MAP_INPUT_MACHINE_TYPE) \
		PAR_DISK_TYPE=pd-ssd \
		PAR_DISK_GB=64 \
		PAR_WORK_DIR=$(MAP_INFO_DIR) \
		PAR_ODIR_VAR=MAP_SPLIT_DIR \
		PAR_TARGET=map_split \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_map_input: $(S_MAP_INPUT_DONE)

S_MAP_CHUNKS_MGR_DONE?=$(MAP_INFO_DIR)/.done_chunks_mgr
$(S_MAP_CHUNKS_MGR_DONE): $(S_MAP_INPUT_DONE) $(S_MAP_INDEX_DONE)
	$(_start)
	$(MAKE) m=par par \
		PAR_MODULE=map \
		PAR_NAME=map_chunk_mgr \
		PAR_TARGET=map_chunks \
		PAR_WORK_DIR=$(MAP_INFO_DIR) \
		PAR_ODIR_VAR=MAP_INFO_DIR \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_map_chunks_mgr: $(S_MAP_CHUNKS_MGR_DONE)

S_MAP_MERGE_DONE?=$(MAP_INFO_DIR)/.done_merge
$(S_MAP_MERGE_DONE): $(S_MAP_CHUNKS_MGR_DONE)
	$(_start)
	$(MAKE) m=par par \
		PAR_MODULE=map \
		PAR_NAME=map_merge \
		PAR_MACHINE=$(MAP_MERGE_MACHINE_TYPE) \
		PAR_DISK_TYPE=pd-ssd \
		PAR_DISK_GB=32 \
		PAR_WORK_DIR=$(MAP_INFO_DIR) \
		PAR_ODIR_VAR=MAP_OUT_DIR \
		PAR_TARGET=map_merge \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_map_merge: $(S_MAP_MERGE_DONE)

S_MAP_CLEAN_DONE?=$(MAP_INFO_DIR)/.done_clean
$(S_MAP_CLEAN_DONE): $(S_MAP_MERGE_DONE)
	$(_start)
	$(MAKE) m=par par_delete_find \
		PAR_REMOVE_DIR=$(MAP_SPLIT_DIR) \
		PAR_REMOVE_NAME_PATTERN="*fastq"
	$(MAKE) m=par par_delete_find \
		PAR_REMOVE_DIR=$(MAP_CHUNKS_DIR) \
		PAR_REMOVE_NAME_PATTERN="*bam"
	$(MAKE) m=par par_delete_find \
		PAR_REMOVE_DIR=$(MAP_CHUNKS_DIR) \
		PAR_REMOVE_NAME_PATTERN="*sam"
	$(MAKE) m=par par_delete_find \
		PAR_REMOVE_DIR=$(MAP_CHUNKS_DIR) \
		PAR_REMOVE_NAME_PATTERN="*tab"
	$(MAKE) m=par par_delete_find \
		PAR_REMOVE_DIR=$(MAP_CHUNKS_DIR) \
		PAR_REMOVE_NAME_PATTERN="*filtered"
	$(_end_touch)
s_map_clean: $(S_MAP_CLEAN_DONE)

s_map: $(S_MAP_CLEAN_DONE)
