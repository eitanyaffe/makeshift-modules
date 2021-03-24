make.contig.table=function(ifn, ofn)
{
    df = load.table(ifn)
    df$length = df$end - df$start + 1
    result = data.frame(contig=df$segment, length=df$length, is.outlier=df$is_outlier, original.contig=df$contig, original.start=df$start, original.end=df$end)
    save.table(result, ofn)
}
