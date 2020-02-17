
append.stats=function(ifn.merge, ifn.stats, ofn)
{
    df = load.table(ifn.merge)
    stats = load.table(ifn.stats)
    ix = match(df$id, stats$GO)
    if (any(is.na(ix)))
        stop("internal error")
    fields = setdiff(names(stats), "GO")
    for (field in fields)
        df[,field] = stats[ix,field]
    save.table(df, ofn)
}

select.GO=function(ifn, min.gene.count, min.enrichment, min.ml.pvalue, ofn)
{
    df = load.table(ifn)
    df = df[df$count >= min.gene.count & df$enrichment >= min.enrichment & df$minus.log.p >= min.ml.pvalue,]
    df = df[order(df$enrichment, decreasing=T),]
    save.table(df, ofn)
}
