gene.matrix=function(ifn, idir, ids, ofn)
{
    df = data.frame(gene=load.table(ifn)[,"gene"])
    for (id  in ids) {
        ifg = paste(idir, "/libs/", id, "/gene.table", sep="")
        if (!file.exists(ifg))
            next
        dfg = load.table(ifg)
        ix = match(df$gene, dfg$gene)
        if (any(is.na(ix)))
            stop("internal")
        df[,id] = dfg$count[ix]
    }
    save.table(df, ofn)
}
