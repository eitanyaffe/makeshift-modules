explode.bins=function(ifn.bins, ifn.sites, ifn.A, ifn.C, ifn.G, ifn.T, ofn, odir)
{
    df.bins = load.table(ifn.bins)
    df.bins = df.bins[df.bins$class == "host",]
    df.sites = load.table(ifn.sites)
    df.sites = df.sites[!duplicated(paste(df.sites$bin, df.sites$contig, df.sites$coord)),]

    dfA = load.table(ifn.A)
    dfC = load.table(ifn.C)
    dfG = load.table(ifn.G)
    dfT = load.table(ifn.T)

    save.table.f=function(df, bin, nt, odir) {
        df = df[df$bin == bin,]
        names(df)[1] = "index"
        df$index = 1:dim(df)[1]
        save.table(df, paste0(odir.bin, "/", nt), verbose=F)
    }

    result = NULL
    for (bin in df.bins$bin) {
        nsites = sum(df.sites$bin == bin)
        if (nsites == 0)
            next
        result = rbind(result, data.frame(bin=bin, nsites=nsites))
        odir.bin = paste0(odir, "/", bin)
        cat(sprintf("preparing tables in directory: %s\n", odir.bin))
        if (system(paste("mkdir -p", odir.bin)) != 0)
            stop("internal error")
        write.table(c(nsites, dim(dfA)[2]-3), paste0(odir.bin, "/params"), col.names=F, row.names=F)
        save.table.f(df=dfA, bin=bin, nt="A", odir=odir.bin)
        save.table.f(df=dfC, bin=bin, nt="C", odir=odir.bin)
        save.table.f(df=dfG, bin=bin, nt="G", odir=odir.bin)
        save.table.f(df=dfT, bin=bin, nt="T", odir=odir.bin)
    }
    save.table(result, ofn)
}

run.finder=function(ifn, module, target, max.N, maxSNPs, is.dry)
{
    if (file.info(ifn)$size == 1)
        return (NULL)

    df = load.table(ifn)

    # limit number of SNPs
    if (!any(df$nsites<maxSNPs))
        return (NULL)
    df = df[df$nsites<maxSNPs,]

    bins = unique(df$bin)

    cat(sprintf("number of bins: %d\n", length(bins)))
    n.strains = 2:max.N

    for (i in 1:length(bins)) {
        bin = bins[i]
        for (j in 1:length(n.strains)) {
            command = sprintf("make m=%s %s STRAIN_FINDER_N=%s STRAIN_BIN=%s",
                module, target, n.strains[j], bin)
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

bins.limit=function(ifn, maxSNPs, ofn)
{
    df = load.table(ifn)
    df = df[df$nsites < maxSNPs,]
    save.table(df, ofn)
}

extract.optimal=function(ifn, idir, type, ofn)
{
    df = load.table(ifn)
    if (is.numeric(type)) {
        fn = paste0(idir, "/N", type, "/otu_table.txt")
    } else {
        ix = which.min(df[,type])
        fn = paste0(idir, "/N", df$N[ix], "/otu_table.txt")
    }
    command = sprintf("cp %s %s", fn, ofn)
    cat(sprintf("%s\n", command))
    if (system(command) != 0)
        stop("command failed")
}

extract.genotype=function(ifn, idir, ofn.genotype, ofn.class)
{
    df = load.table(ifn)
    seqs = names(df)
    result = load.table(paste0(idir, "/A"))[,1:3]
    nsites = dim(result)[1]
    for (i in 1:length(seqs)) {
        id = paste0("s", i)
        if (length(seqs[i]) > nsites)
            stop("not all sites found")
        seq = substr(seqs[i], 1, nsites)
        result[,id] = strsplit(seq, "")
    }
    save.table(result, ofn.genotype)

    # classes
    ids = names(result)[-(1:3)]
    mm = as.matrix(result[,-(1:3)])
    result.class = result[,1:3]
    result.class$ngroups = 0
    result.class$full.label = ""
    result.class$short.label = ""
    for (i in 1:nsites) {
        ss = split(ids, mm[i,])
        ss = ss[order(sapply(ss, length))]
        sslen = sapply(ss, length)
        sslab = sapply(ss, function(x) { paste(x, sep="", collapse=",") })
        ngroups = length(ss)
        full.label = paste(sslab, collapse="|")
        short.label = paste(sslab[-ngroups], collapse="|")
        result.class$ngroups[i] = ngroups
        result.class$full.label[i] = full.label
        result.class$short.label[i] = short.label
    }
    save.table(result.class, ofn.class)
}

make.bins=function(ifn, module, target, maxSNPs, is.dry)
{
    if (file.info(ifn)$size == 1)
        return (NULL)

    df = load.table(ifn)

    # limit number of SNPs
    if (!any(df$nsites<maxSNPs))
        return (NULL)
    df = df[df$nsites<maxSNPs,]

    bins = unique(df$bin)

    cat(sprintf("number of bins: %d\n", length(bins)))

    for (i in 1:length(bins)) {
        bin = bins[i]
        command = sprintf("make m=%s %s STRAIN_BIN=%s", module, target, bin)
        if (is.dry) {
            command = paste(command, "-n")
        }
        if (system(command) != 0)
            stop(paste("error in command:", command))
    }
    if (is.dry)
        stop(paste("dry run, stopping", command))
}
