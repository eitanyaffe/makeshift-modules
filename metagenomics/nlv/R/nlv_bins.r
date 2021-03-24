restrict.contigs=function(ifn.bins, ifn.c2b, bin.field, bin.value, ofn)
{
    bins = load.table(ifn.bins)
    c2b = load.table(ifn.c2b)

    bins = bins[bins[,bin.field] == bin.value,]
    c2b = c2b[is.element(c2b$bin, bins$bin),]
    save.table(c2b, ofn)
}

generage.bin.segments=function(ifn.contigs, ifn.bins, ifn.c2b, bin.field, bin.value, margin, ofn.segments, ofn.bins)
{
    contigs = load.table(ifn.contigs)
    bins = load.table(ifn.bins)
    c2b = load.table(ifn.c2b)

    bins = bins[bins[,bin.field] == bin.value,]

    result.bins = NULL
    result.segments = NULL
    cat(sprintf("generaring segments for %d bins\n", length(bins$bin)));

    for (bin in bins$bin) {
        contigs.bin = c2b$contig[c2b$bin == bin]
        segments = data.frame(bin=bin, contig=contigs.bin)
        contig.length = contigs$length[match(segments$contig,contigs$contig)]

        # trim start and end of contig
        segments$start = margin
        segments$end = contig.length-margin
        segments$length = segments$end - segments$start

        segments = segments[segments$length >= margin,]

        result.bins = rbind(result.bins, data.frame(bin=bin, segment.count=dim(segments)[1], segment.length=sum(segments$length)))
        result.segments = rbind(result.segments, segments)
    }

    save.table(result.bins, ofn.bins)
    save.table(result.segments, ofn.segments)
}

diverge.filter=function(ifn, min.major.freq, ifn.cov1, ifn.cov2, min.p, max.p, ofn)
{
    df = load.table(ifn)

    df$f1 = round(pmax(df$major1, df$minor1) / (df$coverage1 + 1),2)
    df$f2 = round(pmax(df$major2, df$minor2) / (df$coverage2 + 1),2)
    changed = (df$major1 > df$minor1 & df$major2 < df$minor2) | (df$major1 < df$minor1 & df$major2 > df$minor2)
    result = df[changed & df$f1 > min.major.freq & df$f2 > min.major.freq,]

    #cov1 = load.table(ifn.cov1)
    #cov2 = load.table(ifn.cov2)
    #df = df[df$coverage1 > 0 & df$coverage2 > 0,]
    #ix1 = match(df$bin, cov1$bin)
    #ix2 = match(df$bin, cov2$bin)
    #min1 = cov1[ix1,min.p]
    #max1 = cov1[ix1,max.p]
    #min2 = cov2[ix2,min.p]
    #max2 = cov2[ix2,max.p]

    #result = df[df$coverage1 >= min1 & df$coverage1 <= max1& df$coverage2 >= min2 & df$coverage2 <= max2,]

    save.table(result, ofn)
}

segregate.filter=function(ifn, ifn.cov, min.p, max.p, ofn)
{
    df = load.table(ifn)
    cov = load.table(ifn.cov)

    ix = match(df$bin, cov$bin)
    min = cov[ix,min.p]
    max = cov[ix,max.p]

    result = df[df$total_count >= min & df$total_count <= max,]

    save.table(result, ofn)
}

bins.site.summary=function(ifn.sites, ifn.bins, ofn)
{
    sites = load.table(ifn.sites)
    bins = load.table(ifn.bins)

    tt = table(sites$bin)
    ix = match(bins$bin, names(tt))

    bins$site.count = ifelse(!is.na(ix), tt[ix], 0)
    bins$site.density = round(bins$site.count / bins$segment.length,7)

    save.table(bins, ofn)

}
