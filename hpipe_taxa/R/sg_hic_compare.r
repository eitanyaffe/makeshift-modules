plot.sg.hic=function(order.ifn, ca.ifn, sg.ifn, hic.ifn, taxa.ifn, fdir)
{
    atable = load.table(order.ifn)
    ca = load.table(ca.ifn)
    sg = load.table(sg.ifn)
    hic = load.table(hic.ifn)
    taxa = load.table(taxa.ifn)

    ca = ca[ca$contig_anchor != 0,]
    hic = hic[is.element(hic$contig, ca$contig),]
    sg = sg[is.element(sg$contig, ca$contig),]
    hic$anchor = ca$anchor[match(hic$contig, ca$contig)]
    sg$anchor = ca$anchor[match(sg$contig, ca$contig)]

    hic.cov = sapply(split(hic$abundance.enrichment, hic$anchor), median)
    sg.cov = sapply(split(sg$abundance.enrichment, sg$anchor), median)

    anchors = atable$set
    df = data.frame(anchor.id=atable$id, anchor=anchors,
        col=taxa$color[match(anchors, taxa$anchor)],
        hic=hic.cov[match(anchors, names(hic.cov))],
        sg=sg.cov[match(anchors, names(sg.cov))])

    lim = range(c(df$sg, df$hic))
    lim[1] = lim[1] - 0.2
    lim[2] = lim[2] + 0.2

    fig.start(fdir=fdir, ofn=paste(fdir, "/hic_vs_sg.pdf", sep=""), type="pdf", height=8, width=8)
    plot.init(xlim=lim, ylim=lim, xlab="Shotgun", ylab="Hi-C", add.grid=T, main="Shotgun vs. Hi-C")
    points(df$sg, df$hic, pch=19, col=df$col)
    abline(a=0, b=1)
    fig.end()

    fig.start(fdir=fdir, ofn=paste(fdir, "/hic_vs_sg_legend.pdf", sep=""), type="pdf", height=8, width=8)
    plot.init(xlim=lim, ylim=lim, xlab="Shotgun", ylab="Hi-C", add.grid=T, main="Shotgun vs. Hi-C")
    points(df$sg, df$hic, pch=19, col=df$col)
    abline(a=0, b=1)
    text(df$sg, df$hic, df$anchor.id, pos=4)
    fig.end()

    fig.start(fdir=fdir, ofn=paste(fdir, "/hic_vs_sg_hist.pdf", sep=""), type="pdf", height=8, width=8)
    ef = ecdf(df$hic - df$sg)
    main = 10^mean(abs(df$hic - df$sg))
    plot.stepfun(ef, col.points=df$col[order(df$hic - df$sg)], verticals=F, pch=19, xlab="Hi-C over Shotgun", main=paste("mean HiC/SG=", main, sep=""))
    abline(v=0, lty=2)
    fig.end()
}
