create.table=function(ifn, lib.count, respect.keys, ofn)
{
    df = load.table(ifn)
    df = df[df$Meas_Type == "MetaG",]
    df$date = as.Date(df$Samp_Date, "%d-%b-%Y")

    if (any(table(df$date) > 1)) {
        ss = split(df, df$date)
        new.df = NULL
        for (i in 1:length(ss)) {
            df.lib = ss[[i]]
            df.lib = df.lib[order(df.lib$Samp_Type),]
            df.lib = df.lib[1,]
            new.df = rbind(new.df, df.lib)
        }
        df = new.df
    }
    df = df[order(df$date),]
    df$lib.index = 1:dim(df)[1]

    bin.df=function(dfx) {
        N = dim(dfx)[1]
        dfx$index = 1:N
        n.bins = floor(N / lib.count)
        if (n.bins > 1) {
            breaks = c(0, 1:(n.bins-1)*lib.count, N)
            as.numeric(cut(dfx$index, breaks=breaks))
        } else {
            rep(1, N)
        }
    }

    result = NULL
    if (respect.keys) {
        keys = unique(df$Event_Key)
        df$key.index = match(df$Event_Key, keys)
        df$key.diff = diff(c(0, df$key.index))
        breaks = c(which(df$key.diff != 0), dim(df)[1]+1)
        ss = split(df, cut(df$lib.index, breaks=breaks, right=F))
        result = NULL
        set.count = 0
        for (i in 1:length(ss)) {
            result.i = ss[[i]]
            result.i$set.index = bin.df(result.i) + set.count
            result = rbind(result, result.i)
            set.count = max(result$set.index)
        }
    } else {
        df$set.index = bin.df(df)
        result = df
    }
    result$set = paste("s", result$set.index, sep="")
    result = result[,c("lib.index", "lib", "date", "Event_Key", "set", "set.index")]
    save.table(result, ofn)
}

merge.libs=function(nlv.bin, ifn, ids, lib.dir, ofn)
{
    ifns = paste(lib.dir, "/libs/", ids, "/lib.nlv", sep="")

    command = paste(nlv.bin, "merge", ofn, paste(ifns, collapse=" "))
    if (system(command) != 0)
        stop(paste("error in command:", command))
}

merge.sets=function(ifn, module, is.dry)
{
    df = load.table(ifn)
    sets = unique(df$set)
    N = length(sets)

    cat(sprintf("number of libraries: %d\n", dim(df)[1]))
    cat(sprintf("number of sets: %d\n", N))

    for (set in sets) {
        ids = paste(df$lib[df$set == set], collapse=" ")
        command = sprintf("make m=%s nlv_merge_lib NLV_SET=%s NLV_SET_IDS='%s'",
            module, set, ids)
        if (is.dry) {
            command = paste(command, "-n")
        }
        if (system(command) != 0)
            stop(paste("error in command:", command))
    }
}

make.set.pairs=function(ifn, module, target, is.dry)
{
    df = load.table(ifn)
    sets = unique(df$set)
    N = length(sets)

    cat(sprintf("number of libraries: %d\n", dim(df)[1]))
    cat(sprintf("number of sets: %d\n", N))


    for (i in 1:N) {
        for (j in 1:N) {
            if (i >= j)
                next
            set.i = sets[i]
            set.j = sets[j]
            command = sprintf("make m=%s %s NLV_SET1=%s NLV_SET2=%s",
                module, target, set.i, set.j)
            if (is.dry) {
                command = paste(command, "-n")
            }
            if (system(command) != 0)
                stop(paste("error in command:", command))
        }
    }
    if (is.dry)
        stop(paste("dry run, stopping", command))
}

make.sets=function(ifn, module, target, is.dry)
{
    df = load.table(ifn)
    sets = unique(df$set)
    N = length(sets)

    cat(sprintf("number of libraries: %d\n", dim(df)[1]))
    cat(sprintf("number of sets: %d\n", N))

    for (i in 1:N) {
        set = sets[i]
        command = sprintf("make m=%s %s NLV_SET=%s",
            module, target, set)
        if (is.dry) {
            command = paste(command, "-n")
        }
        if (system(command) != 0)
            stop(paste("error in command:", command))
    }
    if (is.dry)
        stop(paste("dry run, stopping", command))
}

make.set.table=function(ifn, base.dir, ofn)
{
    df = load.table(ifn)
    sets = unique(df$set)
    result = data.frame(set=sets, fn=paste(base.dir, "/sets/", sets, "/set.nlv", sep=""))
    save.table(result, ofn)
}

collect.data=function(ifn, idir, ofn.sets, ofn.set.pairs, ofn.segregating.sites, ofn.diverge.sites)
{
    df = load.table(ifn)
    sets = unique(df$set)
    N = length(sets)

    cat(sprintf("number of sets: %d\n", N))

    # 1D
    result.sets = NULL
    result.seg.sites = NULL
    for (i in 1:N) {
        set = sets[i]
        df.cov = read.delim(paste(idir, "/sets/", set, "/bin.xcov", sep=""))
        df.segregate = read.delim(paste(idir, "/sets/", set, "/bin_segregate.tab", sep=""))

        if (!setequal(df.cov$bin, df.segregate$bin))
            stop("bin sets in coverage and segregation files not equal")

        colnames(df.cov)[-1] = paste("cov_", colnames(df.cov)[-1], sep="")

        ix = match(df.segregate$bin, df.cov$bin)
        xx = match("bin", colnames(df.cov))
        result.sets = rbind(result.sets, data.frame(set=set, df.segregate, df.cov[ix,-xx]))

        df.seg.sites = read.delim(paste(idir, "/sets/", set, "/bin_segregate.sites", sep=""))
        df.seg.sites$var = df.seg.sites$major_allele
        result.seg.sites = rbind(result.seg.sites, df.seg.sites[,c("bin", "contig", "coord", "var")])

    }
    save.table(result.sets, ofn.sets)
    result.seg.sites = result.seg.sites[!duplicated(result.seg.sites),]
    save.table(result.seg.sites, ofn.segregating.sites)

    cat(sprintf("number of set pairs: %d\n", (N*(N-1))/2))

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
            df.div.sites = df.div.sites[,c("bin", "contig", "coord", "var1", "var2")]
            df1 = df.div.sites
            df1$var = df1$var1
            df2 = df.div.sites
            df2$var = df2$var2
            result.div.sites = rbind(result.div.sites, df1, df2)
        }
    }
    save.table(result.set.pairs, ofn.set.pairs)

    result.div.sites = result.div.sites[,c("bin", "contig", "coord", "var")]
    result.div.sites = result.div.sites[!duplicated(result.div.sites),]
    save.table(result.div.sites, ofn.diverge.sites)
}

collect.trajectory=function(ifn.libs, ifn.sites, idir, tag, ofn.count, ofn.total)
{
    df.sets = load.table(ifn.libs)
    df.sites = load.table(ifn.sites)
    sets = unique(df.sets$set)
    N = length(sets)

    cat(sprintf("number of sets: %d\n", N))

    # order
    df.sites = df.sites[order(df.sites$bin, df.sites$contig, df.sites$coord),]

    # 1D
    result.count = df.sites
    result.total = df.sites
    keys = paste(df.sites$contig, df.sites$coord, df.sites$var)

    for (i in 1:N) {
        set = sets[i]
        df = read.delim(paste(idir, "/sets/", set, "/", tag, sep=""))
        df.keys = paste(df$contig, df$coord, df$var)
        if (!setequal(keys, df.keys))
            stop("contig/coord/var keys must be identical across library sets")
        ix = match(keys, df.keys)
        result.count = cbind(result.count, df$count[ix])
        result.total = cbind(result.total, df$total[ix])
    }
    colnames(result.count)[-(1:4)] = sets
    colnames(result.total)[-(1:4)] = sets

    save.table(result.count, ofn.count)
    save.table(result.total, ofn.total)
}
