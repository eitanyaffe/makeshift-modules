anchor.segments=function(ifn.anchor.order, ifn.anchors, ifn.ca, ifn.contigs, ifn.genes, ofn)
{
    # anchor segments
    anchor.table = load.table(ifn.anchor.order)
    ca = load.table(ifn.ca)
    genes = load.table(ifn.genes)
    contigs = load.table(ifn.contigs)

    ca = ca[ca$contig_anchor == ca$anchor,]
    ca$anchor.id = anchor.table$id[match(ca$anchor,anchor.table$set)]
    ca$start = 1
    ca$end = contigs$length[match(ca$contig,contigs$contig)]
    ca$length = ca$end-ca$start

    # gene per contig
    tt = table(genes$contig)
    gene.count.table = data.frame(contig=names(tt), count=as.vector(tt))

    result = NULL
    for (anchor.id in anchor.table$id) {
        anchor = anchor.table$set[match(anchor.id,anchor.table$id)]
        df = ca[ca$anchor.id == anchor.id,]

        ix = match(df$contig, gene.count.table$contig)
        gene.count = ifelse(!is.na(ix), gene.count.table$count[ix], 0)
        N = dim(df)[1]
        result = rbind(result, data.frame(set=anchor.id, contig=df$contig, segment=1:N, start=df$start, end=df$end, length=df$length, gene_count=gene.count))
    }
    save.table(result, ofn)

}

merge.segments=function(ifn.cores, ifn.elements, ifn.anchors, ifn.anchor.order, ofn)
{
    anchor.table = load.table(ifn.anchor.order)

    # core segments
    df.cores = load.table(ifn.cores)
    df.cores$set = anchor.table$id[match(df.cores$set, anchor.table$set)]
    df.cores$type = "core"

    # anchor segments
    df.anchors = load.table(ifn.anchors)
    df.anchors$type = "anchor"
    df.anchors = df.anchors[!is.element(df.anchors$set, df.cores$set),]

    # element segments
    df.elements = load.table(ifn.elements)
    df.elements$type = "element"

    df = rbind(df.anchors, df.cores, df.elements)
    N = dim(df)[1]
    df$segment=paste("s", 1:N, sep="_")
    oo = setdiff(names(df), c("segment"))
    df = df[, c("segment", oo)]

    save.table(df, ofn)
}

bin.segments=function(ifn.segments, ifn.contigs, binsize, min.binsize, min.segment.size, read.length, ofn.bins, ofn.segments)
{
    df.contigs = load.table(ifn.contigs)
    df = load.table(ifn.segments)

    max.coord = df.contigs$length[match(df$contig, df.contigs$contig)] - read.length
    df$end = pmin(df$end, max.coord)
    df$length = df$end - df$start + 1

    # select segments
    df = df[df$length >= min.segment.size,]

    N = dim(df)[1]
    cat(sprintf("binning %d segments...\n", N))

    result = NULL
    for (i in 1:N) {
        set = df$set[i]
        segment = df$segment[i]
        contig = df$contig[i]
        start = df$start[i]
        end = df$end[i]
        length = end - start + 1
        n.bins = ceiling(length/binsize)
        bin.start = start + (1:n.bins - 1)*binsize
        bin.end = pmin(bin.start+binsize-1, end)
        df.bins = data.frame(set=set, segment=segment, contig=contig, start=bin.start, end=bin.end, length=bin.end-bin.start+1)
        if (!any(df.bins$length >= min.binsize))
            next

        # select bins
        df.bins = df.bins[df.bins$length >= min.binsize,]

        result = rbind(result, df.bins)
    }

    # select segments with at least one bin
    df = df[is.element(df$segment, result$segment),]

    M = dim(result)[1]
    result$bin=paste("b", 1:M, sep="_")
    oo = setdiff(names(result), c("segment", "bin"))
    result = result[, c("segment", "bin", oo)]

    cat(sprintf("result number of segments: %d\n", dim(df)[1]))
    cat(sprintf("result number of bins: %d\n", dim(result)[1]))

    save.table(df, ofn.segments)
    save.table(result, ofn.bins)
}

segment.summary=function(ifn, ofn)
{
    df = load.table(ifn)
    ss = split(df, df$set)
    result = data.frame(set=names(ss))
    result$type = sapply(ss, function(x) { x$type[1] })
    result$segment.count = sapply(ss, function(x) { dim(x)[1] })
    result$gene.count = sapply(ss, function(x) { sum(x$gene_count) })
    result$length = sapply(ss, function(x) { sum(x$length) })

    save.table(result, ofn)
}
