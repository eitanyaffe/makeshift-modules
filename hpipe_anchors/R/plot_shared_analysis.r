plot.shared.analysis=function(ifn.ca, ifn.contigs, ifn.coverage, ifn.kcube, ifn.order, fdir)
{
    anchors = load.table(ifn.order)
    ca = load.table(ifn.ca)
    cov = load.table(ifn.coverage)
    contigs = load.table(ifn.contigs)
    kcube = load.table(ifn.kcube)

    fc = field.count(ca, field="contig")
    df = data.frame(contig=fc$contig, host.count=fc$count)

    # add length
    df$length = contigs$length[match(df$contig, contigs$contig)]
    df$cov = 10^cov$abundance.enrichment[match(df$contig, cov$contig)]

    # add prevalence
    ix = match(df$contig,kcube$item)
    df$prev = ifelse(!is.na(ix), kcube$subject.ratio[ix], -1)
    df = df[df$prev >= 0,]

    # boxplots
    ss = split(df$prev, cut(df$host.count, breaks=c(0,1,2,3,4,20)))
    fig.start(fdir=fdir, ofn=paste(fdir, "/prev_vs_hosts.pdf", sep=""), type="pdf", width=12, height=12)
    boxplot(ss, xlab="#hosts", ylab="prev")
    fig.end()

    # plotting params
    df$length.size = 1 + 5 * df$length / max(df$length)
    # df$col.hosts = ifelse(df$host.count == 2, "gray", ifelse(df$host.count <= 4, "orange", "darkgreen"))
    cols = rainbow(max(df$host.count))
    cols = colorpanel(max(df$host.count), "blue", "red")
    df$col.hosts = cols[df$host.count]

    # limit to shared
    df1 = df[df$host.count == 1,]
    dfn = df[df$host.count > 1,]

    xlim = range(dfn$prev)
    ylim = range(dfn$cov)

    size = 12

    fig.start(fdir=fdir, ofn=paste(fdir, "/prev_vs_abundance.pdf", sep=""), type="pdf", width=size, height=size)
    plot.init(xlim=xlim, ylim=ylim, xlab="prevalence", ylab="abundance", main="prev_vs_abundance")
    points(df1$prev, df1$cov, col="lightgray", pch=19)
    points(dfn$prev, dfn$cov, col=dfn$col.hosts, pch=19)
    fig.end()

    fig.start(fdir=fdir, ofn=paste(fdir, "/prev_vs_abundance_label.pdf", sep=""), type="pdf", width=size, height=size)
    plot.init(xlim=xlim, ylim=ylim, xlab="prevalence", ylab="abundance", main="prev_vs_abundance")
    points(df1$prev, df1$cov, col="lightgray", pch=19)
    points(dfn$prev, dfn$cov, col=dfn$col.hosts, pch=19)
    dfx = dfn[dfn$host.count>3,]
    text(dfx$prev, dfx$cov, dfx$contig, pos=4)
    fig.end()
}
