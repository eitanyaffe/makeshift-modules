WF_DONE?=$(WF_DIR)/.done
$(WF_DONE):
	$(call _start,$(WF_DIR))
	$(_R) R/wright_fisher.r wf.temporal \
		genome.length=$(WF_GENOME_SIZE) \
		u.per.bp=$(WF_MUTATION_BP_RATE) \
		N2=$(WF_POP_SIZE) \
		end.factor=$(WF_END_FACTOR) \
		step.factor=$(WF_STEP_FACTOR) \
		sample.size=$(WF_SAMPLE_SIZE) \
		ofn=$(WF_TABLE)
	$(_end_touch)
temporal_wf: $(WF_DONE)

WF_POP_DONE?=$(WF_POP_DIR)/.done
$(WF_POP_DONE):
	$(call _start,$(WF_POP_DIR))
	$(_R) R/wright_fisher.r wf.pop \
		genome.length=$(WF_GENOME_SIZE) \
		u.per.bp=$(WF_MUTATION_BP_RATE) \
		N2.begin=$(WF_POP_SIZE_BEGIN) \
		N2.end=$(WF_POP_SIZE_END) \
		N2.logstep=$(WF_POP_SIZE_LOG_STEP) \
		factor=$(WF_POP_FACTOR) \
		sample.size=$(WF_POP_SAMPLE_SIZE) \
		ofn=$(WF_POP_TABLE)
	$(_end_touch)
pop_wf: $(WF_POP_DONE)

make_wf: $(WF_DONE) $(WF_POP_DONE)

wf_plot_temporal:
	$(_R) R/wright_fisher.r wf.plot \
		ifn=$(WF_TABLE) \
		fdir=$(EVO_BASE_FDIR)/wright_fisher/$(WF_TAG)
wf_plot_pop:
	$(_R) R/wright_fisher.r wf.plot.pop \
		ifn=$(WF_POP_TABLE) \
		fdir=$(EVO_BASE_FDIR)/wright_fisher/$(WF_POP_TAG)
plot_wf: wf_plot_temporal wf_plot_pop
