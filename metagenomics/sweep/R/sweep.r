merge.libs=function(ifn.a, ifn.b, ifn.contigs, ifn.bins, ofn)
{
    df.a = load.table(ifn.a)
    df.b = load.table(ifn.b)
    contigs = load.table(ifn.contigs)
    bins = load.table(ifn.bins)

    mm = merge(df.a, df.b, by=c("host", "element"), all=T)
    mm$element_is_singleton = ifelse(!is.na(mm$element_is_singleton.x), mm$element_is_singleton.x, mm$element_is_singleton.y)
    mm$count.x[is.na(mm$count.x)] = 0
    mm$count.y[is.na(mm$count.y)] = 0
    result = mm[,c("host", "element", "element_is_singleton")]
    result$length = ifelse(result$element_is_singleton, contigs$length[match(result$element, contigs$contig)], bins$length[match(result$element, bins$bin)])

    result$count.a = mm$count.x
    result$count.b = mm$count.y
    save.table(result, ofn)
}

get.ratio=function(ifn, ofn)
{
    df = load.table(ifn)
    hosts = sort(unique(df$host))

    result = NULL
    for (host in hosts) {
        dfh = df[df$host == host,]
        if (dim(dfh)[1] < 5)
            next
        fit = lm(dfh$count.b ~ 0 + dfh$count.a)
        result = rbind(result, data.frame(host=host, ratio=fit[1]$coefficients))
    }
    save.table(result, ofn)
}

select.change=function(ifn.cmp, ifn.ratio, min.log.fold, min.count, min.ratio, ofn)
{
    df = load.table(ifn.cmp)
    ratio.df = load.table(ifn.ratio)

    ix = match(df$host, ratio.df$host)
    df$ratio = ifelse(!is.na(ix), ratio.df$ratio[ix], 1)
    df$log.fold = log10((df$count.b+1) / (df$ratio*(df$count.a+1)))
    df = df[df$ratio > min.ratio,]

    df = df[abs(df$log.fold) >= min.log.fold & ((df$count.a >= min.count) | (df$count.b >= min.count)),]
    df$class = ifelse(df$log.fold > 0, "gain", "loss")
    save.table(df, ofn)
}

get.genes=function(ifn.elements, ifn.gene2contig, ifn.contig2bin, ifn.uniref, ofn)
{
    df = load.table(ifn.elements)
    gene2contig = load.table(ifn.gene2contig)
    contig2bin = load.table(ifn.contig2bin)
    uniref = load.table(ifn.uniref)

    uniref$contig = gene2contig$contig[match(uniref$gene,gene2contig$gene)]

    result = NULL
    # singlton contigs
    dfs = df[df$element_is_singleton,]
    uni.single = uniref[is.element(uniref$contig, dfs$element),]
    uni.single$element = uni.single$contig
    uni.single$type = "singleton"

    # elements
    dfe = df[!df$element_is_singleton,]
    contig2bin = contig2bin[is.element(contig2bin$bin,dfe$element),]
    uni.element = uniref[is.element(uniref$contig, contig2bin$contig),]
    uni.element$element = contig2bin$bin[match(uni.element$contig, contig2bin$contig)]
    uni.element$type = "element"

    result = rbind(uni.element, uni.single)
    save.table(result, ofn)
}
