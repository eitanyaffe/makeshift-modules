compute.profile=function(ifn.bins, ifn.norm, ifn.obs, ifn.exp,
    ofn.obs, ofn.exp, ofn.mean, ofn.sd, ofn.top95, ofn.top75, ofn.median, ofn.bottom25, ofn.bottom05, ofn.bottom0, ofn.top100)
{
    df = load.table(ifn.bins)

    norm = load.table(ifn.norm)
    obs = load.table(ifn.obs)
    exp = load.table(ifn.exp)

    sets = unique(df$set)

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

    cat(sprintf("computing profiles for sets, N=%d\n",  length(sets)))
    for (set in sets) {
        bins = df$bin[df$set == set]
        size = length(bins)

        # normalized matrix
        rx = as.matrix(norm[is.element(norm$bin,bins),-1])
        result.mean = rbind(result.mean, data.frame(cluster=set, size=size, t(apply(rx, 2, mean))))
        result.top100 = rbind(result.top100, data.frame(cluster=set, size=size, t(apply(rx, 2, function(x) quantile(x, 1)))))
        result.top95 = rbind(result.top95, data.frame(cluster=set, size=size, t(apply(rx, 2, function(x) quantile(x, 0.95)))))
        result.top75 = rbind(result.top75, data.frame(cluster=set, size=size, t(apply(rx, 2, function(x) quantile(x, 0.75)))))
        result.median = rbind(result.median, data.frame(cluster=set, size=size, t(apply(rx, 2, function(x) quantile(x, 0.5)))))
        result.bottom0 = rbind(result.bottom0, data.frame(cluster=set, size=size, t(apply(rx, 2, function(x) quantile(x, 0)))))
        result.bottom05 = rbind(result.bottom05, data.frame(cluster=set, size=size, t(apply(rx, 2, function(x) quantile(x, 0.05)))))
        result.bottom25 = rbind(result.bottom25, data.frame(cluster=set, size=size, t(apply(rx, 2, function(x) quantile(x, 0.25)))))
        ssd = if (size > 1) t(apply(rx, 2, sd)) else t(rep(0, N))
        colnames(ssd) = names
        result.sd = rbind(result.sd, data.frame(cluster=set, size=size, ssd))

        # obs
        ox = as.matrix(obs[is.element(obs$bin,bins),-1])
        result.obs = rbind(result.obs, data.frame(cluster=set, t(colSums(ox))))

        # exp
        ex = as.matrix(exp[is.element(exp$bin,bins),-1])
        result.exp = rbind(result.exp, data.frame(cluster=set, t(colSums(ex))))
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


compute.bin.cor=function(ifn.bins, ifn.norm, ifn.median, ofn)
{
    df = load.table(ifn.bins)
    norm = load.table(ifn.norm)
    med = load.table(ifn.median)

    result = NULL
    sets = unique(df$set)
    cat(sprintf("comparing bin to set, number of sets: %d\n",  length(sets)))
    for (set in sets) {
        bins = df$bin[df$set == set]
        bin.profile = norm[match(bins,norm$bin),-1]
        set.profile = med[med$cluster == set,-(1:2)]
        cc = as.vector(cor(t(bin.profile), t(set.profile)))
        result = rbind(result, data.frame(bin=bins, set=set, cor=cc))
    }

    save.table(result, ofn)
}

compute.set.cor=function(ifn, ofn)
{
    df = load.table(ifn)
    sets = unique(df$set)
    cat(sprintf("computing mean set correlations, number of sets: %d\n",  length(sets)))
    result = NULL
    for (set in sets) {
        vals = df$cor[df$set == set]
        ssd = if (length(vals) > 3) sd(vals) else 0
        result = rbind(result, data.frame(set=set, size=length(vals), min=min(vals), max=max(vals), median=median(vals), mean=mean(vals), sd=ssd))
    }
    save.table(result, ofn)
}
