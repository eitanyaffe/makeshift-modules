
select.contigs=function(ifn, filter, min.pearson, min.zscore, max.discard.fraction, ofn.contigs, ofn.bins)
{
    df = load.table(ifn)
    df$selected = (df$pearson >= min.pearson & df$zscore >= min.zscore) | rep(!filter, dim(df)[1])

    # compute fraction of filtered contigs per bin
    tt = table(df$bin, factor(df$selected, levels=c(T,F)))
    bin.ratio = tt[,"FALSE"] / rowSums(tt)
    df.bins = data.frame(bin=rownames(tt), total.count=rowSums(tt), discarded.count=tt[,"FALSE"])
    df.bins$discard.ratio = df.bins$discarded.count / df.bins$total.count
    df.bins$selected = df.bins$discard.ratio <= max.discard.fraction

    # discard contig if bin was hit strong
    ix = match(df$bin,df.bins$bin)
    df$selected = df$selected & df.bins$selected[ix]

    save.table(df, ofn.contigs)
    save.table(df.bins, ofn.bins)
}

discard.contigs=function(ifn, ofn)
{
    df = load.table(ifn)
    ix = -match("selected",colnames(df))
    df = df[df$selected,ix]
    save.table(df, ofn)
}
