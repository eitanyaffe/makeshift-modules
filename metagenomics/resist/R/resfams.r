select.hits=function(ifn, ifn.genes, min.evalue, min.bitscore, ofn)
{
    genes = load.table(ifn.genes)
    df = load.table(ifn)
    ix = match(df$target, genes$gene)
    for (field in c("contig", "start", "end"))
         df[,field] = genes[ix,field]
    df = df[
        df$full_Evalue < min.evalue & df$domain_Evalue < min.evalue &
        df$full_score > min.bitscore & df$domain_score > min.bitscore,]
    save.table(df, ofn)
}
