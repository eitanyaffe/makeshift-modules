plot.changes=function(ifn.anchors, ifn.ca, ifn.contigs, ifn.snps, fdir)
{
    table = load.table(ifn.anchors)
    ca = load.table(ifn.ca)
    df.contigs = load.table(ifn.contigs)
    snps = load.table(ifn.snps)

    ca = ca[ca$anchor == ca$contig_anchor,]
    ca$id = table$id[match(ca$anchor,table$set)]
    ca$length = df.contigs$length[match(ca$contig,df.contigs$contig)]

    ix = match(ca$contig, snps$contig)
    ca$changes = ifelse(!is.na(ix), snps$count[ix], 0)

    s = split(ca[,c("contig", "length", "changes")], ca$id)
    switch.per.bp = sapply(s, function(x) { sum(x$changes) / sum(x$length) })
    df = data.frame(id=names(s), switch.per.bp=switch.per.bp)
    df = df[match(table$id, df$id),]

    fig.start(fdir=fdir, ofn=paste(fdir, "/compare.pdf", sep=""), type="pdf", height=5, width=10)
    barplot(100*df$switch.per.bp, names.arg=df$id, las=2, border=NA, col="darkgreen", ylab="%", ylim=c(0,0.1))
    fig.end()
}
