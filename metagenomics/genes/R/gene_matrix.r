gene.matrix=function(ifn.genes, ifn.libs, idir, ofn)
{
    df = load.table(ifn.genes)
    ids = load.table(ifn.libs)$MAP_LIB_ID
    for (id in ids) {
        ifg = paste(idir, "/libs/", id, "/gene.table", sep="")
        dfg = load.table(ifg)
        ix = match(df$gene, dfg$gene)
        if (any(is.na(ix)))
            stop("internal")
        df[,as.character(id)] = dfg$count[ix]
    }
    save.table(df, ofn)
}
