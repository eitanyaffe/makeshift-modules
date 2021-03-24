rr = NULL
gg = c(52,171,174,148,161,111)
ids = c("03", "05", "06", "09", "12", "18")
for (i in 1:6) {
    df = read.delim(sprintf("/relman02/work/projects/mpipe/systems/S2_0%s/assembly/megahit/cov_v3/analysis/marginal_v1/contigs.tab", ids[i]))
    ll = sum(df$length)/(10*10^6)
    rr = rbind(rr, data.frame(id=ids[i], amr=gg[i], density=gg[i]/ll))
}

gg = c(127, 71, 204, 76)
ids = c("EAQ", "EBF", "DBU", "AAB")
for (i in 1:4) {
    df = read.delim(sprintf("/relman03/work/users/eitany/tempo/subjects/%s/assembly/megahit/cov_v3/analysis/marginal_v1/contigs.tab", ids[i]))
    ll = sum(df$length)/(10*10^6)
    rr = rbind(rr, data.frame(id=ids[i], amr=gg[i], density=gg[i]/ll))
}
