get.single.depth=function(ifn, ofn)
{
    df = load.table(ifn)
    df$index = as.numeric(sub("k141_", "", df$contig))
    df = df[order(df$index),]
    result = data.frame(contig=df$contig, depth=df$reads.per.bp)
    save.table(result, ofn)
}

get.multi.depth=function(ifn.coverage, ifn.contigs, ofn)
{
    df = load.table(ifn.coverage)
    df.contigs = load.table(ifn.contigs)

    fields = names(df)[-1]

    df$index = as.numeric(sub("k141_", "", df$contig))
    df$contig.length = df.contigs$length[match(df$contig,df.contigs$contig)]
    df = df[order(df$index),]

    result = data.frame(contig=df$contig, as.matrix(df[,fields]) / df$contig.length)
}
