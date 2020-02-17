gene2bin.table=function(ifn.genes, ifn.contigs, ifn.bins, ofn)
{
    df = load.table(ifn.genes)
    bins = load.table(ifn.bins)
    contigs = load.table(ifn.contigs)

    bins = bins[bins$class == "host",]
    df = df[is.element(df$contig, contigs$contig),]
    df$bin = contigs$bin[match(df$contig, contigs$contig)]
    result = df[,c("gene", "contig", "bin")]

    result = result[is.element(result$bin, bins$bin),]
    save.table(result, ofn)
}
