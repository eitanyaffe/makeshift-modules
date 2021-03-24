merge.sites=function(ifn.segregating.sites, ifn.diverge.sites, ofn.sites, ofn.bins)
{
    df1 = load.table(ifn.segregating.sites)
    df2 = load.table(ifn.diverge.sites)
    rr = rbind(df1, df2)
    rr = rr[!duplicated(rr),]
    save.table(rr, ofn.sites)

    tt = table(rr$bin)
    df = data.frame(bin=names(tt), site.count=as.vector(tt))
    save.table(df, ofn.bins)
}

collect.data=function(ifn, idir, ofn.sets, ofn.set.pairs, ofn.segregating.sites, ofn.diverge.sites)
{
    df = load.table(ifn)
    sets = unique(df$set)
    N = length(sets)

    cat(sprintf("number of set pairs: %d\n", (N*(N-1))/2))

    fields = c("bin", "contig", "coord", "var")
    # 2D
    result.set.pairs = NULL
    result.div.sites = NULL
    for (i in 1:N) {
        for (j in 1:N) {
            if (i >= j)
                next
            set.i = sets[i]
            set.j = sets[j]
            df.diverge = read.delim(paste(idir, "/diverge/", set.i, "_", set.j, "/bin.tab", sep=""))
            result.set.pairs = rbind(result.set.pairs, data.frame(set1=set.i, set2=set.j, df.diverge))

            df.div.sites = read.delim(paste(idir, "/diverge/", set.i, "_", set.j, "/bin.sites", sep=""))
            df.div.sites$var = df.div.sites$major_var
            result.div.sites = rbind(result.div.sites, df.div.sites[,fields])
        }
    }
    save.table(result.set.pairs, ofn.set.pairs)
    result.div.sites = result.div.sites[!duplicated(result.div.sites),]
    save.table(result.div.sites, ofn.diverge.sites)

    cat(sprintf("number of sets: %d\n", N))

    # 1D
    result.sets = NULL
    result.seg.sites = NULL
    for (i in 1:N) {
        set = sets[i]
        df.cov = read.delim(paste(idir, "/bins/coverage/", set, "/bin.xcov", sep=""))
        df.segregate = read.delim(paste(idir, "/segregate/", set, "/bin_segregate.tab", sep=""))

        if (!setequal(df.cov$bin, df.segregate$bin))
            stop("bin sets in coverage and segregation files not equal")

        colnames(df.cov)[-1] = paste("cov_", colnames(df.cov)[-1], sep="")

        ix = match(df.segregate$bin, df.cov$bin)
        xx = match("bin", colnames(df.cov))
        result.sets = rbind(result.sets, data.frame(set=set, df.segregate, df.cov[ix,-xx]))

        df.seg.sites = read.delim(paste(idir, "/segregate/", set, "/bin_segregate.sites", sep=""))
        df.seg.sites$var = df.seg.sites$major_allele
        result.seg.sites = rbind(result.seg.sites, df.seg.sites[,fields])

    }
    save.table(result.sets, ofn.sets)
    result.seg.sites = result.seg.sites[!duplicated(result.seg.sites),]
    save.table(result.seg.sites, ofn.segregating.sites)
}


collect.trajectory=function(ifn.libs, ifn.sites, field, idir, tag, ofn.count, ofn.total)
{
    df.sets = load.table(ifn.libs)
    df.sites = load.table(ifn.sites)
    sets = unique(df.sets$set)
    N = length(sets)

    cat(sprintf("number of sets: %d\n", N))
    df = data.frame(contig=df.sites$contig, coord=df.sites$coord, var=df.sites[,field])

    # 1D
    result.count = df
    result.total = df
    keys = paste(df$contig, df$coord, df$var)

    for (i in 1:N) {
        set = sets[i]
        df = read.delim(paste(idir, "/", set, "/", tag, sep=""))
        df.keys = paste(df$contig, df$coord, df$var)
        if (!setequal(keys, df.keys))
            stop("contig/coord/var keys must be identical across library sets")
        ix = match(keys, df.keys)
        result.count = cbind(result.count, df$count[ix])
        result.total = cbind(result.total, df$total[ix])
    }
    colnames(result.count)[-(1:3)] = sets
    colnames(result.total)[-(1:3)] = sets

    save.table(result.count, ofn.count)
    save.table(result.total, ofn.total)
}

collect.nts=function(ifn.libs, ifn.sites, idir, tag, ofn.A, ofn.C, ofn.G, ofn.T)
{
    df.sets = load.table(ifn.libs)
    df.sites = load.table(ifn.sites)
    sets = unique(df.sets$set)
    N = length(sets)

    # make unique
    df.sites = df.sites[!duplicated(paste(df.sites$contig, df.sites$coord)),]

    cat(sprintf("number of sets: %d\n", N))
    df = data.frame(contig=df.sites$contig, coord=df.sites$coord)

    # 1D
    result.A = df
    result.C = df
    result.G = df
    result.T = df
    keys = paste(df$contig, df$coord)

    for (i in 1:N) {
        set = sets[i]
        df = read.delim(paste(idir, "/", set, "/", tag, sep=""))
        df.keys = paste(df$contig, df$coord)
        if (!setequal(keys, df.keys))
            stop("contig/coord keys must be identical across library sets")
        ix = match(keys, df.keys)
        result.A = cbind(result.A, df$A[ix])
        result.C = cbind(result.C, df$C[ix])
        result.G = cbind(result.G, df$G[ix])
        result.T = cbind(result.T, df$T[ix])
    }
    colnames(result.A)[-(1:2)] = sets
    colnames(result.C)[-(1:2)] = sets
    colnames(result.G)[-(1:2)] = sets
    colnames(result.T)[-(1:2)] = sets

    save.table(result.A, ofn.A)
    save.table(result.C, ofn.C)
    save.table(result.G, ofn.G)
    save.table(result.T, ofn.T)
}
