cag.taxa=function(ifn.genes, ifn.taxa, ofn)
{
    genes = load.table(ifn.genes)
    taxa = load.table(ifn.taxa)
    sets = sort(unique(genes$set))

    ix = match(genes$gene, taxa$gene)
    genes$taxa = ifelse(!is.na(ix), taxa$tax[ix], "none")
    result = NULL
    for (set in sets) {
        x = genes$taxa[genes$set == set]
        tt = table(x)
        oo = order(tt, decreasing=T)
        tt = tt[oo]
        N = length(tt)
        df = data.frame(set=rep(set, N), name=names(tt), count=tt, percent=100*tt/sum(tt))
        result = rbind(result, df)
    }
    save.table(result, ofn)
}
