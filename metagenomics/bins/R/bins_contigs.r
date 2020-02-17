contig.table=function(ifn, ofn.contigs, ofn.contigs.associated, ofn.bins)
{
    df = load.table(ifn)
    df$length = df$end_coord - df$start_coord + 1
    result = data.frame(contig=df$segment, length=df$length, bin=df$bin, contig.org=df$contig, start.org=df$start_coord, end.org=df$end_coord)
    save.table(result, ofn.contigs)

    result = result[result$bin != 0,]
    save.table(result, ofn.contigs.associated)

    ss.length = sapply(split(result$length, result$bin), sum)
    ss.count = sapply(split(result$length, result$bin), length)

    bins = data.frame(bin=names(ss.length), contig.count=ss.count, length=ss.length)
    save.table(bins, ofn.bins)

}
