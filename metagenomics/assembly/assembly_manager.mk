#####################################################################################################
# assembly steps
#####################################################################################################

S_INPUT_DONE?=$(ASSEMBLY_INFO_DIR)/.done_input
$(S_INPUT_DONE):
	$(call _start,$(ASSEMBLY_INFO_DIR))
	$(MAKE) m=par par \
		PAR_WORK_DIR=$(ASSEMBLY_INFO_DIR) \
		PAR_MODULE=assembly \
		PAR_NAME=assembly_input \
		PAR_ODIR_VAR=ASSEMBLY_INPUT_DIR \
		PAR_TARGET=assembly_input \
		PAR_MACHINE=$(ASSEMBLY_INPUT_MACHINE) \
		PAR_DISK_GB=$(ASSEMBLY_DISK_GB) \
		PAR_DISK_TYPE=$(ASSEMBLY_DISK_TYPE) \
		PAR_PREEMTIBLE=3 \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_assembly_input: $(S_INPUT_DONE)


S_ASSEMBLY_DONE?=$(ASSEMBLY_INFO_DIR)/.done_assembly
$(S_ASSEMBLY_DONE): $(S_INPUT_DONE)
	$(_start)
	$(MAKE) m=par par \
		PAR_WORK_DIR=$(ASSEMBLY_INFO_DIR) \
		PAR_MODULE=assembly \
		PAR_NAME=megahit \
		PAR_ODIR_VAR=ASSEMBLY_WORK_DIR \
		PAR_TARGET=megahit \
		PAR_MACHINE=$(ASSEMBLY_MACHINE) \
		PAR_DISK_GB=$(ASSEMBLY_DISK_GB) \
		PAR_DISK_TYPE=$(ASSEMBLY_DISK_TYPE) \
		PAR_PREEMTIBLE=3 \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_assembly_main: $(S_ASSEMBLY_DONE)

#####################################################################################################
# entire assembly
#####################################################################################################

s_assembly:
	$(MAKE) m=par par \
		PAR_WORK_DIR=$(ASSEMBLY_INFO_DIR) \
		PAR_MODULE=assembly \
		PAR_NAME=assembly_single \
		PAR_ODIR_VAR=ASSEMBLY_INFO_DIR \
		PAR_TARGET=s_assembly_main \
		PAR_PREEMTIBLE=3 \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"

ASSEMBLY_MULTI_DONE?=$(ASSEMBLY_MULTI_DIR)/.done_run
$(ASSEMBLY_MULTI_DONE):
	$(_start)
	$(MAKE) m=par par_tasks_complex \
		PAR_MODULE=assembly \
		PAR_NAME=assembly_task \
		PAR_WORK_DIR=$(ASSEMBLY_MULTI_DIR) \
		PAR_TARGET=s_assembly_main \
		PAR_TASK_ITEM_TABLE=$(ASSEMBLY_TABLE) \
		PAR_TASK_ITEM_VAR=ASSEMBLY_ID \
		PAR_TASK_ODIR_VAR=ASSEMBLY_DIR \
		PAR_PREEMTIBLE=3 \
		PAR_MAKEFLAGS="$(PAR_MAKEOVERRIDES)"
	$(_end_touch)
s_assemblies: $(ASSEMBLY_MULTI_DONE)
