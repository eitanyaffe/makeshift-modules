plot.basic=function(ifn, ifn.contigs, fdir)
{
    cc = load.table(ifn.contigs)
    df = load.table(ifn)

    df$length = cc$length[match(df$contig, cc$contig)]

    tt = table(df$cluster)
    tt = tt[order(names(tt))]
    N = length(tt)

    fig.start(fdir=fdir, ofn=paste(fdir, "/cluster_contig_count.pdf", sep=""), type="pdf", width=2+N*0.1, height=4)
    barplot(tt, names.arg=names(tt), ylab="#contigs", border=NA, las=2)
    fig.end()

    ss = sapply(split(df$length/10^6, df$cluster), sum)
    N = length(ss)
    ss = ss[order(names(ss))]
    fig.start(fdir=fdir, ofn=paste(fdir, "/cluster_mb.pdf", sep=""), type="pdf", width=2+N*0.1, height=4)
    barplot(ss, names.arg=names(ss), ylab="mb", border=NA, las=2)
    fig.end()
}
