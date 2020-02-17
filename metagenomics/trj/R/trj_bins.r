get.hosts=function(ifn, ofn)
{
    df = load.table(ifn)
    df = df[df$class == "host",]
    save.table(df, ofn)
}

bin.trj=function(ifn.bins, ifn.c2b, ifn.norm, ifn.obs, ifn.exp,
    ofn.obs, ofn.exp, ofn.mean, ofn.sd, ofn.top95, ofn.top75, ofn.median, ofn.bottom25, ofn.bottom05, ofn.bottom0, ofn.top100)
{
    bins = load.table(ifn.bins)
    c2b = load.table(ifn.c2b)

    norm = load.table(ifn.norm)
    obs = load.table(ifn.obs)
    exp = load.table(ifn.exp)
    N = dim(norm)[2] - 1
    names = names(norm)[-1]

    result.mean = NULL
    result.top100 = NULL
    result.top95 = NULL
    result.top75 = NULL
    result.median = NULL
    result.bottom0 = NULL
    result.bottom05 = NULL
    result.bottom25 = NULL
    result.sd = NULL

    result.obs = NULL
    result.exp = NULL

    for (bin in bins$bin) {
        contigs = c2b$contig[c2b$bin == bin]
        size = length(contigs)

        # normalized matrix
        rx = as.matrix(norm[is.element(norm$contig,contigs),-1])
        result.mean = rbind(result.mean, data.frame(bin=bin, size=size, t(apply(rx, 2, mean))))
        result.top100 = rbind(result.top100, data.frame(bin=bin, size=size, t(apply(rx, 2, function(x) quantile(x, 1)))))
        result.top95 = rbind(result.top95, data.frame(bin=bin, size=size, t(apply(rx, 2, function(x) quantile(x, 0.95)))))
        result.top75 = rbind(result.top75, data.frame(bin=bin, size=size, t(apply(rx, 2, function(x) quantile(x, 0.75)))))
        result.median = rbind(result.median, data.frame(bin=bin, size=size, t(apply(rx, 2, function(x) quantile(x, 0.5)))))
        result.bottom0 = rbind(result.bottom0, data.frame(bin=bin, size=size, t(apply(rx, 2, function(x) quantile(x, 0)))))
        result.bottom05 = rbind(result.bottom05, data.frame(bin=bin, size=size, t(apply(rx, 2, function(x) quantile(x, 0.05)))))
        result.bottom25 = rbind(result.bottom25, data.frame(bin=bin, size=size, t(apply(rx, 2, function(x) quantile(x, 0.25)))))
        ssd = if (size > 1) t(apply(rx, 2, sd)) else t(rep(0, N))
        colnames(ssd) = names
        result.sd = rbind(result.sd, data.frame(bin=bin, size=size, ssd))

        # obs
        ox = as.matrix(obs[is.element(obs$contig,contigs),-1])
        result.obs = rbind(result.obs, data.frame(bin=bin, t(colSums(ox))))

        # exp
        ex = as.matrix(exp[is.element(exp$contig,contigs),-1])
        result.exp = rbind(result.exp, data.frame(bin=bin, t(colSums(ex))))
    }

    save.table(result.obs, ofn.obs)
    save.table(result.exp, ofn.exp)
    save.table(result.mean, ofn.mean)
    save.table(result.top100, ofn.top100)
    save.table(result.top95, ofn.top95)
    save.table(result.top75, ofn.top75)
    save.table(result.median, ofn.median)
    save.table(result.bottom05, ofn.bottom05)
    save.table(result.bottom25, ofn.bottom25)
    save.table(result.bottom0, ofn.bottom0)
    save.table(result.sd, ofn.sd)
}
