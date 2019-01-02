plot.cell.factors=function(order.ifn, ca.ifn, hic.ifn, taxa.ifn, factors.ifn, fdir)
{
    atable = load.table(order.ifn)
    ca = load.table(ca.ifn)
    hic = load.table(hic.ifn)
    taxa = load.table(taxa.ifn)
    factors = load.table(factors.ifn)

    ca = ca[ca$contig_anchor != 0,]
    hic = hic[is.element(hic$contig, ca$contig),]
    hic$anchor = ca$anchor[match(hic$contig, ca$contig)]
    hic.cov = sapply(split(hic$abundance.enrichment, hic$anchor), median)

    anchors = atable$set

    df = data.frame(anchor.id=atable$id, anchor=anchors,
        col=taxa$color[match(anchors, taxa$anchor)],
        group.id=taxa$group.id[match(anchors, taxa$anchor)],
        cov=10^hic.cov[match(anchors, names(hic.cov))])
    df$factor = factors$probs[match(df$anchor, factors$anchor1)] / df$cov

    xlim = range(df$cov)
    ylim = range(df$factor)

    ################################################################################################################
    # cov vs factor scatter
    ################################################################################################################

    fig.start(fdir=fdir, ofn=paste(fdir, "/factor_vs_abundance.pdf", sep=""), type="pdf", height=8, width=8)
    plot.init(xlim=xlim, ylim=ylim, xlab="abundance", ylab="cell-factor", add.grid=T, main="", log="xy")
    points(df$cov, df$factor, pch=19, col=df$col)
    fig.end()

    fig.start(fdir=fdir, ofn=paste(fdir, "/factor_vs_abundance_label.pdf", sep=""), type="pdf", height=8, width=8)
    plot.init(xlim=xlim, ylim=ylim, xlab="abundance", ylab="cell-factor", add.grid=T, main="", log="xy")
    points(df$cov, df$factor, pch=19, col=df$col)
    text(df$cov, df$factor, df$anchor.id, pos=4)
    fig.end()

    ################################################################################################################
    # factor by taxa boxplot plot
    ################################################################################################################

    df = df[!is.na(df$group.id),]
    ss = split(df$factor, df$group.id)
    ll = sapply(ss, length)
    ss = ss[ll>=3]
    col = df$col[match(names(ss), df$group.id)]
    fig.start(fdir=fdir, ofn=paste(fdir, "/factor_by_taxa_boxplot.pdf", sep=""), type="pdf", height=6, width=1+length(ss)*0.5)
    boxplot(ss, las=2, col=col, outline=F)
    fig.end()
}
