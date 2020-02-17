plot.host.trajectories=function(ifn.snps, ifn.bins, prefix, fdir)
{
    df = load.table(ifn.snps)
    df.bins = load.table(ifn.bins)
    df.bins = df.bins[df.bins$class == "host",]
    df = df[is.element(df$bin, df.bins$bin),]
    bins = sort(unique(df$bin))

    ll = list()
    for (ext in c("A", "C", "G", "T", "total")) {
        ll[[ext]] = load.table(paste(prefix, ".", ext, sep=""))
    }

    for (bin in bins) {
        dfb = df[df$bin == bin,]
        if (sum(dfb$fixed_count) > 1000 || sum(dfb$fixed_count) < 3)
            next
        dfb = dfb[dfb$fixed_count > 1,]
    }

}
