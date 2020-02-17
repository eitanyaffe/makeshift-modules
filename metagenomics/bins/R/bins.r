frag.table.complete=function(df)
{
#    index = rep(1,dim(df)[1])
#    fragment_id = paste(df$contig, index, sep=":")
    fragment_id = df$contig
    data.frame(contig=df$contig, frag_index=1, fragment_id=fragment_id, start=1, end=df$length, fragment_length=df$length)
}

frag.table.breakdown.internal=function(df, frag.size)
{
    # limit to contigs that are not smaller than a single fragment
    df = df[df$length >= frag.size,]

    df$n.bins = ceiling(df$length / frag.size)

    # first and last fragment are larger by extra
    df$start.coord = floor((df$length - frag.size*(df$n.bins-2))/2)

    rr = list(lengths=df$n.bins, values=df$contig)
    result = data.frame(contig=inverse.rle(rr))

    # get contig values
    result$n.bins = df$n.bins[match(result$contig,df$contig)]
    result$contig.length = df$length[match(result$contig,df$contig)]

    # compute fragment index
    result$global.index = 1:dim(result)[1]
    result$start.index = match(result$contig,result$contig)
    result$frag_index = result$global.index - result$global.index[result$start.index] + 1

    # fragment id
    result$fragment_id = paste(result$contig, result$frag_index, sep=":")

    # fragment coords
    result$start = ifelse(result$frag_index > 1, df$start.coord[match(result$contig,df$contig)] + (result$frag_index-2)*frag.size, 0) + 1
    result$end = ifelse(result$frag_index < result$n.bins, df$start.coord[match(result$contig,df$contig)] + (result$frag_index-1)*frag.size, result$contig.length)
    result$fragment_length = result$end - result$start + 1

    result[,c("contig", "frag_index", "fragment_id", "start", "end", "fragment_length")]
}

frag.table.breakdown=function(df, frag.size)
{
    df.small = df[df$length <= frag.size,]
    df.large = df[df$length > frag.size,]

    rbind(frag.table.complete(df=df.small), frag.table.breakdown.internal(df=df.large, frag.size=frag.size))
}

frag.table=function(ifn, style, uniform.size, breakdown.size, ofn)
{
    df = load.table(ifn)
    result = switch (style,
        complete=frag.table.complete(df=df),
        breakdown=frag.table.breakdown(df=df, frag.size=breakdown.size),
        stop("unknown style"))
    save.table(result, ofn)
}

metabat.contig.table=function(ifn, ofn)
{
    df = load.table(ifn)
    df = data.frame(contig=df$fragment_id, length=df$fragment_length)
    save.table(df, ofn)
}
