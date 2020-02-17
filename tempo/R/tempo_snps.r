create.lib.set.table=function(ifn, n.libs, ofn)
{
    df = load.table(ifn)
    if (any(is.na(df$Abx_RelDay))) {
        N = dim(df)[1]
        base.ids = df$Meas_ID[1:n.libs]
        mid.ids = df$Meas_ID[round(1:n.libs + N/2)]
        post.ids = df$Meas_ID[N - n.libs:1 + 1]
    } else {
        base.ids = df$Meas_ID[df$Abx_RelDay <= 0]
        base.ids = base.ids[length(base.ids) - n.libs:1 + 1]
        mid.ids = df$Meas_ID[df$Abx_Interval == "MidAbx"]
        post.ids = df$Meas_ID[dim(df)[1] - n.libs:1 + 1]
    }
    if (length(base.ids) != n.libs || length(post.ids) != n.libs)
        stop("not enough libs meet conditions")
    result = rbind(data.frame(group="base", lib=base.ids), data.frame(group="mid", lib=mid.ids), data.frame(group="post", lib=post.ids))
    result$sample = df$Samp_ID[match(result$lib, df$Meas_ID)]
    save.table(result, ofn)
}

lib.sets.explode=function(ifn, ofn.base, ofn.mid, ofn.post)
{
    df = load.table(ifn)
    cat(sprintf("writing id file: %s\n", ofn.base))
    write.table(df$lib[df$group=="base"], file=ofn.base, quote=F, row.names=F, col.names=F)
    cat(sprintf("writing id file: %s\n", ofn.mid))
    write.table(df$lib[df$group=="mid"], file=ofn.mid, quote=F, row.names=F, col.names=F)
    cat(sprintf("writing id file: %s\n", ofn.post))
    write.table(df$lib[df$group=="post"], file=ofn.post, quote=F, row.names=F, col.names=F)
}
