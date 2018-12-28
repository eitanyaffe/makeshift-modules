filter.cags=function(ifn.cag.table, ifn.gene, min.prevalence, sample.count, ofn.cag, ofn.gene)
{
    df = load.table(ifn.cag.table)
    df$prev = 100 * df$observed_count / sample.count
    df = df[df$prev > min.prevalence,]
    df = df[order(df$prev, decreasing=T),]
    df$id = sub("CAG:", "", df$id)

    save.table(df, ofn.cag)

    genes = load.table(ifn.gene)
    genes.out = genes[is.element(genes$set, df$id),]
    save.table(genes.out, ofn.gene)
}
