cag.summary=function(ifn.genes, ifn.kcube.summary, ifn.depend, ofn)
{
    genes = load.table(ifn.genes)
    kcube = load.table(ifn.kcube.summary)
    depend = load.table(ifn.depend)

    ix = match(kcube$item, genes$gene)
    if (any(is.na(ix)))
        stop("not all genes found")
    kcube$cag = genes$set[ix]

    ss = split(kcube, kcube$cag)
    s.prev = sapply(ss, function(x) { median(x$subject.ratio) })
    s.xcov = sapply(ss, function(x) { median(x$mean.median.xcov) })
    s.identity = sapply(ss, function(x) { median(x$identity) })
    s.count = sapply(ss, function(x) { dim(x)[1] })

    result = data.frame(cag=sort(unique(kcube$cag)))
    result$gene.count = s.count[match(result$cag, names(s.count))]
    result$fraction = s.prev[match(result$cag, names(s.prev))]
    result$xcov = s.xcov[match(result$cag, names(s.xcov))]
    result$identity = round(s.identity[match(result$cag, names(s.identity))],5)

    ix = match(paste("CAG:", result$cag, sep=""), depend$dependent)
    result$host = ifelse(!is.na(ix), depend$host[ix], "none")
    result$host.taxa = ifelse(!is.na(ix), depend$host_taxa[ix], "none")

    save.table(result, ofn)
}

cag.select=function(ifn, min.fraction, min.identity, min.xcov, force.cags, ofn)
{
    df = load.table(ifn)

    if (any(force.cags == "NA"))
        df = df[df$host == "none" & df$identity >= min.identity & df$xcov >= min.xcov & df$fraction >= min.fraction,]
    else
        df = df[is.element(df$cag,force.cags),]
    save.table(df, ofn)
}

cag.genes=function(ifn, ifn.genes, ifn.uniref, ofn)
{
    df = load.table(ifn)
    genes = load.table(ifn.genes)
    uniref = load.table(ifn.uniref)

    uniref$cag = genes$set[match(uniref$gene, genes$gene)]

    result = data.frame(cag=genes$set, gene=genes$gene, length=genes$length)
    result = result[is.element(result$cag, df$cag),]

    ix = match(result$gene, uniref$gene)
    result$uniref = ifelse(!is.na(ix), uniref$uniref[ix], "none")
    result$identity = ifelse(!is.na(ix), uniref$identity[ix], 0)
    result$coverage = round(ifelse(!is.na(ix), uniref$coverage[ix], 0),2)
    result$prot_desc = ifelse(!is.na(ix), uniref$prot_desc[ix], "none")
    result$tax = ifelse(!is.na(ix), uniref$tax[ix], "none")
    result$uniref_count = ifelse(!is.na(ix), uniref$uniref_count[ix], 0)
    result$evalue = ifelse(!is.na(ix), uniref$evalue[ix], 0)

    save.table(result, ofn)
}
